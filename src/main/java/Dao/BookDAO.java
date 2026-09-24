package Dao;

import com.bookswap.entity.Book;
import com.bookswap.util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class BookDAO {

    public void saveBook(Book book) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(book);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            e.printStackTrace();
        }
    }

    public List<Book> getAllBooks() {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery("FROM Book", Book.class)
                    .getResultList();

        } catch (Exception e) {

            e.printStackTrace();
            return List.of();
        }
    }

    public Book getBookById(Long id) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Book.class, id);

        } catch (Exception e) {

            e.printStackTrace();
            return null;
        }
    }

    public void updateBook(Book book) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(book);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            e.printStackTrace();
        }
    }

    public void deleteBook(Long id) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Book book = session.get(Book.class, id);

            if (book != null) {
                session.remove(book);
            }

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            e.printStackTrace();
        }
    }
}