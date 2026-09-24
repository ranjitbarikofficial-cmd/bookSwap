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

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession hs= req.getSession();
        Object id=hs.getAttribute("id");

        User u=new User();
        u.setId((Long)id);

        User up= UserService.findByid(u);
        if(up!=null){
            hs.setAttribute("User",up);
            req.getRequestDispatcher("profile.jsp").forward(req,resp);
        }else{
            resp.sendRedirect("Login.jsp");
        }
    }
}
