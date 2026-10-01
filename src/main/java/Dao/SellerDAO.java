package Dao;

import Entity.Seller;
import Util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class SellerDAO {


    public void saveSeller(Seller seller) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(seller);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            e.printStackTrace();
        }
    }


    public Seller getSellerById(Long id) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Seller.class, id);

        } catch (Exception e) {

            e.printStackTrace();
            return null;
        }
    }


    public void updateSeller(Seller seller) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(seller);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            e.printStackTrace();
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

            if (transaction != null) {
                transaction.rollback();
            }

            e.printStackTrace();
        }
    }
}