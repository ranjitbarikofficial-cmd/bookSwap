
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BookSwap - Login</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #171c32, #293451);
            color: #ffffff;
        }

        .login-container {
            width: 100%;
            max-width: 420px;
            padding: 35px;
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.08);
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.25);
        }

        .logo {
            margin-bottom: 10px;
            color: #ffd08a;
            text-align: center;
            font-size: 30px;
            font-weight: bold;
        }

        h2 {
            margin-bottom: 8px;
            text-align: center;
            font-size: 25px;
        }

        .subtitle {
            margin-bottom: 28px;
            color: #c5ccdc;
            text-align: center;
            font-size: 14px;
        }

        .field {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
        }

        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #515c77;
            border-radius: 8px;
            outline: none;
            background: #202943;
            color: #ffffff;
            font-size: 15px;
        }

        input[type="email"]:focus,
        input[type="password"]:focus {
            border-color: #ffd08a;
        }

        input[type="submit"] {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 8px;
            background: #ffd08a;
            color: #202943;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background: #ffc46a;
        }

        .forgot-password {
            margin-top: -8px;
            margin-bottom: 22px;
            text-align: right;
        }

        a {
            color: #ffd08a;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        .error-message {
            margin-bottom: 18px;
            color: #ff9999;
            font-size: 13px;
            line-height: 1.5;
        }

        .success-message {
            margin-bottom: 18px;
            color: #9ce6b0;
            font-size: 13px;
            line-height: 1.5;
        }

        .switch {
            margin-top: 22px;
            color: #c5ccdc;
            text-align: center;
            font-size: 14px;
        }

        @media (max-width: 480px) {
            .login-container {
                padding: 25px 20px;
            }
        }
    </style>
</head>

<body>

<div class="login-container">

    <div class="logo">BookSwap</div>

    <h2>Welcome Back</h2>

    <p class="subtitle">Log in to continue your reading journey</p>

    <%
        String error = request.getParameter("error");
        String message = request.getParameter("message");
    %>

    <% if ("invalid".equals(error)) { %>
    <p class="error-message">
        Invalid email or password, or your account is blocked. Please check your details.
    </p>
    <% } else if ("failed".equals(error)) { %>
    <p class="error-message">
        Login failed. Please try again.
    </p>
    <% } %>

    <% if ("passwordupdated".equals(message)) { %>
    <p class="success-message">
        Password updated successfully. Please log in with your new password.
    </p>
    <% } %>

    <form action="login" method="post">

        <div class="field">
            <label for="email">Email</label>
            <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="Enter your email"
                    autocomplete="email"
                    required>
        </div>

        <div class="field">
            <label for="password">Password</label>
            <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="Enter your password"
                    autocomplete="current-password"
                    required>
        </div>

        <div class="forgot-password">
            <a href="updatepassword.jsp">Forgot Password?</a>
        </div>

        <input type="submit" value="Log in">

        <p class="switch">
            New here?
            <a href="register.jsp">Create an account</a>
        </p>

    </form>

</div>

</body>
</html>
