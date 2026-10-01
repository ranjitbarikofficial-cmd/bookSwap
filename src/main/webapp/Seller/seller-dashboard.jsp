<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <title>Seller Dashboard - BookSwap</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f6fa;
        }

        .navbar {
            background: #2c3e50;
            color: white;
            padding: 18px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h2 {
            margin: 0;
        }

        .logout {
            color: white;
            text-decoration: none;
            background: #e74c3c;
            padding: 8px 15px;
            border-radius: 5px;
        }

        .container {
            padding: 40px;
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
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }

        .card h3 {
            margin-bottom: 15px;
        }

        .card a {
            display: inline-block;
            text-decoration: none;
            background: #3498db;
            color: white;
            padding: 10px 18px;
            border-radius: 5px;
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>BookSwap</h2>

    <a href="#" class="logout">Logout</a>
</div>

<div class="container">

    <div class="welcome">
        <h1>Seller Dashboard</h1>
        <p>Welcome to your BookSwap seller dashboard.</p>
    </div>

    <div class="cards">

        <div class="card">
            <h3>Add Book</h3>
            <p>List a new book for swapping.</p>
            <a href="add-book.jsp">Add Book</a>
        </div>

        <div class="card">
            <h3>My Books</h3>
            <p>View and manage your listed books.</p>
            <a href="my-books.jsp">My Books</a>
        </div>

        <div class="card">
            <h3>Swap Requests</h3>
            <p>View requests from other users.</p>
            <a href="swap-requests.jsp">Requests</a>
        </div>

    </div>

</div>

</body>
</html>