package Dao;

import com.bookswap.entity.Category;
import com.bookswap.util.HibernateUtil;
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

            if (transaction != null) {
                transaction.rollback();
            }

            e.printStackTrace();
        }
    }

    public List<Category> getAllCategories() {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session
                    .createQuery("FROM Category", Category.class)
                    .getResultList();

        } catch (Exception e) {

            e.printStackTrace();
            return List.of();
        }
    }

    public Category getCategoryById(Long id) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Category.class, id);

        } catch (Exception e) {

            e.printStackTrace();
            return null;
        }
    }
}