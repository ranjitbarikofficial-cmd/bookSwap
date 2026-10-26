<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
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

        .card {
            width: 100%;
            max-width: 460px;
            border-radius: 24px;
            overflow: hidden;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.14);
            box-shadow: 0 30px 70px rgba(0, 0, 0, 0.4);
        }

        .card h2 {
            margin: 0;
            padding: 46px 32px 60px;
            text-align: center;
            font-size: 1.9rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background:
                    radial-gradient(circle at 20% 0%, rgba(255, 176, 92, 0.45), transparent 55%),
                    linear-gradient(135deg, #312e81, #1e1b4b);
            position: relative;
        }

        .card h2::before {
            content: "👤";
            position: absolute;
            left: 50%;
            bottom: -40px;
            transform: translateX(-50%);
            width: 80px;
            height: 80px;
            display: grid;
            place-items: center;
            font-size: 2rem;
            border-radius: 50%;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
            border: 4px solid #171438;
            box-shadow: 0 12px 28px rgba(255, 176, 84, 0.4);
        }

        .card p {
            margin: 0;
            padding: 16px 34px;
            display: block;
            font-size: 0.95rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        .card p:first-of-type { padding-top: 56px; }
        .card p:last-of-type { border-bottom: none; }

        .card form {
            margin: 0;
            padding: 24px 34px 34px;
        }

        input[type="submit"] {
            width: 100%;
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
        input[type="submit"]:hover {
            transform: translateY(-3px);
            box-shadow: 0 16px 34px rgba(255, 176, 84, 0.45);
        }
        input[type="submit"]:active { transform: translateY(0); }
        input[type="submit"]:focus-visible {
            outline: 3px solid #a5b4fc;
            outline-offset: 3px;
        }
    </style>
</head>
<body>
<div class="card">
    <%   HttpSession hs=request.getSession();%><h2>My Profile</h2><p>Name: <%= hs.getAttribute("name")%></p><p>Email: <%= hs.getAttribute("email") %></p><p>Phone: <%=  hs.getAttribute("phone") %></p><p>Role: <%=  hs.getAttribute("role") %></p><p>Status: <%= hs.getAttribute("status") %></p><p>Member Since: <%=  hs.getAttribute("createdat") %></p><form action="editProfile.jsp" method="post">    <input type="submit" value="Edit Profile"></form>
</div>
</body>
</html>