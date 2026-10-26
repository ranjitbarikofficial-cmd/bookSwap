<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BookSwap — Home</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f7fb;
            color: #1f2937;
        }
        .hero {
            max-width: 760px;
            margin: 60px auto;
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 3px 12px rgba(0,0,0,0.08);
            text-align: center;
        }
        .links {
            margin-top: 25px;
            display: flex;
            justify-content: center;
            gap: 14px;
            flex-wrap: wrap;
        }
        .links a {
            display: inline-block;
            padding: 12px 20px;
            background: #2457d6;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
        }
        .links a.secondary {
            background: #2c3e50;
        }
    </style>
</head>
<body>
<div class="hero">
    <h1>Welcome to BookSwap</h1>
    <p>Discover, list, and swap books with fellow readers.</p>
    <div class="links">
        <a href="${pageContext.request.contextPath}/Login.jsp">Login</a>
        <a href="${pageContext.request.contextPath}/register.jsp">Register</a>
        <a href="${pageContext.request.contextPath}/books/list">Browse Books</a>
        <a href="${pageContext.request.contextPath}/books/add">Add a Book</a>
        <a class="secondary" href="${pageContext.request.contextPath}/books/my-books">My Books</a>
        <a class="secondary" href="${pageContext.request.contextPath}/swaps/requests">Swap Requests</a>
        <a class="secondary" href="${pageContext.request.contextPath}/seller/dashboard">Seller Dashboard</a>
    </div>
</div>
</body>
</html>
