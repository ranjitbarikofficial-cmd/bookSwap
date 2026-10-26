package Controller;

import Entity.Book;
import Entity.Category;
import Entity.Seller;
import Service.BookService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.List;

public class BookController extends HttpServlet {

    public static final String CSRF_TOKEN_ATTR = "csrfToken";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private BookService bookService;

    @Override
    public void init() {
        bookService = new BookService();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();
        Seller authenticatedSeller = resolveAuthenticatedSeller(request);
        request.setAttribute("authenticatedSeller", authenticatedSeller);
        ensureCsrfToken(request);

        switch (path) {
            case "/books/add" -> handleShowAddForm(request, response);
            case "/books/list" -> handleListBooks(request, response);
            case "/books/details" -> handleBookDetails(request, response, authenticatedSeller);
            case "/books/edit" -> handleShowEditForm(request, response, authenticatedSeller);
            case "/books/my-books" -> handleMyBooks(request, response, authenticatedSeller);
            case "/books/delete" -> handleDeleteGetRedirect(request, response);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND, "Requested book route was not found.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();
        Seller authenticatedSeller = resolveAuthenticatedSeller(request);
        request.setAttribute("authenticatedSeller", authenticatedSeller);

        if (!isValidCsrfToken(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid or missing CSRF token. Please reload the form and try again."
            );
            return;
        }

        switch (path) {
            case "/books/add" -> handleCreateBook(request, response, authenticatedSeller);
            case "/books/edit" -> handleUpdateBook(request, response, authenticatedSeller);
            case "/books/delete" -> handleDeleteBook(request, response, authenticatedSeller);
            default -> response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "POST is not supported for this route.");
        }
    }

    private void handleShowAddForm(HttpServletRequest request,
                                   HttpServletResponse response)
            throws ServletException, IOException {

        loadFormData(request);
        request.getRequestDispatcher("/Seller/add-book.jsp").forward(request, response);
    }

    private void handleCreateBook(HttpServletRequest request,
                                  HttpServletResponse response,
                                  Seller authenticatedSeller)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String description = request.getParameter("description");
        String bookCondition = request.getParameter("bookCondition");
        String location = request.getParameter("location");
        String categoryIdParam = request.getParameter("categoryId");
        String sellerIdParam = request.getParameter("sellerId");

        Long categoryId = parsePositiveLong(categoryIdParam);
        if (categoryId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", "Please select a valid category.");
            loadFormData(request);
            request.getRequestDispatcher("/Seller/add-book.jsp").forward(request, response);
            return;
        }

        Long effectiveSellerId;
        if (authenticatedSeller != null && authenticatedSeller.getId() != null) {
            effectiveSellerId = authenticatedSeller.getId();
        } else {
            effectiveSellerId = parsePositiveLong(sellerIdParam);
        }

        if (effectiveSellerId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", "Please select a valid seller.");
            loadFormData(request);
            request.getRequestDispatcher("/Seller/add-book.jsp").forward(request, response);
            return;
        }

        try {
            Book created = bookService.createBook(
                    title,
                    author,
                    description,
                    bookCondition,
                    location,
                    categoryId,
                    effectiveSellerId
            );

            request.getSession(true).setAttribute("sellerId", effectiveSellerId);

            response.sendRedirect(
                    request.getContextPath() + "/books/list?added=true&bookId=" + created.getId()
            );

        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", e.getMessage());
            loadFormData(request);
            request.getRequestDispatcher("/Seller/add-book.jsp").forward(request, response);
        } catch (Exception e) {
            log("Failed to save book", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "An unexpected database error occurred while saving the book. Please try again.");
            loadFormData(request);
            request.getRequestDispatcher("/Seller/add-book.jsp").forward(request, response);
        }
    }

    private void handleListBooks(HttpServletRequest request,
                                 HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("q");
        if (keyword == null || keyword.isBlank()) {
            keyword = request.getParameter("keyword");
        }
        String categoryIdParam = request.getParameter("categoryId");
        String condition = request.getParameter("condition");
        if (condition == null || condition.isBlank()) {
            condition = request.getParameter("bookCondition");
        }
        String status = request.getParameter("status");

        Long categoryId = null;
        if (categoryIdParam != null && !categoryIdParam.isBlank()) {
            categoryId = parsePositiveLong(categoryIdParam);
            if (categoryId == null) {
                request.setAttribute("filterWarning", "Ignored invalid category filter value.");
            }
        }

        try {
            List<Category> categories = bookService.getAllCategories();
            List<Book> books = bookService.searchAndFilterBooks(keyword, categoryId, condition, status);

            request.setAttribute("categories", categories);
            request.setAttribute("books", books);
            request.setAttribute("searchKeyword", keyword != null ? keyword.trim() : "");
            request.setAttribute("selectedCategoryId", categoryId);
            request.setAttribute("selectedCondition", condition != null ? condition.trim().toUpperCase() : "");
            request.setAttribute("selectedStatus", status != null ? status.trim().toUpperCase() : "");

            request.getRequestDispatcher("/Seller/book-list.jsp").forward(request, response);

        } catch (Exception e) {
            log("Failed to list books", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Unable to load books at this time.");
            request.setAttribute("books", List.of());
            request.getRequestDispatcher("/Seller/book-list.jsp").forward(request, response);
        }
    }

    private void handleBookDetails(HttpServletRequest request,
                                   HttpServletResponse response,
                                   Seller authenticatedSeller)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        Long bookId = parsePositiveLong(idParam);

        if (bookId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", "Invalid or missing book ID.");
            request.getRequestDispatcher("/Seller/book-details.jsp").forward(request, response);
            return;
        }

        try {
            Book book = bookService.getBookById(bookId);
            if (book == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                request.setAttribute("notFound", true);
                request.setAttribute("error", "The requested book (ID #" + bookId + ") was not found.");
                request.getRequestDispatcher("/Seller/book-details.jsp").forward(request, response);
                return;
            }

            boolean isOwner = (authenticatedSeller == null)
                    || bookService.canSellerModifyBook(book, authenticatedSeller.getId());

            request.setAttribute("book", book);
            request.setAttribute("isOwner", isOwner);
            request.getRequestDispatcher("/Seller/book-details.jsp").forward(request, response);

        } catch (Exception e) {
            log("Failed to load book details for ID " + bookId, e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Unable to load book details right now.");
            request.getRequestDispatcher("/Seller/book-details.jsp").forward(request, response);
        }
    }

    private void handleShowEditForm(HttpServletRequest request,
                                    HttpServletResponse response,
                                    Seller authenticatedSeller)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        Long bookId = parsePositiveLong(idParam);

        if (bookId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", "Invalid or missing book ID.");
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);
            return;
        }

        Book book = bookService.getBookById(bookId);
        if (book == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            request.setAttribute("notFound", true);
            request.setAttribute("error", "Book not found (ID #" + bookId + ").");
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);
            return;
        }

        if (authenticatedSeller != null && !bookService.canSellerModifyBook(book, authenticatedSeller.getId())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("forbidden", true);
            request.setAttribute("error", "Access denied: You can only edit books listed by your own seller account.");
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);
            return;
        }

        request.setAttribute("book", book);
        request.setAttribute("categories", bookService.getAllCategories());
        request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);
    }

    private void handleUpdateBook(HttpServletRequest request,
                                  HttpServletResponse response,
                                  Seller authenticatedSeller)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        Long bookId = parsePositiveLong(idParam);

        if (bookId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing book ID.");
            return;
        }

        Book existingBook = bookService.getBookById(bookId);
        if (existingBook == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            request.setAttribute("notFound", true);
            request.setAttribute("error", "Book not found (ID #" + bookId + ").");
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);
            return;
        }

        Long effectiveSellerId = (authenticatedSeller != null)
                ? authenticatedSeller.getId()
                : (existingBook.getSeller() != null ? existingBook.getSeller().getId() : null);

        if (authenticatedSeller != null && !bookService.canSellerModifyBook(existingBook, authenticatedSeller.getId())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("forbidden", true);
            request.setAttribute("error", "Access denied: You cannot modify another seller's book.");
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);
            return;
        }

        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String description = request.getParameter("description");
        String bookCondition = request.getParameter("bookCondition");
        String location = request.getParameter("location");
        String status = request.getParameter("status");
        String categoryIdParam = request.getParameter("categoryId");

        Long categoryId = parsePositiveLong(categoryIdParam);

        try {
            if (categoryId == null) {
                throw new IllegalArgumentException("Please select a valid category.");
            }

            bookService.updateBookForSeller(
                    bookId,
                    title,
                    author,
                    description,
                    bookCondition,
                    location,
                    status,
                    categoryId,
                    effectiveSellerId
            );

            response.sendRedirect(
                    request.getContextPath() + "/books/details?id=" + bookId + "&updated=true"
            );

        } catch (SecurityException e) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("forbidden", true);
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);

        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", e.getMessage());

            Book draft = new Book();
            draft.setId(existingBook.getId());
            draft.setTitle(title);
            draft.setAuthor(author);
            draft.setDescription(description);
            draft.setBookCondition(bookCondition);
            draft.setLocation(location);
            draft.setStatus(status != null && !status.isBlank() ? status : existingBook.getStatus());
            draft.setSeller(existingBook.getSeller());
            if (categoryId != null) {
                Category selectedCat = bookService.getCategoryById(categoryId);
                draft.setCategory(selectedCat != null ? selectedCat : existingBook.getCategory());
            } else {
                draft.setCategory(existingBook.getCategory());
            }

            request.setAttribute("book", draft);
            request.setAttribute("categories", bookService.getAllCategories());
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);

        } catch (Exception e) {
            log("Failed to update book ID " + bookId, e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "An unexpected database error occurred while updating the book.");
            request.setAttribute("book", existingBook);
            request.setAttribute("categories", bookService.getAllCategories());
            request.getRequestDispatcher("/Seller/edit-book.jsp").forward(request, response);
        }
    }

    private void handleDeleteGetRedirect(HttpServletRequest request,
                                         HttpServletResponse response)
            throws IOException {

        Long bookId = parsePositiveLong(request.getParameter("id"));
        if (bookId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid book ID.");
            return;
        }
        response.sendRedirect(
                request.getContextPath() + "/books/details?id=" + bookId + "&confirmDelete=true"
        );
    }

    private void handleDeleteBook(HttpServletRequest request,
                                  HttpServletResponse response,
                                  Seller authenticatedSeller)
            throws ServletException, IOException {

        Long bookId = parsePositiveLong(request.getParameter("id"));
        if (bookId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing book ID.");
            return;
        }

        Book existingBook = bookService.getBookById(bookId);
        if (existingBook == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Book not found.");
            return;
        }

        Long effectiveSellerId = (authenticatedSeller != null)
                ? authenticatedSeller.getId()
                : (existingBook.getSeller() != null ? existingBook.getSeller().getId() : null);

        try {
            bookService.deleteBookForSeller(bookId, effectiveSellerId);
            String source = request.getParameter("source");
            if ("list".equalsIgnoreCase(source) || authenticatedSeller == null) {
                response.sendRedirect(request.getContextPath() + "/books/list?deleted=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/books/my-books?deleted=true");
            }
        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            log("Failed to delete book ID " + bookId, e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to delete book because of a database error or related swap records."
            );
        }
    }

    private void handleMyBooks(HttpServletRequest request,
                               HttpServletResponse response,
                               Seller authenticatedSeller)
            throws ServletException, IOException {

        if (authenticatedSeller == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            request.setAttribute("authRequired", true);
            request.setAttribute("books", List.of());
            request.getRequestDispatcher("/Seller/my-books.jsp").forward(request, response);
            return;
        }

        try {
            List<Book> sellerBooks = bookService.getBooksBySellerId(authenticatedSeller.getId());
            request.setAttribute("books", sellerBooks);
            request.getRequestDispatcher("/Seller/my-books.jsp").forward(request, response);
        } catch (Exception e) {
            log("Failed to load seller books for seller ID " + authenticatedSeller.getId(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Unable to load your books at this time.");
            request.setAttribute("books", List.of());
            request.getRequestDispatcher("/Seller/my-books.jsp").forward(request, response);
        }
    }

    private void loadFormData(HttpServletRequest request) {
        List<Category> categories = bookService.getAllCategories();
        List<Seller> sellers = bookService.getAllSellers();

        request.setAttribute("categories", categories);
        request.setAttribute("sellers", sellers);
    }

    /**
     * Resolves the authenticated Seller strictly from the server-side HttpSession.
     * Supports:
     * 1. Session attribute "seller" or "loggedInSeller" of type Entity.Seller
     * 2. Session attribute "sellerId" (Long / Integer / numeric String)
     * 3. Rahul's Authentication Module session attributes ("email", "id", "name", "phone")
     * Never trusts any request parameter for seller ownership!
     */
    private Seller resolveAuthenticatedSeller(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object sellerObj = session.getAttribute("seller");
        if (sellerObj == null) {
            sellerObj = session.getAttribute("loggedInSeller");
        }
        if (sellerObj instanceof Seller sessionSeller && sessionSeller.getId() != null) {
            Seller fresh = bookService.getSellerById(sessionSeller.getId());
            if (fresh != null) {
                return fresh;
            }
        }

        Long explicitSellerId = extractLongAttribute(session.getAttribute("sellerId"));
        if (explicitSellerId != null) {
            Seller byId = bookService.getSellerById(explicitSellerId);
            if (byId != null) {
                return byId;
            }
        }

        Object emailObj = session.getAttribute("email");
        Object nameObj = session.getAttribute("name");
        Object phoneObj = session.getAttribute("phone");
        Long userId = extractLongAttribute(session.getAttribute("id"));
        if (userId == null) {
            userId = extractLongAttribute(session.getAttribute("userId"));
        }

        String email = (emailObj instanceof String s && !s.isBlank()) ? s.trim() : null;
        String name = (nameObj instanceof String s && !s.isBlank()) ? s.trim() : null;
        String phone = (phoneObj instanceof String s && !s.isBlank()) ? s.trim() : null;

        if (email != null || userId != null) {
            Seller synced = bookService.resolveOrSyncAuthenticatedSeller(userId, email, name, phone, null);
            if (synced != null) {
                session.setAttribute("sellerId", synced.getId());
                return synced;
            }
        }

        return null;
    }

    private Long extractLongAttribute(Object attr) {
        if (attr instanceof Long l && l > 0) {
            return l;
        }
        if (attr instanceof Integer i && i > 0) {
            return i.longValue();
        }
        if (attr instanceof String s) {
            return parsePositiveLong(s);
        }
        return null;
    }

    private Long parsePositiveLong(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            long parsed = Long.parseLong(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String ensureCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Object existing = session.getAttribute(CSRF_TOKEN_ATTR);
        if (existing instanceof String token && !token.isBlank()) {
            request.setAttribute(CSRF_TOKEN_ATTR, token);
            return token;
        }
        byte[] bytes = new byte[24];
        SECURE_RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(CSRF_TOKEN_ATTR, token);
        request.setAttribute(CSRF_TOKEN_ATTR, token);
        return token;
    }

    private boolean isValidCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object sessionToken = session.getAttribute(CSRF_TOKEN_ATTR);
        if (!(sessionToken instanceof String expected) || expected.isBlank()) {
            return false;
        }
        String provided = request.getParameter(CSRF_TOKEN_ATTR);
        return provided != null && expected.equals(provided);
    }
}
