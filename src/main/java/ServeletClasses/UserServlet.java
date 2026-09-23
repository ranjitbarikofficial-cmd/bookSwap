package ServeletClasses;

import Entity.Role;
import Entity.Status;
import Entity.User;
import Service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class UserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String phone = req.getParameter("phone");

        User u=new User();
        u.setName(name);
        u.setEmail(email);
        u.setPassword(password);
        u.setPhone(phone);
        u.setRole(Role.USER);
        u.setStatus(Status.ACTIVE);

        if (UserService.addUser(u)) {
            resp.sendRedirect("Login.jsp");
            System.out.println(u);
        } else {
            resp.sendRedirect("register.jsp");
        }



    }
}
