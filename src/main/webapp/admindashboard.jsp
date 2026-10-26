
<%@ page import="Entity.Role" %>
<%@ page import="Entity.Status" %>
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
  List<User> users = (List<User>) hs.getAttribute("user");

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
    <th>Action</th>
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
    <td>
      <form action="updatestatus" method="post">
        <input type="hidden" name="id" value="<%= u.getId() %>">

        <% if (u.getStatus() == Status.ACTIVE) { %>
        <input type="hidden" name="status" value="BLOCKED">
        <button type="submit">Block</button>
        <% } else { %>
        <input type="hidden" name="status" value="ACTIVE">
        <button type="submit">Unblock</button>
        <% } %>
      </form>
    </td>
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