<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- If nobody is logged in, send them to the login page --%>
<c:if test="${empty sessionScope.User}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit Profile | BookSwap</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;800&display=swap');

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Poppins", "Segoe UI", Arial, sans-serif;
            color: #fff;
            background:
                    radial-gradient(circle at 10% 5%, rgba(255, 176, 92, 0.22), transparent 35%),
                    radial-gradient(circle at 90% 60%, rgba(99, 102, 241, 0.3), transparent 40%),
                    #0f172a;
        }

        nav {
            max-width: 1120px;
            margin: 0 auto;
            padding: 22px 24px;
        }
        .logo {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 1.35rem;
            font-weight: 800;
            color: #fff;
            text-decoration: none;
        }
        .logo span {
            display: grid;
            place-items: center;
            width: 36px; height: 36px;
            border-radius: 10px;
            color: #1e1b4b;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
            font-size: 1.05rem;
        }

        main {
            display: flex;
            justify-content: center;
            padding: 30px 24px 80px;
        }

        .container {
            width: 100%;
            max-width: 460px;
            padding: 40px 34px 34px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.15);
            box-shadow: 0 30px 70px rgba(0, 0, 0, 0.4);
            animation: rise 0.7s ease both;
        }
        .container h2 {
            margin: 0 0 6px;
            font-size: 1.9rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #ffd08a, #ffffff 60%, #a5b4fc);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .container h2::after {
            content: "Update your details below.";
            display: block;
            margin-top: 6px;
            font-size: 0.95rem;
            font-weight: 400;
            -webkit-text-fill-color: rgba(255, 255, 255, 0.6);
        }

        form { margin-top: 28px; display: flex; flex-direction: column; }

        label {
            margin: 0 0 8px;
            font-size: 0.85rem;
            font-weight: 500;
            color: rgba(255, 255, 255, 0.8);
        }

        input[type="text"],
        input[type="tel"] {
            width: 100%;
            margin-bottom: 20px;
            padding: 14px 16px;
            font-family: inherit;
            font-size: 0.95rem;
            color: #fff;
            background: rgba(255, 255, 255, 0.06);
            border: 1.5px solid rgba(255, 255, 255, 0.16);
            border-radius: 12px;
            outline: none;
            transition: border-color 0.25s, background 0.25s, box-shadow 0.25s;
        }
        input::placeholder { color: rgba(255, 255, 255, 0.4); }
        input:focus {
            border-color: #ffb054;
            background: rgba(255, 255, 255, 0.1);
            box-shadow: 0 0 0 4px rgba(255, 176, 84, 0.18);
        }
        input:-webkit-autofill {
            -webkit-text-fill-color: #fff;
            box-shadow: 0 0 0 100px #1f2350 inset;
            transition: background-color 9999s ease-in-out 0s;
        }

        button[type="submit"] {
            width: 100%;
            margin-top: 4px;
            padding: 14px;
            font-family: inherit;
            font-size: 1rem;
            font-weight: 600;
            color: #1e1b4b;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
            border: none;
            border-radius: 12px;
            cursor: pointer;
            box-shadow: 0 10px 25px rgba(255, 176, 84, 0.3);
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }
        button[type="submit"]:hover {
            transform: translateY(-3px);
            box-shadow: 0 16px 34px rgba(255, 176, 84, 0.45);
        }
        button[type="submit"]:active { transform: translateY(0); }

        .back {
            display: block;
            margin-top: 22px;
            text-align: center;
            font-size: 0.9rem;
            font-weight: 600;
            color: #ffd08a;
            text-decoration: none;
        }
        .back:hover { text-decoration: underline; }

        input:focus-visible, button:focus-visible, a:focus-visible {
            outline: 3px solid #a5b4fc;
            outline-offset: 3px;
        }

        @keyframes rise {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @media (prefers-reduced-motion: reduce) {
            * { animation: none !important; transition: none !important; }
        }
    </style>
</head>
<body>
<nav>
    <a class="logo" href="index.jsp"><span>B</span> BookSwap</a>
</nav>
<main>
    <div class="container">
        <h2>Edit Profile</h2>
        <form action="editprofile" method="post">
            <label for="name">Name:</label>
            <input type="text" id="name" name="name"
                   value="<c:out value='${sessionScope.User.name}'/>"
                   placeholder="Enter your name" required>
            <label for="phone">Phone:</label>
            <input type="tel" id="phone" name="phone"
                   value="<c:out value='${sessionScope.User.phone}'/>"
                   placeholder="Enter your phone number" required>
            <button type="submit">Update Profile</button>
        </form>
        <a class="back" href="profile.jsp">Back to Profile</a>
    </div>
</main>
</body>
</html>