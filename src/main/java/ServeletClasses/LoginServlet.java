package ServeletClasses;

import Entity.User;
import Service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email=req.getParameter("email");
        String password=req.getParameter("password");

        User u= UserService.verify(email,password);
        if(u!=null){

            resp.sendRedirect("dashboard.jsp");

            HttpSession hs=req.getSession();
            hs.setAttribute("id",u.getId());
            hs.setAttribute("name",u.getName());
            hs.setAttribute("email",u.getEmail());
            hs.setAttribute("role" ,u.getRole());
            hs.setAttribute("phone",u.getPhone());
        }else{
            resp.sendRedirect("login.jsp");
        }
    }
}
