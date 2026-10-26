package Service;

import Dao.SellerDAO;
import Entity.Book;
import Entity.Category;
import Entity.Seller;
import Entity.SwapRequest;
import Util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.Assert.*;

public class SwapRequestServiceTest {

    private BookService bookService;
    private SwapRequestService swapRequestService;
    private Category testCategory;
    private Seller sellerA;
    private Seller sellerB;
    private Seller sellerC;

    private final List<Long> createdRequestIds = new ArrayList<>();
    private final List<Long> createdBookIds = new ArrayList<>();

    @Before
    public void setUp() {
        bookService = new BookService();
        swapRequestService = new SwapRequestService();

        List<Category> categories = bookService.getAllCategories();
        assertFalse("Categories should exist", categories.isEmpty());
        testCategory = categories.get(0);

        List<Seller> sellers = bookService.getAllSellers();
        assertTrue("At least two sellers should exist", sellers.size() >= 2);

        SellerDAO sellerDAO = new SellerDAO();
        Seller third = sellerDAO.getSellerByEmail("third.swap.tester@bookswap.local");
        if (third == null) {
            third = new Seller(
                    "Priya Nair",
                    "third.swap.tester@bookswap.local",
                    "9000011111",
                    "Puri, Odisha"
            );
            sellerDAO.saveSeller(third);
        }
        sellerC = third;

        List<Seller> nonThirdSellers = bookService.getAllSellers().stream()
                .filter(s -> !s.getId().equals(sellerC.getId()))
                .toList();
        assertTrue("At least two other sellers should exist", nonThirdSellers.size() >= 2);
        sellerA = nonThirdSellers.get(0);
        sellerB = nonThirdSellers.get(1);
    }

    @After
    public void tearDown() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();
            for (Long reqId : createdRequestIds) {
                if (reqId != null) {
                    SwapRequest req = session.get(SwapRequest.class, reqId);
                    if (req != null) {
                        session.remove(req);
                    }
                }
            }
            for (Long bookId : createdBookIds) {
                if (bookId != null) {
                    Book b = session.get(Book.class, bookId);
                    if (b != null) {
                        session.remove(b);
                    }
                }
            }
            tx.commit();
        } catch (Exception ignored) {
        }
        createdRequestIds.clear();
        createdBookIds.clear();
    }

    private Book createTestBook(String title, Seller owner) {
        Book book = bookService.createBook(
                title,
                "Test Author",
                "Test book for swap workflow.",
                "GOOD",
                "Bhubaneswar",
                testCategory.getId(),
                owner.getId()
        );
        createdBookIds.add(book.getId());
        return book;
    }

    @Test
    public void testCreateValidSwapRequestDuplicatePreventionAndReject() {
        Book bookA = createTestBook("Java Programming", sellerA);
        Book bookB = createTestBook("C Programming", sellerB);

        SwapRequest created = swapRequestService.createRequest(
                sellerA.getId(),
                bookA.getId(),
                bookB.getId()
        );
        assertNotNull(created.getId());
        createdRequestIds.add(created.getId());
        assertEquals("PENDING", created.getStatus());

        // Sent and received queries
        List<SwapRequest> sentByA = swapRequestService.getSentRequests(sellerA.getId());
        assertTrue(sentByA.stream().anyMatch(r -> r.getId().equals(created.getId())));

        List<SwapRequest> receivedByB = swapRequestService.getReceivedRequests(sellerB.getId());
        assertTrue(receivedByB.stream().anyMatch(r -> r.getId().equals(created.getId())));

        // Duplicate pending request between the same books must be rejected
        try {
            swapRequestService.createRequest(sellerA.getId(), bookA.getId(), bookB.getId());
            fail("Expected IllegalStateException for duplicate pending request");
        } catch (IllegalStateException expected) {
            assertTrue(expected.getMessage().contains("already exists"));
        }

        // Rejecting the request must NOT change book availability
        swapRequestService.rejectRequest(created.getId(), sellerB.getId());

        SwapRequest rejected = swapRequestService.getRequestById(created.getId());
        assertEquals("REJECTED", rejected.getStatus());
        assertEquals("AVAILABLE", bookService.getBookById(bookA.getId()).getStatus());
        assertEquals("AVAILABLE", bookService.getBookById(bookB.getId()).getStatus());

        // Appears in swap history
        List<SwapRequest> historyB = swapRequestService.getSwapHistory(sellerB.getId());
        assertTrue(historyB.stream().anyMatch(r -> r.getId().equals(created.getId())));
    }

    @Test
    public void testRejectInvalidOwnershipAndSelfSwap() {
        Book bookA1 = createTestBook("Seller A Book 1", sellerA);
        Book bookA2 = createTestBook("Seller A Book 2", sellerA);
        Book bookB = createTestBook("Seller B Book", sellerB);

        // Seller A tries to offer Seller B's book
        try {
            swapRequestService.createRequest(sellerA.getId(), bookB.getId(), bookA1.getId());
            fail("Expected IllegalArgumentException when offering a book not owned by requester");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("only offer a book that you own"));
        }

        // Seller A tries to request Seller A's own book
        try {
            swapRequestService.createRequest(sellerA.getId(), bookA1.getId(), bookA2.getId());
            fail("Expected IllegalArgumentException when requesting own book");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("cannot request a book from yourself"));
        }

        // Swapping a book with itself
        try {
            swapRequestService.createRequest(sellerA.getId(), bookA1.getId(), bookA1.getId());
            fail("Expected IllegalArgumentException when swapping a book with itself");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("cannot swap a book with itself"));
        }
    }

    @Test
    public void testRejectUnavailableBooks() {
        Book bookA = createTestBook("Available Book A", sellerA);
        Book bookB = createTestBook("Unavailable Book B", sellerB);

        bookService.updateBookForSeller(
                bookB.getId(),
                bookB.getTitle(),
                bookB.getAuthor(),
                bookB.getDescription(),
                bookB.getBookCondition(),
                bookB.getLocation(),
                "SWAPPED",
                testCategory.getId(),
                sellerB.getId()
        );

        try {
            swapRequestService.createRequest(sellerA.getId(), bookA.getId(), bookB.getId());
            fail("Expected IllegalArgumentException when requested book is not AVAILABLE");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("must be available"));
        }
    }

    @Test
    public void testUnauthorizedResponseAcceptReservesBooksAndRepeatedResponseFails() {
        Book bookA = createTestBook("Clean Architecture", sellerA);
        Book bookB = createTestBook("Domain-Driven Design", sellerB);

        SwapRequest req = swapRequestService.createRequest(
                sellerA.getId(),
                bookA.getId(),
                bookB.getId()
        );
        createdRequestIds.add(req.getId());

        // Non-owner (requester A) cannot accept the request
        try {
            swapRequestService.acceptRequest(req.getId(), sellerA.getId());
            fail("Expected SecurityException when non-owner tries to accept request");
        } catch (SecurityException expected) {
            assertTrue(expected.getMessage().contains("not authorized"));
        }

        // Non-owner (seller C) cannot reject the request
        try {
            swapRequestService.rejectRequest(req.getId(), sellerC.getId());
            fail("Expected SecurityException when unrelated seller tries to reject request");
        } catch (SecurityException expected) {
            assertTrue(expected.getMessage().contains("not authorized"));
        }

        // Recipient owner (seller B) accepts the request -> both books become RESERVED
        swapRequestService.acceptRequest(req.getId(), sellerB.getId());

        SwapRequest accepted = swapRequestService.getRequestById(req.getId());
        assertEquals("ACCEPTED", accepted.getStatus());
        assertEquals("RESERVED", bookService.getBookById(bookA.getId()).getStatus());
        assertEquals("RESERVED", bookService.getBookById(bookB.getId()).getStatus());

        // Repeated accept or reject on already-processed request must fail
        try {
            swapRequestService.acceptRequest(req.getId(), sellerB.getId());
            fail("Expected IllegalStateException on repeated accept");
        } catch (IllegalStateException expected) {
            assertTrue(expected.getMessage().contains("already been processed"));
        }

        try {
            swapRequestService.rejectRequest(req.getId(), sellerB.getId());
            fail("Expected IllegalStateException on reject after accept");
        } catch (IllegalStateException expected) {
            assertTrue(expected.getMessage().contains("already been processed"));
        }
    }

    @Test
    public void testSeparateCompletionWorkflowMarksBooksSwapped() {
        Book bookA = createTestBook("Design Patterns", sellerA);
        Book bookB = createTestBook("Refactoring", sellerB);

        SwapRequest req = swapRequestService.createRequest(
                sellerA.getId(),
                bookA.getId(),
                bookB.getId()
        );
        createdRequestIds.add(req.getId());

        // Cannot complete while still PENDING
        try {
            swapRequestService.completeRequest(req.getId(), sellerB.getId());
            fail("Expected IllegalStateException when completing a PENDING request");
        } catch (IllegalStateException expected) {
            assertTrue(expected.getMessage().contains("ACCEPTED"));
        }

        // Owner accepts -> books are RESERVED
        swapRequestService.acceptRequest(req.getId(), sellerB.getId());
        assertEquals("RESERVED", bookService.getBookById(bookA.getId()).getStatus());
        assertEquals("RESERVED", bookService.getBookById(bookB.getId()).getStatus());

        // Unrelated seller C cannot complete the swap
        try {
            swapRequestService.completeRequest(req.getId(), sellerC.getId());
            fail("Expected SecurityException when non-participant tries to complete swap");
        } catch (SecurityException expected) {
            assertTrue(expected.getMessage().contains("not authorized"));
        }

        // Participant completes the exchange -> request becomes COMPLETED and books become SWAPPED
        swapRequestService.completeRequest(req.getId(), sellerA.getId());

        SwapRequest completed = swapRequestService.getRequestById(req.getId());
        assertEquals("COMPLETED", completed.getStatus());
        assertEquals("SWAPPED", bookService.getBookById(bookA.getId()).getStatus());
        assertEquals("SWAPPED", bookService.getBookById(bookB.getId()).getStatus());
    }

    @Test
    public void testConcurrentAcceptanceAttemptsPreventConflictingSwaps() throws Exception {
        Book bookA = createTestBook("Concurrent Offer A", sellerA);
        Book bookC = createTestBook("Concurrent Offer C", sellerC);
        Book targetBookB = createTestBook("Highly Contended Book B", sellerB);

        // Two competing PENDING requests targeting the same requested book (targetBookB)
        SwapRequest reqFromA = swapRequestService.createRequest(
                sellerA.getId(),
                bookA.getId(),
                targetBookB.getId()
        );
        createdRequestIds.add(reqFromA.getId());

        SwapRequest reqFromC = swapRequestService.createRequest(
                sellerC.getId(),
                bookC.getId(),
                targetBookB.getId()
        );
        createdRequestIds.add(reqFromC.getId());

        ExecutorService pool = Executors.newFixedThreadPool(2);
        CountDownLatch readyLatch = new CountDownLatch(2);
        CountDownLatch startLatch = new CountDownLatch(1);
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger conflictCount = new AtomicInteger(0);

        Runnable acceptTask1 = () -> {
            readyLatch.countDown();
            try {
                startLatch.await();
                swapRequestService.acceptRequest(reqFromA.getId(), sellerB.getId());
                successCount.incrementAndGet();
            } catch (IllegalStateException conflict) {
                conflictCount.incrementAndGet();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        };

        Runnable acceptTask2 = () -> {
            readyLatch.countDown();
            try {
                startLatch.await();
                swapRequestService.acceptRequest(reqFromC.getId(), sellerB.getId());
                successCount.incrementAndGet();
            } catch (IllegalStateException conflict) {
                conflictCount.incrementAndGet();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        };

        Future<?> f1 = pool.submit(acceptTask1);
        Future<?> f2 = pool.submit(acceptTask2);

        assertTrue(readyLatch.await(5, TimeUnit.SECONDS));
        startLatch.countDown();

        f1.get(10, TimeUnit.SECONDS);
        f2.get(10, TimeUnit.SECONDS);
        pool.shutdownNow();

        assertEquals("Exactly one concurrent accept must succeed", 1, successCount.get());
        assertEquals("The competing concurrent accept must fail with IllegalStateException", 1, conflictCount.get());
        assertEquals("Target book must be RESERVED", "RESERVED", bookService.getBookById(targetBookB.getId()).getStatus());
    }
}
