<%--
  Created by IntelliJ IDEA.
  User: Rahul Baliarsingh
  Date: 23-09-2026
  Time: 18:24
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>


<form method="post" action="register" >

    <label for="name">Name:</label>
    <input type="text" id="name" name="name"
           placeholder="Enter your name" required>
    <br><br>

    <label for="email">Email:</label>
    <input type="email" id="email" name="email"
           placeholder="Enter your email" required>
    <br><br>

    <label for="password">Password:</label>
    <input type="password" id="password" name="password"
           placeholder="Enter your password" required>
    <br><br>

    <label for="phone">Phone:</label>
    <input type="tel" id="phone" name="phone"
           placeholder="Enter your phone number" required>
    <br><br>

    <button type="submit">Register</button>

</form>

</body>
</html>
