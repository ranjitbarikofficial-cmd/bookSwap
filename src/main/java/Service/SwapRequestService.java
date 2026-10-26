
package Service;

import Dao.BookDAO;
import Dao.SwapRequestDAO;
import Entity.Book;
import Entity.Seller;
import Entity.SwapRequest;

import java.util.List;

public class SwapRequestService {

    private final SwapRequestDAO swapRequestDAO;
    private final BookDAO bookDAO;

    public SwapRequestService() {
        this.swapRequestDAO = new SwapRequestDAO();
        this.bookDAO = new BookDAO();
    }

    /**
     * Create a swap request between two sellers.
     */
    public SwapRequest createRequest(
            Long requesterId,
            Long offeredBookId,
            Long requestedBookId) {

        if (requesterId == null
                || offeredBookId == null
                || requestedBookId == null) {
            throw new IllegalArgumentException(
                    "Seller and book IDs are required.");
        }

        if (offeredBookId.equals(requestedBookId)) {
            throw new IllegalArgumentException(
                    "You cannot swap a book with itself.");
        }

        Book offeredBook = bookDAO.getBookById(offeredBookId);
        Book requestedBook = bookDAO.getBookById(requestedBookId);

        if (offeredBook == null || requestedBook == null) {
            throw new IllegalArgumentException(
                    "One or both books could not be found.");
        }

        Seller requester = offeredBook.getSeller();
        Seller owner = requestedBook.getSeller();

        if (requester == null || owner == null) {
            throw new IllegalArgumentException(
                    "Both books must have an owner.");
        }

        if (requester.getId() == null
                || !requesterId.equals(requester.getId())) {
            throw new IllegalArgumentException(
                    "You can only offer a book that you own.");
        }

        if (owner.getId() == null
                || requester.getId().equals(owner.getId())) {
            throw new IllegalArgumentException(
                    "You cannot request a book from yourself.");
        }

        if (!"AVAILABLE".equalsIgnoreCase(offeredBook.getStatus())
                || !"AVAILABLE".equalsIgnoreCase(
                requestedBook.getStatus())) {
            throw new IllegalArgumentException(
                    "Both books must be available for swapping.");
        }

        if (swapRequestDAO.existsActiveRequestBetweenBooks(offeredBookId, requestedBookId)) {
            throw new IllegalStateException(
                    "A pending or active swap request already exists for these books.");
        }

        SwapRequest request = new SwapRequest();
        request.setRequester(requester);
        request.setOwner(owner);
        request.setOfferedBook(offeredBook);
        request.setRequestedBook(requestedBook);
        request.setStatus("PENDING");

        swapRequestDAO.save(request);

        return request;
    }

    /**
     * Retrieve requests sent by a seller.
     */
    public List<SwapRequest> getSentRequests(Long sellerId) {
        validateSellerId(sellerId);
        return swapRequestDAO.getRequestsByRequester(sellerId);
    }

    /**
     * Retrieve requests received by a seller.
     */
    public List<SwapRequest> getReceivedRequests(Long sellerId) {
        validateSellerId(sellerId);
        return swapRequestDAO.getRequestsByOwner(sellerId);
    }

    /**
     * Retrieve swap history (ACCEPTED, COMPLETED, REJECTED) involving a seller.
     */
    public List<SwapRequest> getSwapHistory(Long sellerId) {
        validateSellerId(sellerId);
        return swapRequestDAO.getSwapHistoryForSeller(sellerId);
    }

    /**
     * Retrieve a request by its ID.
     */
    public SwapRequest getRequestById(Long requestId) {
        if (requestId == null || requestId <= 0) {
            throw new IllegalArgumentException(
                    "A valid request ID is required.");
        }

        return swapRequestDAO.getById(requestId);
    }

    /**
     * Accept a pending swap request.
     */
    public void acceptRequest(Long requestId, Long ownerId) {
        validateResponse(requestId, ownerId);
        swapRequestDAO.respondToRequest(requestId, ownerId, true);
    }

    /**
     * Reject a pending swap request.
     */
    public void rejectRequest(Long requestId, Long ownerId) {
        validateResponse(requestId, ownerId);
        swapRequestDAO.respondToRequest(requestId, ownerId, false);
    }

    /**
     * Complete an accepted swap request, marking both reserved books as SWAPPED.
     */
    public void completeRequest(Long requestId, Long actorSellerId) {
        validateResponse(requestId, actorSellerId);
        swapRequestDAO.completeRequest(requestId, actorSellerId);
    }

    private void validateSellerId(Long sellerId) {
        if (sellerId == null || sellerId <= 0) {
            throw new IllegalArgumentException(
                    "A valid seller ID is required.");
        }
    }

    private void validateResponse(Long requestId, Long ownerId) {
        if (requestId == null || requestId <= 0
                || ownerId == null || ownerId <= 0) {
            throw new IllegalArgumentException(
                    "Valid request and seller IDs are required.");
        }
    }
}
