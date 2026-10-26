package Dao;

import Entity.Book;
import Entity.SwapRequest;
import Util.HibernateUtil;
import jakarta.persistence.LockModeType;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class SwapRequestDAO {

    /**
     * Save a new swap request.
     */
    public void save(SwapRequest request) {
        if (request == null) {
            throw new IllegalArgumentException(
                    "Swap request cannot be null.");
        }

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(request);

            transaction.commit();

        } catch (Exception e) {
            rollback(transaction, e);

            throw new RuntimeException(
                    "Failed to save swap request.", e);
        }
    }

    /**
     * Check whether a duplicate pending or accepted request already exists for the same pair of books.
     */
    public boolean existsActiveRequestBetweenBooks(Long offeredBookId, Long requestedBookId) {
        if (offeredBookId == null || requestedBookId == null) {
            return false;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                            "SELECT COUNT(r.id) FROM SwapRequest r " +
                            "WHERE ((r.offeredBook.id = :offeredId AND r.requestedBook.id = :requestedId) " +
                            "   OR  (r.offeredBook.id = :requestedId AND r.requestedBook.id = :offeredId)) " +
                            "AND UPPER(r.status) IN ('PENDING', 'ACCEPTED')",
                            Long.class)
                    .setParameter("offeredId", offeredBookId)
                    .setParameter("requestedId", requestedBookId)
                    .uniqueResult();

            return count != null && count > 0;

        } catch (Exception e) {
            throw new RuntimeException("Failed to check existing swap requests.", e);
        }
    }

    /**
     * Retrieve a swap request by ID.
     */
    public SwapRequest getById(Long id) {
        if (id == null || id <= 0) {
            return null;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                            "SELECT r FROM SwapRequest r " +
                                    "JOIN FETCH r.requester " +
                                    "JOIN FETCH r.owner " +
                                    "JOIN FETCH r.offeredBook ob " +
                                    "LEFT JOIN FETCH ob.category " +
                                    "JOIN FETCH r.requestedBook rb " +
                                    "LEFT JOIN FETCH rb.category " +
                                    "WHERE r.id = :id",
                            SwapRequest.class)
                    .setParameter("id", id)
                    .uniqueResult();

        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to retrieve swap request.", e);
        }
    }

    /**
     * Retrieve requests sent by a seller.
     */
    public List<SwapRequest> getRequestsByRequester(Long sellerId) {
        if (sellerId == null || sellerId <= 0) {
            return List.of();
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                            "SELECT r FROM SwapRequest r " +
                                    "JOIN FETCH r.requester " +
                                    "JOIN FETCH r.owner " +
                                    "JOIN FETCH r.offeredBook ob " +
                                    "LEFT JOIN FETCH ob.category " +
                                    "JOIN FETCH r.requestedBook rb " +
                                    "LEFT JOIN FETCH rb.category " +
                                    "WHERE r.requester.id = :sellerId " +
                                    "ORDER BY r.createdAt DESC, r.id DESC",
                            SwapRequest.class)
                    .setParameter("sellerId", sellerId)
                    .getResultList();

        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to retrieve sent swap requests.", e);
        }
    }

    /**
     * Retrieve requests received by a seller.
     */
    public List<SwapRequest> getRequestsByOwner(Long sellerId) {
        if (sellerId == null || sellerId <= 0) {
            return List.of();
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                            "SELECT r FROM SwapRequest r " +
                                    "JOIN FETCH r.requester " +
                                    "JOIN FETCH r.owner " +
                                    "JOIN FETCH r.offeredBook ob " +
                                    "LEFT JOIN FETCH ob.category " +
                                    "JOIN FETCH r.requestedBook rb " +
                                    "LEFT JOIN FETCH rb.category " +
                                    "WHERE r.owner.id = :sellerId " +
                                    "ORDER BY r.createdAt DESC, r.id DESC",
                            SwapRequest.class)
                    .setParameter("sellerId", sellerId)
                    .getResultList();

        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to retrieve received swap requests.", e);
        }
    }

    /**
     * Retrieve swap history (processed requests: ACCEPTED, COMPLETED, REJECTED) involving a seller.
     */
    public List<SwapRequest> getSwapHistoryForSeller(Long sellerId) {
        if (sellerId == null || sellerId <= 0) {
            return List.of();
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                            "SELECT r FROM SwapRequest r " +
                                    "JOIN FETCH r.requester " +
                                    "JOIN FETCH r.owner " +
                                    "JOIN FETCH r.offeredBook ob " +
                                    "LEFT JOIN FETCH ob.category " +
                                    "JOIN FETCH r.requestedBook rb " +
                                    "LEFT JOIN FETCH rb.category " +
                                    "WHERE (r.requester.id = :sellerId OR r.owner.id = :sellerId) " +
                                    "AND UPPER(r.status) IN ('ACCEPTED', 'COMPLETED', 'REJECTED') " +
                                    "ORDER BY COALESCE(r.updatedAt, r.createdAt) DESC, r.id DESC",
                            SwapRequest.class)
                    .setParameter("sellerId", sellerId)
                    .getResultList();

        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to retrieve swap history.", e);
        }
    }

    /**
     * Accept or reject a request in a single database transaction.
     */
    public void respondToRequest(
            Long requestId,
            Long ownerId,
            boolean accept) {

        if (requestId == null || requestId <= 0
                || ownerId == null || ownerId <= 0) {
            throw new IllegalArgumentException(
                    "Valid request and owner IDs are required.");
        }

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            SwapRequest request = session.find(
                    SwapRequest.class,
                    requestId,
                    LockModeType.PESSIMISTIC_WRITE
            );

            if (request == null) {
                throw new IllegalArgumentException(
                        "Swap request not found.");
            }

            if (request.getOwner() == null
                    || !ownerId.equals(request.getOwner().getId())) {
                throw new SecurityException(
                        "You are not authorized to respond to this request.");
            }

            if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
                throw new IllegalStateException(
                        "This request has already been processed.");
            }

            if (accept) {
                Long offeredId = request.getOfferedBook().getId();
                Long requestedId = request.getRequestedBook().getId();

                // Lock books in ascending ID order to avoid deadlocks under concurrent acceptance
                Long firstLockId = Math.min(offeredId, requestedId);
                Long secondLockId = Math.max(offeredId, requestedId);

                Book firstLocked = session.find(Book.class, firstLockId, LockModeType.PESSIMISTIC_WRITE);
                Book secondLocked = session.find(Book.class, secondLockId, LockModeType.PESSIMISTIC_WRITE);

                Book offeredBook = offeredId.equals(firstLockId) ? firstLocked : secondLocked;
                Book requestedBook = requestedId.equals(firstLockId) ? firstLocked : secondLocked;

                if (offeredBook == null || requestedBook == null) {
                    throw new IllegalStateException(
                            "One or both books no longer exist.");
                }

                if (!"AVAILABLE".equalsIgnoreCase(
                        offeredBook.getStatus())
                        || !"AVAILABLE".equalsIgnoreCase(
                        requestedBook.getStatus())) {
                    throw new IllegalStateException(
                            "One or both books are no longer available.");
                }

                if (offeredBook.getSeller() == null
                        || requestedBook.getSeller() == null
                        || !request.getRequester().getId().equals(
                        offeredBook.getSeller().getId())
                        || !request.getOwner().getId().equals(
                        requestedBook.getSeller().getId())) {
                    throw new IllegalStateException(
                            "Book ownership has changed. Request cannot be accepted.");
                }

                offeredBook.setStatus("RESERVED");
                requestedBook.setStatus("RESERVED");
                request.setStatus("ACCEPTED");

            } else {
                request.setStatus("REJECTED");
            }

            session.flush();
            transaction.commit();

        } catch (Exception e) {
            rollback(transaction, e);

            if (e instanceof IllegalArgumentException
                    || e instanceof SecurityException
                    || e instanceof IllegalStateException) {
                throw (RuntimeException) e;
            }

            throw new RuntimeException(
                    "Failed to respond to swap request.", e);
        }
    }

    /**
     * Complete an ACCEPTED swap request in a single transaction, marking both reserved books as SWAPPED.
     */
    public void completeRequest(Long requestId, Long actorSellerId) {
        if (requestId == null || requestId <= 0
                || actorSellerId == null || actorSellerId <= 0) {
            throw new IllegalArgumentException(
                    "Valid request and seller IDs are required.");
        }

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            SwapRequest request = session.find(
                    SwapRequest.class,
                    requestId,
                    LockModeType.PESSIMISTIC_WRITE
            );

            if (request == null) {
                throw new IllegalArgumentException("Swap request not found.");
            }

            boolean isOwner = request.getOwner() != null && actorSellerId.equals(request.getOwner().getId());
            boolean isRequester = request.getRequester() != null && actorSellerId.equals(request.getRequester().getId());
            if (!isOwner && !isRequester) {
                throw new SecurityException("You are not authorized to complete this swap request.");
            }

            if (!"ACCEPTED".equalsIgnoreCase(request.getStatus())) {
                throw new IllegalStateException("Only an ACCEPTED swap request can be completed.");
            }

            Long offeredId = request.getOfferedBook().getId();
            Long requestedId = request.getRequestedBook().getId();

            Long firstLockId = Math.min(offeredId, requestedId);
            Long secondLockId = Math.max(offeredId, requestedId);

            Book firstLocked = session.find(Book.class, firstLockId, LockModeType.PESSIMISTIC_WRITE);
            Book secondLocked = session.find(Book.class, secondLockId, LockModeType.PESSIMISTIC_WRITE);

            Book offeredBook = offeredId.equals(firstLockId) ? firstLocked : secondLocked;
            Book requestedBook = requestedId.equals(firstLockId) ? firstLocked : secondLocked;

            if (offeredBook == null || requestedBook == null) {
                throw new IllegalStateException("One or both books no longer exist.");
            }

            if (!"RESERVED".equalsIgnoreCase(offeredBook.getStatus())
                    || !"RESERVED".equalsIgnoreCase(requestedBook.getStatus())) {
                throw new IllegalStateException("Both books must be RESERVED before completing the swap.");
            }

            offeredBook.setStatus("SWAPPED");
            requestedBook.setStatus("SWAPPED");
            request.setStatus("COMPLETED");

            session.flush();
            transaction.commit();

        } catch (Exception e) {
            rollback(transaction, e);

            if (e instanceof IllegalArgumentException
                    || e instanceof SecurityException
                    || e instanceof IllegalStateException) {
                throw (RuntimeException) e;
            }

            throw new RuntimeException("Failed to complete swap request.", e);
        }
    }

    private void rollback(Transaction transaction, Exception original) {
        if (transaction != null && transaction.isActive()) {
            try {
                transaction.rollback();
            } catch (Exception rollbackException) {
                original.addSuppressed(rollbackException);
            }
        }
    }
}
