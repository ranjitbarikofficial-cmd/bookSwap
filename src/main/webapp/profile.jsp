<%@ page import="Entity.User" %><%--
  Created by IntelliJ IDEA.
  User: Rahul Baliarsingh
  Date: 24-09-2026
  Time: 00:06
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

<%
    User u=(User)request.getAttribute("User");
%>


<h2><%=u.getName()%></h2>
<p>Email:<%=u.getEmail()%></p>
<p>Phone:<%=u.getPhone()%></p>

</body>
</html>
