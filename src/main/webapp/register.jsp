<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Register | BookSwap</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;800&display=swap');

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1.1fr 1fr;
            font-family: "Poppins", "Segoe UI", Arial, sans-serif;
            color: #fff;
            background: #0f172a;
        }

        /* ---------- Left brand panel ---------- */
        .brand {
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 60px clamp(32px, 6vw, 90px);
            background:
                    radial-gradient(circle at 20% 15%, rgba(255, 176, 92, 0.45), transparent 45%),
                    radial-gradient(circle at 90% 90%, rgba(99, 102, 241, 0.55), transparent 50%),
                    linear-gradient(135deg, #1e1b4b, #312e81);
        }
        .brand::before, .brand::after {
            content: "";
            position: absolute;
            border-radius: 50%;
            border: 1.5px solid rgba(255, 255, 255, 0.12);
        }
        .brand::before { width: 420px; height: 420px; right: -140px; top: -120px; }
        .brand::after  { width: 300px; height: 300px; left: -100px; bottom: -90px; }

        .logo {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 40px;
            font-size: 1.4rem;
            font-weight: 800;
        }
        .logo span {
            display: grid;
            place-items: center;
            width: 38px; height: 38px;
            border-radius: 10px;
            color: #1e1b4b;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
            font-size: 1.1rem;
        }

        .brand h1 {
            margin: 0 0 16px;
            max-width: 460px;
            font-size: clamp(2rem, 4vw, 3.1rem);
            font-weight: 800;
            line-height: 1.15;
            letter-spacing: -1px;
        }
        .brand h1 em {
            font-style: normal;
            background: linear-gradient(90deg, #ffd08a, #ffffff);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .brand p {
            max-width: 420px;
            margin: 0 0 36px;
            line-height: 1.7;
            color: rgba(255, 255, 255, 0.72);
        }

        .points { list-style: none; margin: 0; padding: 0; display: grid; gap: 14px; }
        .points li {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.95rem;
            color: rgba(255, 255, 255, 0.88);
        }
        .points li::before {
            content: "✓";
            display: grid;
            place-items: center;
            flex: none;
            width: 24px; height: 24px;
            border-radius: 50%;
            font-size: 0.75rem;
            font-weight: 700;
            color: #1e1b4b;
            background: #ffd08a;
        }

        /* ---------- Right form panel ---------- */
        .panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 24px;
            background:
                    radial-gradient(circle at 80% 10%, rgba(99, 102, 241, 0.2), transparent 40%),
                    #0f172a;
        }

        form {
            width: 100%;
            max-width: 400px;
            animation: rise 0.7s ease both;
        }
        form h2 {
            margin: 0 0 6px;
            font-size: 1.9rem;
            font-weight: 800;
            letter-spacing: -0.5px;
        }
        .sub { margin: 0 0 26px; color: rgba(255, 255, 255, 0.6); font-size: 0.95rem; }

        label {
            display: block;
            margin: 0 0 8px;
            font-size: 0.85rem;
            font-weight: 500;
            color: rgba(255, 255, 255, 0.8);
        }
        .field { margin-bottom: 18px; }

        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="tel"] {
            width: 100%;
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
            margin-top: 6px;
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

        .switch {
            margin: 24px 0 0;
            text-align: center;
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.6);
        }
        .switch a { color: #ffd08a; font-weight: 600; text-decoration: none; }
        .switch a:hover { text-decoration: underline; }

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

        /* ---------- Mobile ---------- */
        @media (max-width: 860px) {
            body { grid-template-columns: 1fr; }
            .brand { display: none; }
        }
    </style>
</head>
<body>

<section class="brand">
    <div class="logo"><span>B</span> BookSwap</div>
    <h1>Your shelf is full of <em>books someone else wants.</em></h1>
    <p>Create a free account and start swapping in minutes. No buying, no fuss.</p>
    <ul class="points">
        <li>Free to join</li>
        <li>List and swap books easily</li>
        <li>Connect with readers who share your taste</li>
    </ul>
</section>

<section class="panel">
    <form method="post" action="register">
        <h2>Create your account</h2>
        <p class="sub">It only takes a minute.</p>

        <div class="field">
            <label for="name">Name</label>
            <input type="text" id="name" name="name"
                   placeholder="Enter your name" required>
        </div>

        <div class="field">
            <label for="email">Email</label>
            <input type="email" id="email" name="email"
                   placeholder="Enter your email" required>
        </div>

        <div class="field">
            <label for="password">Password</label>
            <input type="password" id="password" name="password"
                   placeholder="Enter your password" required>
        </div>

        <div class="field">
            <label for="phone">Phone</label>
            <input type="tel" id="phone" name="phone"
                   placeholder="Enter your phone number" required>
        </div>

        <button type="submit">Register</button>

        <p class="switch">Already have an account? <a href="Login.jsp">Log in</a></p>
    </form>
</section>

</body>
</html>