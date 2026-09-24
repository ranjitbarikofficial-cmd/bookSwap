package Service;

import Entity.Role;
import Entity.Status;
import Entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Persistence;

import java.sql.*;

public class UserService {
    private static  Connection con=null;
    private static EntityManagerFactory emf=null;
    private static EntityManager em=null;
    private static EntityTransaction et=null;
    static{
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            con= DriverManager.getConnection("jdbc:mysql://localhost:3306/bookswap","root","rahul@2004");
            System.out.println("Database connected successfully");

        } catch (Exception e) {

            System.out.println("Database connection failed!");
            e.printStackTrace();

        }
    }
    static {
        emf= Persistence.createEntityManagerFactory("BookSwap");
        em=emf.createEntityManager();
        et=em.getTransaction();
    }

    public static boolean addUser(User u){
        try {
            PreparedStatement ps = con.prepareStatement("INSERT INTO users (name, email, password, phone, role, status) VALUES (?, ?, ?, ?, ?, ?)");


            ps.setString(1, u.getName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassword());
            ps.setString(4, u.getPhone());
            ps.setString(5, u.getRole().name());
            ps.setString(6, u.getStatus().name());

            int row=ps.executeUpdate();
            if(row>0){
                return true;
            }

            return false;

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static User verify(String email,String password){
        try {
            PreparedStatement ps=con.prepareStatement("select * from users where email=? and password=?");
            ps.setString(1,email);
            ps.setString(2,password);
            ResultSet rs=ps.executeQuery();
            if(rs.next()){
                User u=new User();
                u.setId(rs.getLong("id"));
                u.setName(rs.getString("name"));
                u.setEmail(rs.getString("email"));
                u.setPassword(rs.getString("password"));
                u.setPhone(rs.getString("phone"));

                u.setRole(Role.valueOf(rs.getString("role")));
                u.setStatus(Status.valueOf(rs.getString("status")));

                u.setCreatedAt(
                        rs.getTimestamp("created_at").toLocalDateTime());
                return u;
            }else{
                return null;
            }

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static User findByid(User u){
        if(u.getId()!=null){
            et.begin();
            User un=em.find(User.class,u.getId());
            et.commit();
            return un;

        }
        return null;

    }

    public static User updateProfile(User u,String name,String phone){

        User up=UserService.findByid(u);
        if(up.getId()!=null){
            up.setName(name);
            up.setPhone(phone);
            et.begin();
            em.merge(up);
            et.commit();
            return up;
        }else{
            return null;
        }
    }
}
