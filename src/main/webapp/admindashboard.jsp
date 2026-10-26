
<%@ page import="Entity.Role" %>
<%@ page import="Entity.User" %>
<%@ page import="java.util.List" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
  <title>Admin Dashboard</title>
</head>

<body>

<%
  HttpSession hs = request.getSession();

  Object name = hs.getAttribute("name");
  Object role = hs.getAttribute("role");

  if (role == null || role != Role.ADMIN) {
    response.sendRedirect("Login.jsp");
    return;
  }


%>

<h1>Welcome Mr. <%= name %> as a <%= role %></h1>

<form action="getUser" method="get">
  <button type="submit">Show All Users</button>
</form>

<%
  HttpSession session1=request.getSession();
  List<User> users = (List<User>) session1.getAttribute("user");
  if (users != null) {
%>

<h2>All Users</h2>

<table border="1" cellpadding="10">

  <tr>
    <th>ID</th>
    <th>Name</th>
    <th>Email</th>
    <th>Phone</th>
    <th>Role</th>
    <th>Status</th>
  </tr>

  <%
    for (User u : users) {
  %>

  <tr>
    <td><%= u.getId() %></td>
    <td><%= u.getName() %></td>
    <td><%= u.getEmail() %></td>
    <td><%= u.getPhone() %></td>
    <td><%= u.getRole() %></td>
    <td><%= u.getStatus() %></td>
  </tr>

  <%
    }
  %>

</table>

<%
  }
%>

</body>
</html>
