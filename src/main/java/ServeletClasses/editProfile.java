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

@WebServlet("/editprofile")
public class editProfile extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        HttpSession hs=req.getSession();
        User up=(User) hs.getAttribute("User");

        System.out.println(up);

        String name=req.getParameter("name");
        String phone=req.getParameter("phone");

        User ue= UserService.updateProfile(up,name,phone);
        if(ue!=null){

            hs.setAttribute("name",ue.getName());
            resp.sendRedirect("profile.jsp");
        }else{
            resp.sendRedirect("editProfile.jsp");
        }


    }
}
