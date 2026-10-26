
package Service;

import Entity.Role;
import Entity.Status;
import Entity.User;
import jakarta.persistence.*;

import java.sql.*;
import java.util.List;

public class UserService {

    private static Connection con = null;
    private static EntityManagerFactory emf = null;
    private static EntityManager em = null;
    private static EntityTransaction et = null;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/bookswap",
                    "root",
                    "rahul@2004"
            );
            System.out.println("Database connected successfully");
        } catch (Exception e) {
            System.out.println("Database connection failed!");
            e.printStackTrace();
        }
    }

    static {
        emf = Persistence.createEntityManagerFactory("BookSwap");
        em = emf.createEntityManager();
        et = em.getTransaction();
    }

    public static boolean addUser(User u) {
        try {
            PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO users (name, email, password, phone, role, status) VALUES (?, ?, ?, ?, ?, ?)"
            );

            ps.setString(1, u.getName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassword());
            ps.setString(4, u.getPhone());
            ps.setString(5, u.getRole().name());
            ps.setString(6, u.getStatus().name());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static User verify(String email, String password) {
        try {
            PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM users WHERE email = ? AND password = ?"
            );

            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User u = new User();
                u.setId(rs.getLong("id"));
                u.setName(rs.getString("name"));
                u.setEmail(rs.getString("email"));
                u.setPassword(rs.getString("password"));
                u.setPhone(rs.getString("phone"));
                u.setRole(Role.valueOf(rs.getString("role")));
                u.setStatus(Status.valueOf(rs.getString("status")));

                Timestamp createdAt = rs.getTimestamp("created_at");
                if (createdAt != null) {
                    u.setCreatedAt(createdAt.toLocalDateTime());
                }

                return u;
            }

            return null;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static User findByid(User u) {
        if (u == null || u.getId() == null) {
            return null;
        }

        return em.find(User.class, u.getId());
    }

    public static User updateProfile(User u, String name, String phone) {
        if (u == null || u.getId() == null) {
            return null;
        }

        try {
            et.begin();

            User up = em.find(User.class, u.getId());

            if (up == null) {
                et.rollback();
                return null;
            }

            up.setName(name);
            up.setPhone(phone);

            em.merge(up);
            et.commit();

            return up;
        } catch (Exception e) {
            if (et.isActive()) {
                et.rollback();
            }
            throw new RuntimeException(e);
        }
    }

    public static boolean updatepassword(String email, String password) {
        User u = findByEmail(email);

        if (u == null) {
            return false;
        }

        return updatepassword(u, password);
    }

    public static boolean updatepassword(User u, String password) {
        if (u == null || u.getId() == null) {
            return false;
        }

        try {
            et.begin();

            User up = em.find(User.class, u.getId());

            if (up == null) {
                et.rollback();
                return false;
            }

            up.setPassword(password);
            em.merge(up);
            et.commit();

            return true;
        } catch (Exception e) {
            if (et.isActive()) {
                et.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }

    public static boolean emailExists(String email) {
        try {
            PreparedStatement ps = con.prepareStatement(
                    "SELECT id FROM users WHERE email = ?"
            );

            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static List<User> getAlluser() {
        Query query = em.createQuery(
                "SELECT u FROM User u WHERE u.role = :role"
        );
        query.setParameter("role", Role.USER);
        return query.getResultList();
    }

    public static List<User> getAll() {
        Query query = em.createQuery("SELECT u FROM User u");
        return query.getResultList();
    }

    public static List<User> searchUsers(String keyword) {
        Query query = em.createQuery(
                "SELECT u FROM User u WHERE u.role = :role " +
                        "AND (LOWER(u.name) LIKE :keyword " +
                        "OR LOWER(u.email) LIKE :keyword)"
        );

        query.setParameter("role", Role.USER);
        query.setParameter(
                "keyword",
                "%" + keyword.trim().toLowerCase() + "%"
        );

        return query.getResultList();
    }

    public static boolean updateStatus(User u, Status status) {
        if (u == null || u.getId() == null || status == null) {
            return false;
        }

        try {
            et.begin();

            User user = em.find(User.class, u.getId());

            if (user == null) {
                et.rollback();
                return false;
            }

            user.setStatus(status);
            em.merge(user);
            et.commit();

            return true;
        } catch (Exception e) {
            if (et.isActive()) {
                et.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }

    public static User findByEmail(String email) {
        try {
            Query query = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email"
            );
            query.setParameter("email", email);

            List<User> users = query.getResultList();
            return users.isEmpty() ? null : users.get(0);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
