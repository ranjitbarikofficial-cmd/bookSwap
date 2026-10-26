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
import java.util.List;

@WebServlet("/getUser")
public class ShowAll extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<User> alluser = UserService.getAlluser();

            HttpSession hs=req.getSession();
            hs.setAttribute("user",alluser);
        System.out.println(alluser);
            resp.sendRedirect("admindashboard.jsp");

    }

}
