package ServeletClasses;

import Entity.Status;
import Entity.User;
import Service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/updatestatus")
public class BlockActiveServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long id = Long.parseLong(req.getParameter("id"));
        Status status = Status.valueOf(req.getParameter("status"));

        User u = new User();
        u.setId(id);

        boolean updated = UserService.updateStatus(u, status);

        if (updated) {
            resp.sendRedirect("getUser");
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
        }
    }
}
