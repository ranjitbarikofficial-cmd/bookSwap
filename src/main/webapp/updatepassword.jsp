<%--  Created by IntelliJ IDEA.  User: Rahul Baliarsingh  Date: 24-09-2026  Time: 15:29  To change this template use File | Settings | File Templates.--%><%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html><head>    <title>Title</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;800&display=swap');

        * { box-sizing: border-box; }

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

        form {
            width: 100%;
            max-width: 400px;
            padding: 40px 34px;
            display: flex;
            flex-direction: column;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.15);
            box-shadow: 0 30px 70px rgba(0, 0, 0, 0.4);
        }

        /* Label the form via the first line of text, without touching markup */
        form::before {
            content: "Reset your password";
            display: block;
            margin-bottom: 6px;
            font-size: 1.8rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #ffd08a, #ffffff 60%, #a5b4fc);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        form::after {
            content: "Enter your email and choose a new password.";
            display: block;
            margin-bottom: 26px;
            font-size: 0.95rem;
            color: rgba(255, 255, 255, 0.6);
        }

        /* Plain text labels in your form */
        form {
            font-size: 0.85rem;
            font-weight: 500;
            color: rgba(255, 255, 255, 0.8);
        }

        input[type="email"],
        input[type="password"] {
            display: block;
            width: 100%;
            margin: 10px 0 4px;
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
            transition: background-color 9999s ease-in-out 0s;
        }

        button[type="submit"] {
            width: 100%;
            margin-top: 16px;
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
        input:focus-visible, button:focus-visible {
            outline: 3px solid #a5b4fc;
            outline-offset: 3px;
        }

        br { display: none; } /* spacing is now handled by CSS margins instead */
    </style>
</head><body><form action="resetpassword" method="post" >    Enter your Email:
    <input type="email" name="email"><br><br>  Enter your new password:
    <input type="password" name="newpassword" ><br><br>  <button type="submit">Reset Password</button></form></body></html>