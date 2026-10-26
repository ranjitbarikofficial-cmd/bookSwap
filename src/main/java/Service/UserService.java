package Service;

import Dao.SellerDAO;
import Entity.Role;
import Entity.Seller;
import Entity.Status;
import Entity.User;
import Util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.time.LocalDateTime;
import java.util.List;

public class UserService {

    private static final SellerDAO SELLER_DAO = new SellerDAO();

    public static boolean addUser(User u) {
        if (u == null || u.getEmail() == null || u.getEmail().isBlank()) {
            return false;
        }

        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();

            if (u.getRole() == null) {
                u.setRole(Role.USER);
            }
            if (u.getStatus() == null) {
                u.setStatus(Status.ACTIVE);
            }
            if (u.getCreatedAt() == null) {
                u.setCreatedAt(LocalDateTime.now());
            }

            session.persist(u);
            tx.commit();

            syncSellerProfile(u);
            return true;

        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                try {
                    tx.rollback();
                } catch (Exception ignored) {
                }
            }
            throw new RuntimeException("Failed to register user.", e);
        }
    }

    public static User verify(String email, String password) {
        if (email == null || password == null) {
            return null;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.createQuery(
                            "FROM User u WHERE LOWER(u.email) = :email AND u.password = :password",
                            User.class)
                    .setParameter("email", email.trim().toLowerCase())
                    .setParameter("password", password)
                    .uniqueResultOptional()
                    .orElse(null);

            if (user != null) {
                syncSellerProfile(user);
            }
            return user;

        } catch (Exception e) {
            throw new RuntimeException("Failed to verify user credentials.", e);
        }
    }

    public static User findByid(User u) {
        if (u == null || u.getId() == null) {
            return null;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(User.class, u.getId());
        } catch (Exception e) {
            throw new RuntimeException("Failed to find user by ID.", e);
        }
    }

    public static User updateProfile(User u, String name, String phone) {
        User up = UserService.findByid(u);
        if (up == null || up.getId() == null) {
            return null;
        }

        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();
            up.setName(name);
            up.setPhone(phone);
            User merged = session.merge(up);
            tx.commit();

            syncSellerProfile(merged);
            return merged;

        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                try {
                    tx.rollback();
                } catch (Exception ignored) {
                }
            }
            throw new RuntimeException("Failed to update user profile.", e);
        }
    }

    public static boolean updatepassword(User u, String password) {
        User up = UserService.findByid(u);
        if (up == null || up.getId() == null) {
            return false;
        }

        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();
            up.setPassword(password);
            session.merge(up);
            tx.commit();
            return true;

        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                try {
                    tx.rollback();
                } catch (Exception ignored) {
                }
            }
            throw new RuntimeException("Failed to update user password.", e);
        }
    }

    public static boolean emailExists(String email) {
        if (email == null || email.isBlank()) {
            return false;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                            "SELECT COUNT(u.id) FROM User u WHERE LOWER(u.email) = :email",
                            Long.class)
                    .setParameter("email", email.trim().toLowerCase())
                    .uniqueResult();
            return count != null && count > 0;

        } catch (Exception e) {
            throw new RuntimeException("Failed to check existing email.", e);
        }
    }

    public static List<User> getAlluser() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                            "SELECT u FROM User u WHERE u.role = :role",
                            User.class)
                    .setParameter("role", Role.USER)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Failed to fetch users.", e);
        }
    }

    private static void syncSellerProfile(User u) {
        if (u == null || u.getEmail() == null || u.getEmail().isBlank()) {
            return;
        }
        try {
            Seller existing = SELLER_DAO.getSellerByEmail(u.getEmail().trim());
            if (existing == null) {
                Seller seller = new Seller(
                        u.getName() != null ? u.getName().trim() : u.getEmail().trim(),
                        u.getEmail().trim(),
                        u.getPhone(),
                        null
                );
                SELLER_DAO.saveSeller(seller);
            }
        } catch (Exception ignored) {
        }
    }
}
