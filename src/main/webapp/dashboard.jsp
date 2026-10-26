<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    HttpSession hs = request.getSession(false);
    Object name = (hs != null) ? hs.getAttribute("name") : null;
    Object role = (hs != null) ? hs.getAttribute("role") : null;
    if (name == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Dashboard | BookSwap</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f6fa;
            color: #1f2937;
        }
        .navbar {
            background: #2c3e50;
            color: white;
            padding: 18px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .navbar h2 { margin: 0; }
        .nav-actions {
            display: flex;
            gap: 12px;
            align-items: center;
        }
        .btn-nav {
            color: white;
            text-decoration: none;
            background: #3498db;
            padding: 8px 15px;
            border-radius: 5px;
            border: 0;
            cursor: pointer;
            font-size: 0.9rem;
        }
        .btn-logout {
            background: #e74c3c;
        }
        .container {
            padding: 40px;
            max-width: 1080px;
            margin: 0 auto;
        }
        .welcome {
            margin-bottom: 30px;
        }
        .cards {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
        }
        .card {
            background: white;
            padding: 28px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }
        .card h3 { margin-top: 0; margin-bottom: 12px; }
        .card p { color: #475569; margin-bottom: 18px; }
        .card a {
            display: inline-block;
            text-decoration: none;
            background: #3498db;
            color: white;
            padding: 10px 18px;
            border-radius: 5px;
            font-weight: 600;
        }
    </style>
</head>
<body>

<div class="navbar">
    <h2>BookSwap</h2>
    <div class="nav-actions">
        <form action="profile" method="get" style="margin:0;">
            <button type="submit" class="btn-nav">My Profile</button>
        </form>
        <form action="logout" method="get" style="margin:0;">
            <button type="submit" class="btn-nav btn-logout">Logout</button>
        </form>
    </div>
</div>

<div class="container">
    <div class="welcome">
        <h1>Welcome <%= name %> (<%= role %>)</h1>
        <p>Manage your profile, list books, and exchange books with other readers.</p>
    </div>

    <div class="cards">
        <div class="card">
            <h3>Browse Books</h3>
            <p>Search and filter all books available for swap.</p>
            <a href="${pageContext.request.contextPath}/books/list">Browse Books</a>
        </div>

        <div class="card">
            <h3>Add Book</h3>
            <p>List a new book for swapping.</p>
            <a href="${pageContext.request.contextPath}/books/add">Add Book</a>
        </div>

        <div class="card">
            <h3>My Books</h3>
            <p>View and manage your listed books.</p>
            <a href="${pageContext.request.contextPath}/books/my-books">My Books</a>
        </div>

        <div class="card">
            <h3>Swap Requests</h3>
            <p>Send, accept, or reject book swap requests.</p>
            <a href="${pageContext.request.contextPath}/swaps/requests">Swap Requests</a>
        </div>

        <div class="card">
            <h3>Swap History</h3>
            <p>View accepted, completed, and rejected swaps.</p>
            <a href="${pageContext.request.contextPath}/swaps/history">Swap History</a>
        </div>

        <div class="card">
            <h3>My Profile</h3>
            <p>View or update your account details and password.</p>
            <a href="${pageContext.request.contextPath}/profile">Profile</a>
        </div>
    </div>
</div>

</body>
</html>
