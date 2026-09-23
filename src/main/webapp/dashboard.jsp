<%--
  Created by IntelliJ IDEA.
  User: Rahul Baliarsingh
  Date: 23-09-2026
  Time: 22:14
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

<%
  HttpSession hs=request.getSession();
  Object name=hs.getAttribute("name");
  Object role=hs.getAttribute("role");
  if(name==null){
      response.sendRedirect("Login.jsp");
  }
%>

<h1>Wellcome Mr.<%=name%> as a <%=role%></h1>

<form action="profile" method="get">
    <button>My Profile</button>
</form>


<form action="logout" method="get">
    <button>Logout</button>
</form>

</body>
</html>
