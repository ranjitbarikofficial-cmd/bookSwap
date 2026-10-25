package Util;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public class HibernateUtil {

    private static final SessionFactory sessionFactory = buildSessionFactory();

    private HibernateUtil() {
    }

    private static SessionFactory buildSessionFactory() {
        Configuration configuration = new Configuration().configure("hibernate.cfg.xml");

        String dbUrl = System.getenv("BOOKSWAP_DB_URL");
        if (dbUrl != null && !dbUrl.isBlank()) {
            configuration.setProperty("hibernate.connection.url", dbUrl.trim());
        }

        String dbUser = System.getenv("BOOKSWAP_DB_USER");
        if (dbUser != null && !dbUser.isBlank()) {
            configuration.setProperty("hibernate.connection.username", dbUser.trim());
        }

        String dbPassword = System.getenv("BOOKSWAP_DB_PASSWORD");
        if (dbPassword != null && !dbPassword.isBlank()) {
            configuration.setProperty("hibernate.connection.password", dbPassword);
        }

        return configuration.buildSessionFactory();
    }

    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }
}