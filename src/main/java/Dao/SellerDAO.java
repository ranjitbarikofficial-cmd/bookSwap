package Dao;

import Entity.Seller;
import Util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class SellerDAO {

    public void saveSeller(Seller seller) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(seller);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }

            throw new RuntimeException("Failed to save seller.", e);
        }
    }

    public List<Seller> getAllSellers() {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery("FROM Seller s ORDER BY s.name ASC", Seller.class)
                    .getResultList();

        } catch (Exception e) {
            throw new RuntimeException("Failed to load sellers.", e);
        }
    }

    public Seller getSellerById(Long id) {
        if (id == null) {
            return null;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Seller.class, id);

        } catch (Exception e) {
            throw new RuntimeException("Failed to load seller with ID: " + id, e);
        }
    }

    public Seller getSellerByEmail(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery("FROM Seller s WHERE LOWER(s.email) = LOWER(:email)", Seller.class)
                    .setParameter("email", email.trim())
                    .uniqueResultOptional()
                    .orElse(null);

        } catch (Exception e) {
            throw new RuntimeException("Failed to load seller by email.", e);
        }
    }

    public void updateSeller(Seller seller) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(seller);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }

            throw new RuntimeException("Failed to update seller.", e);
        }
    }

    public void deleteSeller(Long id) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Seller seller = session.get(Seller.class, id);

            if (seller != null) {
                session.remove(seller);
            }

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }

            throw new RuntimeException("Failed to delete seller.", e);
        }
    }
}