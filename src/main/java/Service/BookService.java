package Service;

import Dao.BookDAO;
import Dao.CategoryDAO;
import Dao.SellerDAO;
import Entity.Book;
import Entity.Category;
import Entity.Seller;

import java.util.List;
import java.util.Set;

public class BookService {

    public static final int MAX_TITLE_LENGTH = 200;
    public static final int MAX_AUTHOR_LENGTH = 150;
    public static final int MAX_DESCRIPTION_LENGTH = 5000;
    public static final int MAX_CONDITION_LENGTH = 50;
    public static final int MAX_LOCATION_LENGTH = 150;
    public static final int MAX_STATUS_LENGTH = 30;

    public static final Set<String> ALLOWED_CONDITIONS = Set.of(
            "NEW", "LIKE_NEW", "GOOD", "ACCEPTABLE"
    );

    public static final Set<String> ALLOWED_STATUSES = Set.of(
            "AVAILABLE", "PENDING", "SWAPPED", "UNAVAILABLE"
    );

    private final BookDAO bookDAO;
    private final CategoryDAO categoryDAO;
    private final SellerDAO sellerDAO;

    public BookService() {
        this.bookDAO = new BookDAO();
        this.categoryDAO = new CategoryDAO();
        this.sellerDAO = new SellerDAO();
    }

    public void saveBook(Book book) {
        validateBookEntity(book, true);
        bookDAO.saveBook(book);
    }

    public Book createBook(String title,
                           String author,
                           String description,
                           String bookCondition,
                           String location,
                           Long categoryId,
                           Long sellerId) {

        validateBookFields(title, author, description, bookCondition, location, "AVAILABLE");

        if (categoryId == null || categoryId <= 0) {
            throw new IllegalArgumentException("Please select a valid category.");
        }
        if (sellerId == null || sellerId <= 0) {
            throw new IllegalArgumentException("A valid seller is required to add a book.");
        }

        Category category = categoryDAO.getCategoryById(categoryId);
        if (category == null) {
            throw new IllegalArgumentException("Selected category does not exist.");
        }

        Seller seller = sellerDAO.getSellerById(sellerId);
        if (seller == null) {
            throw new IllegalArgumentException("Selected seller does not exist.");
        }

        Book book = new Book();
        book.setTitle(title.trim());
        book.setAuthor(normalizeOptional(author));
        book.setDescription(normalizeOptional(description));
        book.setBookCondition(normalizeCondition(bookCondition));
        book.setLocation(normalizeOptional(location));
        book.setStatus("AVAILABLE");
        book.setCategory(category);
        book.setSeller(seller);

        bookDAO.saveBook(book);
        return book;
    }

    public List<Book> getAllBooks() {
        return bookDAO.getAllBooks();
    }

    public Book getBookById(Long id) {
        if (id == null || id <= 0) {
            return null;
        }
        return bookDAO.getBookById(id);
    }

    public List<Book> getBooksBySellerId(Long sellerId) {
        if (sellerId == null || sellerId <= 0) {
            return List.of();
        }
        return bookDAO.getBooksBySellerId(sellerId);
    }

    public List<Book> searchAndFilterBooks(String keyword,
                                           Long categoryId,
                                           String bookCondition,
                                           String status) {

        String cleanKeyword = normalizeOptional(keyword);
        String cleanCondition = normalizeConditionFilter(bookCondition);
        String cleanStatus = normalizeStatusFilter(status);

        if (cleanKeyword == null && categoryId == null && cleanCondition == null && cleanStatus == null) {
            return bookDAO.getAllBooks();
        }

        return bookDAO.searchAndFilterBooks(cleanKeyword, categoryId, cleanCondition, cleanStatus);
    }

    public void updateBook(Book book) {
        validateBookEntity(book, false);
        bookDAO.updateBook(book);
    }

    public Book updateBookForSeller(Long bookId,
                                    String title,
                                    String author,
                                    String description,
                                    String bookCondition,
                                    String location,
                                    String status,
                                    Long categoryId,
                                    Long authenticatedSellerId) {

        if (bookId == null || bookId <= 0) {
            throw new IllegalArgumentException("Invalid book ID.");
        }
        if (authenticatedSellerId == null || authenticatedSellerId <= 0) {
            throw new SecurityException("Authentication is required to edit a book.");
        }

        Book existingBook = bookDAO.getBookById(bookId);
        if (existingBook == null) {
            throw new IllegalArgumentException("Book not found.");
        }

        if (!canSellerModifyBook(existingBook, authenticatedSellerId)) {
            throw new SecurityException("You are not authorized to edit another seller's book.");
        }

        String resolvedStatus = (status == null || status.isBlank())
                ? existingBook.getStatus()
                : status.trim().toUpperCase();

        validateBookFields(title, author, description, bookCondition, location, resolvedStatus);

        if (categoryId == null || categoryId <= 0) {
            throw new IllegalArgumentException("Please select a valid category.");
        }

        Category category = categoryDAO.getCategoryById(categoryId);
        if (category == null) {
            throw new IllegalArgumentException("Selected category does not exist.");
        }

        existingBook.setTitle(title.trim());
        existingBook.setAuthor(normalizeOptional(author));
        existingBook.setDescription(normalizeOptional(description));
        existingBook.setBookCondition(normalizeCondition(bookCondition));
        existingBook.setLocation(normalizeOptional(location));
        existingBook.setStatus(resolvedStatus);
        existingBook.setCategory(category);
        // Preserve existingBook.getSeller() unchanged

        bookDAO.updateBook(existingBook);
        return existingBook;
    }

    public void deleteBook(Long id) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException("Invalid book ID.");
        }
        bookDAO.deleteBook(id);
    }

    public void deleteBookForSeller(Long bookId, Long authenticatedSellerId) {
        if (bookId == null || bookId <= 0) {
            throw new IllegalArgumentException("Invalid book ID.");
        }
        if (authenticatedSellerId == null || authenticatedSellerId <= 0) {
            throw new SecurityException("Authentication is required to delete a book.");
        }

        Book existingBook = bookDAO.getBookById(bookId);
        if (existingBook == null) {
            throw new IllegalArgumentException("Book not found.");
        }

        if (!canSellerModifyBook(existingBook, authenticatedSellerId)) {
            throw new SecurityException("You are not authorized to delete another seller's book.");
        }

        boolean deleted = bookDAO.deleteBookById(bookId);
        if (!deleted) {
            throw new IllegalArgumentException("Book could not be deleted because it no longer exists.");
        }
    }

    public boolean canSellerModifyBook(Book book, Long authenticatedSellerId) {
        if (book == null || book.getSeller() == null || book.getSeller().getId() == null) {
            return false;
        }
        return authenticatedSellerId != null && authenticatedSellerId.equals(book.getSeller().getId());
    }

    public List<Category> getAllCategories() {
        List<Category> categories = categoryDAO.getAllCategories();
        if (categories.isEmpty()) {
            List<String> defaults = List.of(
                    "Academic & Textbooks",
                    "Children & Young Adult",
                    "Fiction",
                    "History & Biography",
                    "Non-Fiction",
                    "Science & Technology"
            );
            for (String name : defaults) {
                try {
                    categoryDAO.saveCategory(new Category(name));
                } catch (Exception ignored) {
                    // Ignore duplicate if concurrently inserted
                }
            }
            categories = categoryDAO.getAllCategories();
        }
        return categories;
    }

    public Category getCategoryById(Long id) {
        return categoryDAO.getCategoryById(id);
    }

    public List<Seller> getAllSellers() {
        List<Seller> sellers = sellerDAO.getAllSellers();
        if (sellers.isEmpty()) {
            try {
                sellerDAO.saveSeller(new Seller(
                        "Ranjit Barik",
                        "ranjit@bookswap.local",
                        "9876543210",
                        "Bhubaneswar, Odisha"
                ));
                sellerDAO.saveSeller(new Seller(
                        "Rahul Sharma",
                        "rahul@bookswap.local",
                        "9123456780",
                        "Cuttack, Odisha"
                ));
            } catch (Exception ignored) {
                // Ignore duplicate if concurrently inserted
            }
            sellers = sellerDAO.getAllSellers();
        }
        return sellers;
    }

    public Seller getSellerById(Long id) {
        return sellerDAO.getSellerById(id);
    }

    public Seller getSellerByEmail(String email) {
        return sellerDAO.getSellerByEmail(email);
    }

    public Seller resolveOrSyncAuthenticatedSeller(Long userId,
                                                   String email,
                                                   String name,
                                                   String phone,
                                                   String address) {
        if (email != null && !email.isBlank()) {
            Seller byEmail = sellerDAO.getSellerByEmail(email.trim());
            if (byEmail != null) {
                return byEmail;
            }
            if (name != null && !name.isBlank()) {
                Seller newSeller = new Seller(
                        name.trim(),
                        email.trim(),
                        normalizeOptional(phone),
                        normalizeOptional(address)
                );
                sellerDAO.saveSeller(newSeller);
                return newSeller;
            }
        }
        if (userId != null && userId > 0) {
            return sellerDAO.getSellerById(userId);
        }
        return null;
    }

    private void validateBookEntity(Book book, boolean isCreate) {
        if (book == null) {
            throw new IllegalArgumentException("Book cannot be null.");
        }
        if (!isCreate && (book.getId() == null || book.getId() <= 0)) {
            throw new IllegalArgumentException("Valid book ID is required for update.");
        }
        String status = (book.getStatus() == null || book.getStatus().isBlank())
                ? "AVAILABLE"
                : book.getStatus().trim().toUpperCase();
        validateBookFields(
                book.getTitle(),
                book.getAuthor(),
                book.getDescription(),
                book.getBookCondition(),
                book.getLocation(),
                status
        );
        if (book.getCategory() == null || book.getCategory().getId() == null) {
            throw new IllegalArgumentException("Category is required.");
        }
        if (book.getSeller() == null || book.getSeller().getId() == null) {
            throw new IllegalArgumentException("Seller is required.");
        }
        book.setTitle(book.getTitle().trim());
        book.setAuthor(normalizeOptional(book.getAuthor()));
        book.setDescription(normalizeOptional(book.getDescription()));
        book.setBookCondition(normalizeCondition(book.getBookCondition()));
        book.setLocation(normalizeOptional(book.getLocation()));
        book.setStatus(status);
    }

    public void validateBookFields(String title,
                                   String author,
                                   String description,
                                   String bookCondition,
                                   String location,
                                   String status) {

        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("Book title is required.");
        }
        if (title.trim().length() > MAX_TITLE_LENGTH) {
            throw new IllegalArgumentException("Book title must not exceed " + MAX_TITLE_LENGTH + " characters.");
        }

        if (author != null && author.trim().length() > MAX_AUTHOR_LENGTH) {
            throw new IllegalArgumentException("Author name must not exceed " + MAX_AUTHOR_LENGTH + " characters.");
        }

        if (description != null && description.trim().length() > MAX_DESCRIPTION_LENGTH) {
            throw new IllegalArgumentException("Description must not exceed " + MAX_DESCRIPTION_LENGTH + " characters.");
        }

        if (bookCondition == null || bookCondition.isBlank()) {
            throw new IllegalArgumentException("Book condition is required.");
        }
        String normalizedCondition = bookCondition.trim().toUpperCase();
        if (normalizedCondition.length() > MAX_CONDITION_LENGTH || !ALLOWED_CONDITIONS.contains(normalizedCondition)) {
            throw new IllegalArgumentException("Invalid book condition. Allowed values: NEW, LIKE_NEW, GOOD, ACCEPTABLE.");
        }

        if (location != null && location.trim().length() > MAX_LOCATION_LENGTH) {
            throw new IllegalArgumentException("Location must not exceed " + MAX_LOCATION_LENGTH + " characters.");
        }

        if (status == null || status.isBlank()) {
            throw new IllegalArgumentException("Book status is required.");
        }
        String normalizedStatus = status.trim().toUpperCase();
        if (normalizedStatus.length() > MAX_STATUS_LENGTH || !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Invalid book status. Allowed values: AVAILABLE, PENDING, SWAPPED, UNAVAILABLE.");
        }
    }

    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeCondition(String condition) {
        if (condition == null || condition.isBlank()) {
            return null;
        }
        return condition.trim().toUpperCase();
    }

    private String normalizeConditionFilter(String condition) {
        if (condition == null || condition.isBlank()) {
            return null;
        }
        String upper = condition.trim().toUpperCase();
        return ALLOWED_CONDITIONS.contains(upper) ? upper : null;
    }

    private String normalizeStatusFilter(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        String upper = status.trim().toUpperCase();
        return ALLOWED_STATUSES.contains(upper) ? upper : null;
    }
}