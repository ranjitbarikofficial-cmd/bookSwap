
package ServeletClasses;

import Service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/resetpassword")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("newpassword");

        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {
            resp.sendRedirect("updatepassword.jsp?error=invalid");
            return;
        }

        boolean updated = UserService.updatepassword(email.trim(), password);

        if (updated) {
            resp.sendRedirect("Login.jsp");
        } else {
            resp.sendRedirect("updatepassword.jsp?error=failed");
        }
    }
}
