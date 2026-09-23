package Util;

public class HibernateTest {

    public static void main(String[] args) {

        try {

            HibernateUtil.getSessionFactory();

            System.out.println("Hibernate connected successfully!");

        } catch (Exception e) {

            System.out.println("Hibernate connection failed!");
            e.printStackTrace();

        } finally {

            HibernateUtil.getSessionFactory().close();
        }
    }
}