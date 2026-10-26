
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BookSwap - Reset Password</title>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;800&display=swap');

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 24px;
            font-family: "Poppins", "Segoe UI", Arial, sans-serif;
            color: #fff;
            background:
                    radial-gradient(circle at 10% 5%, rgba(255, 176, 92, 0.22), transparent 35%),
                    radial-gradient(circle at 90% 60%, rgba(99, 102, 241, 0.3), transparent 40%),
                    #0f172a;
        }

        .reset-container {
            width: 100%;
            max-width: 420px;
            padding: 40px 34px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.15);
            box-shadow: 0 30px 70px rgba(0, 0, 0, 0.4);
        }

        h1 {
            margin: 0 0 8px;
            font-size: 1.8rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #ffd08a, #ffffff 60%, #a5b4fc);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .subtitle {
            margin: 0 0 26px;
            font-size: 0.95rem;
            color: rgba(255, 255, 255, 0.6);
            line-height: 1.6;
        }

        .field {
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 0.9rem;
            font-weight: 500;
            color: rgba(255, 255, 255, 0.85);
        }

        input[type="email"],
        input[type="password"] {
            display: block;
            width: 100%;
            margin-top: 10px;
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

        input:focus {
            border-color: #ffb054;
            background: rgba(255, 255, 255, 0.1);
            box-shadow: 0 0 0 4px rgba(255, 176, 84, 0.18);
        }

        input:-webkit-autofill {
            -webkit-text-fill-color: #fff;
            box-shadow: 0 0 0 100px #1f2350 inset;
        }

        button[type="submit"] {
            width: 100%;
            margin-top: 8px;
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

        .error-message {
            margin-bottom: 18px;
            color: #ff9999;
            font-size: 0.85rem;
            line-height: 1.5;
        }

        .back-link {
            margin-top: 22px;
            text-align: center;
            font-size: 0.9rem;
        }

        .back-link a {
            color: #ffd08a;
            text-decoration: none;
        }

        .back-link a:hover {
            text-decoration: underline;
        }

        input:focus-visible,
        button:focus-visible {
            outline: 3px solid #a5b4fc;
            outline-offset: 3px;
        }

        @media (max-width: 480px) {
            .reset-container {
                padding: 30px 22px;
            }
        }
    </style>
</head>

<body>

<div class="reset-container">

    <h1>Reset Your Password</h1>

    <p class="subtitle">
        Enter your registered email and choose a new password.
    </p>

    <%
        String error = request.getParameter("error");
    %>

    <% if ("invalid".equals(error)) { %>
    <p class="error-message">
        Please enter a valid email and password.
    </p>
    <% } else if ("failed".equals(error)) { %>
    <p class="error-message">
        Password reset failed. Please check your registered email and try again.
    </p>
    <% } %>

    <form action="resetpassword" method="post">

        <div class="field">
            <label for="email">Registered Email</label>
            <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="Enter your registered email"
                    autocomplete="email"
                    required>
        </div>

        <div class="field">
            <label for="newpassword">New Password</label>
            <input
                    type="password"
                    id="newpassword"
                    name="newpassword"
                    placeholder="Enter your new password"
                    autocomplete="new-password"
                    required>
        </div>

        <button type="submit">Reset Password</button>

    </form>

    <div class="back-link">
        <a href="Login.jsp">Back to Login</a>
    </div>

</div>

</body>
</html>