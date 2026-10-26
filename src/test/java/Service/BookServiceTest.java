package Service;

import Entity.Book;
import Entity.Category;
import Entity.Seller;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class BookServiceTest {

    private BookService bookService;
    private Category testCategory;
    private Seller ownerSeller;
    private Seller otherSeller;

    @Before
    public void setUp() {
        bookService = new BookService();
        List<Category> categories = bookService.getAllCategories();
        assertFalse("Categories should be seeded", categories.isEmpty());
        testCategory = categories.get(0);

        List<Seller> sellers = bookService.getAllSellers();
        assertTrue("At least two sellers should be available", sellers.size() >= 2);
        ownerSeller = sellers.get(0);
        otherSeller = sellers.get(1);
    }

    @Test
    public void testCreateReadUpdateSearchAndDeleteLifecycle() {
        // 1. Create book
        Book created = bookService.createBook(
                "Effective Java 3rd Edition",
                "Joshua Bloch",
                "Best practices for the Java platform.",
                "LIKE_NEW",
                "Bhubaneswar",
                testCategory.getId(),
                ownerSeller.getId()
        );
        assertNotNull(created.getId());
        assertEquals("AVAILABLE", created.getStatus());

        // 2. Read book by ID
        Book fetched = bookService.getBookById(created.getId());
        assertNotNull(fetched);
        assertEquals("Effective Java 3rd Edition", fetched.getTitle());
        assertEquals(ownerSeller.getId(), fetched.getSeller().getId());
        assertEquals(testCategory.getId(), fetched.getCategory().getId());

        // 3. Search & filter (parameterized HQL)
        List<Book> searchByTitle = bookService.searchAndFilterBooks(
                "Effective Java", testCategory.getId(), "LIKE_NEW", "AVAILABLE"
        );
        assertTrue(searchByTitle.stream().anyMatch(b -> b.getId().equals(created.getId())));

        // Verify parameterized HQL handles special characters safely without HQL injection
        List<Book> injectionAttempt = bookService.searchAndFilterBooks(
                "' OR '1'='1", null, null, null
        );
        assertTrue(injectionAttempt.isEmpty());

        // 4. My Books (filter by owner seller)
        List<Book> ownerBooks = bookService.getBooksBySellerId(ownerSeller.getId());
        assertTrue(ownerBooks.stream().anyMatch(b -> b.getId().equals(created.getId())));

        // 5. Unauthorized seller cannot edit
        try {
            bookService.updateBookForSeller(
                    created.getId(),
                    "Hijacked Title",
                    "Joshua Bloch",
                    "Tampered",
                    "GOOD",
                    "Cuttack",
                    "AVAILABLE",
                    testCategory.getId(),
                    otherSeller.getId()
            );
            fail("Expected SecurityException when non-owner tries to edit book");
        } catch (SecurityException expected) {
            // Expected
        }

        // 6. Authorized owner can edit
        Book updated = bookService.updateBookForSeller(
                created.getId(),
                "Effective Java (Updated)",
                "Joshua Bloch",
                "Updated description.",
                "GOOD",
                "Bhubaneswar",
                "PENDING",
                testCategory.getId(),
                ownerSeller.getId()
        );
        assertEquals("Effective Java (Updated)", updated.getTitle());
        assertEquals("GOOD", updated.getBookCondition());
        assertEquals("PENDING", updated.getStatus());
        assertEquals("Seller ownership must be preserved", ownerSeller.getId(), updated.getSeller().getId());

        // 7. Unauthorized seller cannot delete
        try {
            bookService.deleteBookForSeller(created.getId(), otherSeller.getId());
            fail("Expected SecurityException when non-owner tries to delete book");
        } catch (SecurityException expected) {
            // Expected
        }

        // 8. Authorized owner can delete
        bookService.deleteBookForSeller(created.getId(), ownerSeller.getId());
        assertNull("Book should be removed after deletion", bookService.getBookById(created.getId()));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRejectBlankTitle() {
        bookService.createBook(
                "   ",
                "Author",
                "Description",
                "GOOD",
                "Location",
                testCategory.getId(),
                ownerSeller.getId()
        );
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRejectInvalidCategoryId() {
        bookService.createBook(
                "Valid Title",
                "Author",
                "Description",
                "GOOD",
                "Location",
                999999L,
                ownerSeller.getId()
        );
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRejectInvalidSellerId() {
        bookService.createBook(
                "Valid Title",
                "Author",
                "Description",
                "GOOD",
                "Location",
                testCategory.getId(),
                999999L
        );
    }

    @Test
    public void testDatabaseFailureAndTransactionRollback() {
        Dao.BookDAO dao = new Dao.BookDAO();
        int countBefore = dao.getAllBooks().size();

        Book invalidDbBook = new Book();
        // Title is @Column(nullable = false) in DB; bypassing service validation to force DB failure in DAO
        invalidDbBook.setTitle(null);
        invalidDbBook.setCategory(testCategory);
        invalidDbBook.setSeller(ownerSeller);

        try {
            dao.saveBook(invalidDbBook);
            fail("Expected RuntimeException when database constraint fails in BookDAO");
        } catch (RuntimeException expected) {
            assertTrue(expected.getMessage().contains("Failed to save book"));
        }

        int countAfter = dao.getAllBooks().size();
        assertEquals("Book count should be unchanged after transaction rollback", countBefore, countAfter);
    }
}
