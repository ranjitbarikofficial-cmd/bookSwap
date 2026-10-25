<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>BookSwap Dashboard</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap');

        * { box-sizing: border-box; }

        body {
            font-family: "Poppins", "Segoe UI", Arial, sans-serif;
            margin: 0;
            padding: 0;
            color: #fff;
            background:
                    radial-gradient(circle at 10% 5%, rgba(255, 176, 92, 0.18), transparent 35%),
                    radial-gradient(circle at 90% 20%, rgba(99, 102, 241, 0.28), transparent 40%),
                    #0f172a;
            min-height: 100vh;
        }

        header {
            background: rgba(255, 255, 255, 0.04);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            color: white;
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        header h2 {
            margin: 0;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #ffd08a, #ffffff 60%, #a5b4fc);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        header span {
            font-size: 0.95rem;
            color: rgba(255, 255, 255, 0.75);
        }

        .container {
            padding: 30px 40px 60px;
            max-width: 1100px;
            margin: 0 auto;
        }

        .welcome {
            margin-bottom: 30px;
        }

        .welcome h1 {
            font-weight: 800;
            letter-spacing: -0.5px;
            margin-bottom: 6px;
        }

        .welcome p {
            color: rgba(255, 255, 255, 0.65);
            font-size: 1rem;
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-top: 25px;
        }

        .feature-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.12);
            padding: 25px;
            border-radius: 16px;
            transition: transform 0.25s ease, border-color 0.25s ease, background 0.25s ease;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            border-color: rgba(255, 176, 84, 0.45);
            background: rgba(255, 255, 255, 0.08);
        }

        .feature-card h3 {
            margin-top: 0;
            font-weight: 600;
        }

        .feature-card p {
            color: rgba(255, 255, 255, 0.6);
            line-height: 1.6;
            font-size: 0.93rem;
        }

        .feature-card a {
            display: inline-block;
            color: #1e1b4b;
            text-decoration: none;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
            padding: 10px 18px;
            border-radius: 999px;
            margin-top: 12px;
            font-size: 0.88rem;
            font-weight: 600;
            box-shadow: 0 8px 20px rgba(255, 176, 84, 0.28);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .feature-card a:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 26px rgba(255, 176, 84, 0.4);
        }

        .section {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.12);
            padding: 24px 28px;
            border-radius: 16px;
            margin-top: 25px;
        }

        .section h2 {
            margin-top: 0;
            font-weight: 600;
            font-size: 1.2rem;
        }

        .section p {
            color: rgba(255, 255, 255, 0.65);
            line-height: 1.6;
            font-size: 0.93rem;
        }

        .section strong {
            color: #ffd08a;
        }

        .account-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 12px;
        }

        .account-actions form {
            margin: 0;
        }

        button {
            background: rgba(255, 255, 255, 0.08);
            color: #fff;
            border: 1.5px solid rgba(255, 255, 255, 0.25);
            padding: 11px 20px;
            border-radius: 999px;
            cursor: pointer;
            font-family: inherit;
            font-size: 0.9rem;
            font-weight: 500;
            transition: background 0.2s ease, transform 0.2s ease;
        }

        button:hover {
            background: rgba(255, 255, 255, 0.16);
            transform: translateY(-2px);
        }

        button:focus-visible {
            outline: 3px solid #a5b4fc;
            outline-offset: 2px;
        }

        @media (max-width: 600px) {
            header {
                padding: 18px;
                flex-direction: column;
                align-items: flex-start;
                gap: 6px;
            }

            .container {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<%
    HttpSession hs = request.getSession(false);
    Object name = hs == null ? null : hs.getAttribute("name");
    Object role = hs == null ? null : hs.getAttribute("role");

    if (name == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>

<header>
    <h2>BookSwap</h2>
    <span>Welcome, <%=name%></span>
</header>

<div class="container">

    <div class="welcome">
        <h1>Welcome, <%=name%>!</h1>
        <p>Find books, share your books, and exchange knowledge with other readers.</p>
    </div>

    <div class="feature-grid">

        <div class="feature-card">
            <h3>Browse Books</h3>
            <p>Explore books available from other users and find your next read.</p>
            <a href="browseBooks.jsp">Browse Books</a>
        </div>

        <div class="feature-card">
            <h3>Add My Book</h3>
            <p>List a book you own and make it available for exchange.</p>
            <a href="addBook.jsp">Add My Book</a>
        </div>

        <div class="feature-card">
            <h3>My Requests</h3>
            <p>Check your book requests and see whether they are pending or matched.</p>
            <a href="myRequests">View Requests</a>
        </div>

        <div class="feature-card">
            <h3>My Exchanges</h3>
            <p>Track your matched books and the progress of your exchanges.</p>
            <a href="myExchanges">View Exchanges</a>
        </div>

    </div>

    <div class="section">
        <h2>My Activity</h2>
        <p>Pending Requests: View your requests that are waiting for a match.</p>
        <p>Potential Matches: Check requests that may have a suitable exchange.</p>
        <p>Completed Exchanges: Keep track of successfully completed book exchanges.</p>
        <p><em>Activity counts can be displayed here after connecting the dashboard to your database.</em></p>
    </div>

    <div class="section">
        <h2>Recent Updates</h2>
        <p>Your recent request and exchange notifications will appear here.</p>
        <p><em>Notifications can be connected after the request and matching features are implemented.</em></p>
    </div>

    <div class="section">
        <h2>My Account</h2>
        <p>Logged in as: <strong><%=name%></strong></p>
        <p>Role: <strong><%=role%></strong></p>

        <div class="account-actions">
            <form action="profile" method="get">
                <button type="submit">My Profile</button>
            </form>

            <form action="logout" method="get">
                <button type="submit">Logout</button>
            </form>
        </div>
    </div>

</div>

</body>
</html>