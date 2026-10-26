package Dao;

import Entity.Book;
import Util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.util.List;

public class BookDAO {

    public void saveBook(Book book) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(book);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }

            throw new RuntimeException("Failed to save book.", e);
        }
    }

    public List<Book> getAllBooks() {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery(
                            "SELECT b FROM Book b " +
                            "LEFT JOIN FETCH b.category " +
                            "LEFT JOIN FETCH b.seller " +
                            "ORDER BY b.id DESC",
                            Book.class
                    )
                    .getResultList();

        } catch (Exception e) {
            throw new RuntimeException("Failed to retrieve books.", e);
        }
    }

    public Book getBookById(Long id) {
        if (id == null) {
            return null;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery(
                            "SELECT b FROM Book b " +
                            "LEFT JOIN FETCH b.category " +
                            "LEFT JOIN FETCH b.seller " +
                            "WHERE b.id = :id",
                            Book.class
                    )
                    .setParameter("id", id)
                    .uniqueResultOptional()
                    .orElse(null);

        } catch (Exception e) {
            throw new RuntimeException("Failed to retrieve book with ID: " + id, e);
        }
    }

    public List<Book> getBooksBySellerId(Long sellerId) {
        if (sellerId == null) {
            return List.of();
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery(
                            "SELECT b FROM Book b " +
                            "LEFT JOIN FETCH b.category " +
                            "LEFT JOIN FETCH b.seller " +
                            "WHERE b.seller.id = :sellerId " +
                            "ORDER BY b.id DESC",
                            Book.class
                    )
                    .setParameter("sellerId", sellerId)
                    .getResultList();

        } catch (Exception e) {
            throw new RuntimeException("Failed to retrieve books for seller ID: " + sellerId, e);
        }
    }

    public List<Book> searchAndFilterBooks(String keyword,
                                           Long categoryId,
                                           String bookCondition,
                                           String status) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            StringBuilder hql = new StringBuilder(
                    "SELECT b FROM Book b " +
                    "LEFT JOIN FETCH b.category " +
                    "LEFT JOIN FETCH b.seller " +
                    "WHERE 1=1"
            );

            boolean hasKeyword = keyword != null && !keyword.isBlank();
            boolean hasCondition = bookCondition != null && !bookCondition.isBlank();
            boolean hasStatus = status != null && !status.isBlank();

            if (hasKeyword) {
                hql.append(" AND (LOWER(b.title) LIKE :keyword OR LOWER(COALESCE(b.author, '')) LIKE :keyword)");
            }
            if (categoryId != null) {
                hql.append(" AND b.category.id = :categoryId");
            }
            if (hasCondition) {
                hql.append(" AND b.bookCondition = :bookCondition");
            }
            if (hasStatus) {
                hql.append(" AND b.status = :status");
            }

            hql.append(" ORDER BY b.id DESC");

            Query<Book> query = session.createQuery(hql.toString(), Book.class);

            if (hasKeyword) {
                query.setParameter("keyword", "%" + keyword.trim().toLowerCase() + "%");
            }
            if (categoryId != null) {
                query.setParameter("categoryId", categoryId);
            }
            if (hasCondition) {
                query.setParameter("bookCondition", bookCondition.trim());
            }
            if (hasStatus) {
                query.setParameter("status", status.trim());
            }

            return query.getResultList();

        } catch (Exception e) {
            throw new RuntimeException("Failed to search and filter books.", e);
        }
    }

    public void updateBook(Book book) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(book);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }

            throw new RuntimeException("Failed to update book.", e);
        }
    }

    public void deleteBook(Long id) {
        deleteBookById(id);
    }

    public boolean deleteBookById(Long id) {
        if (id == null) {
            return false;
        }

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Book book = session.get(Book.class, id);

            if (book == null) {
                transaction.commit();
                return false;
            }

            Long activeOrCompletedSwaps = session.createQuery(
                            "SELECT COUNT(r.id) FROM SwapRequest r " +
                            "WHERE (r.offeredBook.id = :bookId OR r.requestedBook.id = :bookId) " +
                            "AND UPPER(r.status) IN ('PENDING', 'ACCEPTED', 'COMPLETED')",
                            Long.class)
                    .setParameter("bookId", id)
                    .uniqueResult();

            if (activeOrCompletedSwaps != null && activeOrCompletedSwaps > 0) {
                throw new IllegalStateException(
                        "Cannot delete this book because it is part of an active or completed swap request.");
            }

            session.createMutationQuery(
                            "DELETE FROM SwapRequest r " +
                            "WHERE (r.offeredBook.id = :bookId OR r.requestedBook.id = :bookId) " +
                            "AND UPPER(r.status) = 'REJECTED'")
                    .setParameter("bookId", id)
                    .executeUpdate();

            session.remove(book);

            transaction.commit();
            return true;

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }

            if (e instanceof IllegalStateException) {
                throw (IllegalStateException) e;
            }

            throw new RuntimeException("Failed to delete book.", e);
        }
    }
}