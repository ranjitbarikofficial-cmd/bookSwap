package Dao;

import Entity.Category;
import Util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class CategoryDAO {

    public void saveCategory(Category category) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(category);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }

            throw new RuntimeException("Failed to save category.", e);
        }
    }

    public List<Category> getAllCategories() {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery("FROM Category c ORDER BY c.name ASC", Category.class)
                    .getResultList();

        } catch (Exception e) {
            throw new RuntimeException("Failed to load categories.", e);
        }
    }

    public Category getCategoryById(Long id) {
        if (id == null) {
            return null;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Category.class, id);

        } catch (Exception e) {
            throw new RuntimeException("Failed to load category with ID: " + id, e);
        }
    }
}