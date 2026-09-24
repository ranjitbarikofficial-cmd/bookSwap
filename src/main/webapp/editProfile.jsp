<%--
  Created by IntelliJ IDEA.
  User: Rahul Baliarsingh
  Date: 24-09-2026
  Time: 09:55
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <div class="container">

        <h2>Edit Profile</h2>

        <form action="editprofile" method="post">

            <label for="name">Name:</label>
            <input
                    type="text"
                    id="name"
                    name="name"
                    placeholder="Enter your name"
                    required>

            <label for="phone">Phone:</label>
            <input
                    type="tel"
                    id="phone"
                    name="phone"
                    placeholder="Enter your phone number"
                    required>

            <button type="submit">Update Profile</button>

        </form>

        <a class="back" href="ProfileServlet">Back to Profile</a>

    </div>
</head>
<body>

</body>
</html>
