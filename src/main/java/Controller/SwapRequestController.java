package Controller;

import Entity.Book;
import Entity.Seller;
import Entity.SwapRequest;
import Service.BookService;
import Service.SwapRequestService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.List;
import java.util.stream.Collectors;

public class SwapRequestController extends HttpServlet {

    public static final String CSRF_TOKEN_ATTR = BookController.CSRF_TOKEN_ATTR;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private SwapRequestService swapRequestService;
    private BookService bookService;

    @Override
    public void init() {
        this.swapRequestService = new SwapRequestService();
        this.bookService = new BookService();
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
            case "/swaps/requests", "/swaps/create" ->
                    handleShowSwapRequests(request, response, authenticatedSeller, "all");
            case "/swaps/sent" ->
                    handleShowSwapRequests(request, response, authenticatedSeller, "sent");
            case "/swaps/received" ->
                    handleShowSwapRequests(request, response, authenticatedSeller, "received");
            case "/swaps/history" ->
                    handleShowSwapHistory(request, response, authenticatedSeller);
            default ->
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Requested swap route was not found.");
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
                    "Invalid or missing CSRF token. Please reload the page and try again."
            );
            return;
        }

        if (authenticatedSeller == null || authenticatedSeller.getId() == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            request.setAttribute("authRequired", true);
            request.setAttribute("error", "You must be signed in as an authenticated seller to perform swap operations.");
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
            return;
        }

        switch (path) {
            case "/swaps/create" -> handleCreateSwapRequest(request, response, authenticatedSeller);
            case "/swaps/accept" -> handleRespondToRequest(request, response, authenticatedSeller, true);
            case "/swaps/reject" -> handleRespondToRequest(request, response, authenticatedSeller, false);
            case "/swaps/complete" -> handleCompleteSwapRequest(request, response, authenticatedSeller);
            default -> response.sendError(
                    HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                    "POST is not supported for this route."
            );
        }
    }

    private void handleShowSwapRequests(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Seller authenticatedSeller,
                                        String defaultView)
            throws ServletException, IOException {

        String viewParam = request.getParameter("view");
        String activeTab = (viewParam != null && !viewParam.isBlank())
                ? viewParam.trim().toLowerCase()
                : defaultView;
        request.setAttribute("activeTab", activeTab);

        Long preselectedRequestedBookId = parsePositiveLong(request.getParameter("requestedBookId"));
        if (preselectedRequestedBookId != null) {
            request.setAttribute("preselectedRequestedBookId", preselectedRequestedBookId);
        }

        if (authenticatedSeller == null || authenticatedSeller.getId() == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            request.setAttribute("authRequired", true);
            request.setAttribute("sentRequests", List.of());
            request.setAttribute("receivedRequests", List.of());
            request.setAttribute("myAvailableBooks", List.of());
            request.setAttribute("otherAvailableBooks", List.of());
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
            return;
        }

        try {
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
        } catch (Exception e) {
            log("Failed to load swap requests for seller ID " + authenticatedSeller.getId(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Unable to load swap requests right now.");
            request.setAttribute("sentRequests", List.of());
            request.setAttribute("receivedRequests", List.of());
            request.setAttribute("myAvailableBooks", List.of());
            request.setAttribute("otherAvailableBooks", List.of());
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
        }
    }

    private void handleCreateSwapRequest(HttpServletRequest request,
                                         HttpServletResponse response,
                                         Seller authenticatedSeller)
            throws ServletException, IOException {

        Long offeredBookId = parsePositiveLong(request.getParameter("offeredBookId"));
        Long requestedBookId = parsePositiveLong(request.getParameter("requestedBookId"));

        if (offeredBookId == null || requestedBookId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", "Please select both a valid book to offer and a valid book to request.");
            request.setAttribute("preselectedRequestedBookId", requestedBookId);
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
            return;
        }

        try {
            SwapRequest created = swapRequestService.createRequest(
                    authenticatedSeller.getId(),
                    offeredBookId,
                    requestedBookId
            );

            response.sendRedirect(
                    request.getContextPath() + "/swaps/requests?created=true&requestId=" + created.getId()
            );

        } catch (IllegalArgumentException | IllegalStateException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", e.getMessage());
            request.setAttribute("preselectedOfferedBookId", offeredBookId);
            request.setAttribute("preselectedRequestedBookId", requestedBookId);
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);

        } catch (Exception e) {
            log("Failed to create swap request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "An unexpected error occurred while creating the swap request.");
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
        }
    }

    private void handleRespondToRequest(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Seller authenticatedSeller,
                                        boolean accept)
            throws ServletException, IOException {

        Long requestId = parsePositiveLong(request.getParameter("requestId"));
        if (requestId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", "Invalid or missing swap request ID.");
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
            return;
        }

        try {
            if (accept) {
                swapRequestService.acceptRequest(requestId, authenticatedSeller.getId());
                response.sendRedirect(
                        request.getContextPath() + "/swaps/requests?accepted=true&requestId=" + requestId
                );
            } else {
                swapRequestService.rejectRequest(requestId, authenticatedSeller.getId());
                response.sendRedirect(
                        request.getContextPath() + "/swaps/requests?rejected=true&requestId=" + requestId
                );
            }
        } catch (SecurityException e) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("error", e.getMessage());
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);

        } catch (IllegalArgumentException | IllegalStateException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", e.getMessage());
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);

        } catch (Exception e) {
            log("Failed to respond to swap request ID " + requestId, e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "An unexpected error occurred while processing the swap request.");
            loadSwapRequestsViewData(request, authenticatedSeller.getId());
            ensureCsrfToken(request);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
        }
    }

    private void handleCompleteSwapRequest(HttpServletRequest request,
                                           HttpServletResponse response,
                                           Seller authenticatedSeller)
            throws ServletException, IOException {

        Long requestId = parsePositiveLong(request.getParameter("requestId"));
        String source = request.getParameter("source");
        boolean fromHistory = "history".equalsIgnoreCase(source);

        if (requestId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", "Invalid or missing swap request ID.");
            if (fromHistory) {
                request.setAttribute("historyRequests", swapRequestService.getSwapHistory(authenticatedSeller.getId()));
                ensureCsrfToken(request);
                request.getRequestDispatcher("/Seller/swap-history.jsp").forward(request, response);
            } else {
                loadSwapRequestsViewData(request, authenticatedSeller.getId());
                ensureCsrfToken(request);
                request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
            }
            return;
        }

        try {
            swapRequestService.completeRequest(requestId, authenticatedSeller.getId());
            if (fromHistory) {
                response.sendRedirect(
                        request.getContextPath() + "/swaps/history?completed=true&requestId=" + requestId
                );
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/swaps/requests?completed=true&requestId=" + requestId
                );
            }
        } catch (SecurityException e) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("error", e.getMessage());
            forwardCompletionError(request, response, authenticatedSeller.getId(), fromHistory);

        } catch (IllegalArgumentException | IllegalStateException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", e.getMessage());
            forwardCompletionError(request, response, authenticatedSeller.getId(), fromHistory);

        } catch (Exception e) {
            log("Failed to complete swap request ID " + requestId, e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "An unexpected error occurred while completing the swap.");
            forwardCompletionError(request, response, authenticatedSeller.getId(), fromHistory);
        }
    }

    private void forwardCompletionError(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Long sellerId,
                                        boolean fromHistory)
            throws ServletException, IOException {
        ensureCsrfToken(request);
        if (fromHistory) {
            request.setAttribute("historyRequests", swapRequestService.getSwapHistory(sellerId));
            request.getRequestDispatcher("/Seller/swap-history.jsp").forward(request, response);
        } else {
            loadSwapRequestsViewData(request, sellerId);
            request.getRequestDispatcher("/Seller/swap-requests.jsp").forward(request, response);
        }
    }

    private void handleShowSwapHistory(HttpServletRequest request,
                                       HttpServletResponse response,
                                       Seller authenticatedSeller)
            throws ServletException, IOException {

        if (authenticatedSeller == null || authenticatedSeller.getId() == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            request.setAttribute("authRequired", true);
            request.setAttribute("historyRequests", List.of());
            request.getRequestDispatcher("/Seller/swap-history.jsp").forward(request, response);
            return;
        }

        try {
            List<SwapRequest> history = swapRequestService.getSwapHistory(authenticatedSeller.getId());
            request.setAttribute("historyRequests", history);
            request.getRequestDispatcher("/Seller/swap-history.jsp").forward(request, response);
        } catch (Exception e) {
            log("Failed to load swap history for seller ID " + authenticatedSeller.getId(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Unable to load swap history right now.");
            request.setAttribute("historyRequests", List.of());
            request.getRequestDispatcher("/Seller/swap-history.jsp").forward(request, response);
        }
    }

    private void loadSwapRequestsViewData(HttpServletRequest request, Long sellerId) {
        List<SwapRequest> sentRequests = swapRequestService.getSentRequests(sellerId);
        List<SwapRequest> receivedRequests = swapRequestService.getReceivedRequests(sellerId);

        List<Book> allAvailableBooks = bookService.searchAndFilterBooks(null, null, null, "AVAILABLE");
        List<Book> myAvailableBooks = allAvailableBooks.stream()
                .filter(b -> b.getSeller() != null && sellerId.equals(b.getSeller().getId()))
                .collect(Collectors.toList());
        List<Book> otherAvailableBooks = allAvailableBooks.stream()
                .filter(b -> b.getSeller() != null && !sellerId.equals(b.getSeller().getId()))
                .collect(Collectors.toList());

        request.setAttribute("sentRequests", sentRequests);
        request.setAttribute("receivedRequests", receivedRequests);
        request.setAttribute("myAvailableBooks", myAvailableBooks);
        request.setAttribute("otherAvailableBooks", otherAvailableBooks);
    }


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
