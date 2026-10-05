<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>BookSwap | Swap books, not money</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;800&display=swap');

        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }

        body {
            margin: 0;
            font-family: "Poppins", "Segoe UI", Arial, sans-serif;
            color: #fff;
            background:
                    radial-gradient(circle at 10% 5%, rgba(255, 176, 92, 0.22), transparent 35%),
                    radial-gradient(circle at 90% 30%, rgba(99, 102, 241, 0.3), transparent 40%),
                    #0f172a;
        }

        a { text-decoration: none; }
        .wrap { max-width: 1120px; margin: 0 auto; padding: 0 24px; }

        /* ---------- Navbar ---------- */
        nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 0;
        }
        .logo {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 1.35rem;
            font-weight: 800;
            color: #fff;
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
        .nav-links { display: flex; align-items: center; gap: 12px; }
        .nav-links .link {
            padding: 9px 16px;
            font-size: 0.9rem;
            font-weight: 500;
            color: rgba(255, 255, 255, 0.8);
            transition: color 0.2s;
        }
        .nav-links .link:hover { color: #ffd08a; }

        /* ---------- Buttons ---------- */
        .btn {
            display: inline-block;
            padding: 11px 26px;
            font-size: 0.92rem;
            font-weight: 600;
            border-radius: 999px;
            transition: transform 0.25s ease, box-shadow 0.25s ease, background 0.25s ease;
        }
        .btn-main {
            color: #1e1b4b;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
            box-shadow: 0 8px 22px rgba(255, 176, 84, 0.3);
        }
        .btn-main:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(255, 176, 84, 0.45); }
        .btn-glass {
            color: #fff;
            background: rgba(255, 255, 255, 0.07);
            border: 1.5px solid rgba(255, 255, 255, 0.3);
        }
        .btn-glass:hover { transform: translateY(-3px); background: rgba(255, 255, 255, 0.16); }

        /* ---------- Hero ---------- */
        .hero {
            display: grid;
            grid-template-columns: 1.15fr 1fr;
            align-items: center;
            gap: 40px;
            padding: 70px 0 90px;
        }
        .tag {
            display: inline-block;
            margin-bottom: 20px;
            padding: 7px 16px;
            font-size: 0.8rem;
            font-weight: 500;
            color: #ffd08a;
            background: rgba(255, 208, 138, 0.1);
            border: 1px solid rgba(255, 208, 138, 0.3);
            border-radius: 999px;
        }
        .hero h1 {
            margin: 0 0 20px;
            font-size: clamp(2.4rem, 5.5vw, 4.2rem);
            font-weight: 800;
            line-height: 1.08;
            letter-spacing: -1.5px;
        }
        .hero h1 em {
            font-style: normal;
            background: linear-gradient(90deg, #ffd08a, #ffffff 60%, #a5b4fc);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .hero p {
            max-width: 480px;
            margin: 0 0 32px;
            font-size: 1.05rem;
            line-height: 1.75;
            color: rgba(255, 255, 255, 0.72);
        }
        .hero .btns { display: flex; flex-wrap: wrap; gap: 14px; }
        .hero .btn { padding: 14px 32px; font-size: 1rem; }

        /* Book stack drawn with CSS */
        .visual { position: relative; height: 380px; display: grid; place-items: center; }
        .visual::before {
            content: "";
            position: absolute;
            width: 320px; height: 320px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255, 176, 84, 0.35), transparent 70%);
        }
        .stack { position: relative; display: grid; gap: 10px; animation: float 5s ease-in-out infinite; }
        .book {
            height: 62px;
            display: flex;
            align-items: center;
            padding: 0 24px;
            border-radius: 8px 14px 14px 8px;
            font-weight: 600;
            font-size: 0.95rem;
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.35);
            border-left: 10px solid rgba(0, 0, 0, 0.25);
        }
        .book:nth-child(1) { width: 260px; background: linear-gradient(135deg, #ffd08a, #ffb054); color: #1e1b4b; margin-left: 20px; }
        .book:nth-child(2) { width: 300px; background: linear-gradient(135deg, #818cf8, #6366f1); margin-left: -10px; }
        .book:nth-child(3) { width: 240px; background: linear-gradient(135deg, #34d399, #10b981); color: #052e25; margin-left: 30px; }
        .book:nth-child(4) { width: 280px; background: linear-gradient(135deg, #f472b6, #ec4899); margin-left: 0; }

        /* ---------- Sections ---------- */
        section.block { padding: 70px 0; }
        .head { text-align: center; max-width: 560px; margin: 0 auto 48px; }
        .head h2 { margin: 0 0 12px; font-size: clamp(1.8rem, 4vw, 2.6rem); font-weight: 800; letter-spacing: -1px; }
        .head p { margin: 0; line-height: 1.7; color: rgba(255, 255, 255, 0.65); }

        .cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 22px; }
        .card {
            padding: 32px 28px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.12);
            transition: transform 0.3s ease, border-color 0.3s ease, background 0.3s ease;
        }
        .card:hover {
            transform: translateY(-6px);
            border-color: rgba(255, 176, 84, 0.5);
            background: rgba(255, 255, 255, 0.08);
        }
        .num {
            display: grid;
            place-items: center;
            width: 44px; height: 44px;
            margin-bottom: 18px;
            border-radius: 12px;
            font-weight: 800;
            color: #1e1b4b;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
        }
        .card h3 { margin: 0 0 10px; font-size: 1.2rem; }
        .card p { margin: 0; line-height: 1.7; font-size: 0.95rem; color: rgba(255, 255, 255, 0.65); }

        /* ---------- Call to action ---------- */
        .cta {
            margin: 30px 0 80px;
            padding: 60px 32px;
            text-align: center;
            border-radius: 28px;
            background:
                    radial-gradient(circle at 20% 0%, rgba(255, 176, 92, 0.4), transparent 50%),
                    linear-gradient(135deg, #312e81, #1e1b4b);
            border: 1px solid rgba(255, 255, 255, 0.15);
        }
        .cta h2 { margin: 0 0 12px; font-size: clamp(1.7rem, 4vw, 2.4rem); font-weight: 800; letter-spacing: -1px; }
        .cta p { margin: 0 0 28px; color: rgba(255, 255, 255, 0.75); }

        /* ---------- Footer ---------- */
        footer {
            padding: 26px 0 40px;
            text-align: center;
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.45);
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        a:focus-visible { outline: 3px solid #a5b4fc; outline-offset: 3px; }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50%      { transform: translateY(-14px); }
        }
        @keyframes rise {
            from { opacity: 0; transform: translateY(24px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .hero > div:first-child { animation: rise 0.8s ease both; }

        @media (prefers-reduced-motion: reduce) {
            * { animation: none !important; transition: none !important; }
        }

        /* ---------- Mobile ---------- */
        @media (max-width: 860px) {
            .hero { grid-template-columns: 1fr; padding: 40px 0 60px; }
            .visual { height: 320px; }
            .cards { grid-template-columns: 1fr; }
            .nav-links .link { display: none; }
        }
    </style>
</head>
<body>

<div class="wrap">
    <nav>
        <a class="logo" href="index.jsp"><span>B</span> BookSwap</a>
        <div class="nav-links">
            <a class="link" href="#how">How it works</a>
            <a class="btn btn-glass" href="Login.jsp">Log in</a>
            <a class="btn btn-main" href="register.jsp">Register</a>
        </div>
    </nav>

    <header class="hero">
        <div>
            <span class="tag">📚 A community for book lovers</span>
            <h1>Swap the books you've read for <em>your next great read.</em></h1>
            <p>BookSwap lets readers trade books with each other. List what you have, find what you want, and keep the stories moving.</p>
            <div class="btns">
                <a class="btn btn-main" href="register.jsp">Get started free</a>
                <a class="btn btn-glass" href="Login.jsp">I have an account</a>
            </div>
        </div>

        <div class="visual" aria-hidden="true">
            <div class="stack">
                <div class="book">Your next read</div>
                <div class="book">Swap it</div>
                <div class="book">Pass it on</div>
                <div class="book">Repeat</div>
            </div>
        </div>
    </header>

    <section class="block" id="how">
        <div class="head">
            <h2>How it works</h2>
            <p>Three simple steps from your shelf to someone else's.</p>
        </div>
        <div class="cards">
            <div class="card">
                <div class="num">1</div>
                <h3>List your books</h3>
                <p>Add the books you're ready to part with and tell others what you have.</p>
            </div>
            <div class="card">
                <div class="num">2</div>
                <h3>Find something new</h3>
                <p>Browse and search books from other readers and pick the ones you like.</p>
            </div>
            <div class="card">
                <div class="num">3</div>
                <h3>Send a request</h3>
                <p>Ask for an exchange. When the owner agrees, swap and enjoy your new book.</p>
            </div>
        </div>
    </section>

    <div class="cta">
        <h2>Ready to swap your first book?</h2>
        <p>Join BookSwap today. It's free.</p>
        <a class="btn btn-main" href="register.jsp" style="padding:14px 34px;font-size:1rem;">Create your account</a>
    </div>
</div>

<footer>© BookSwap. Made for readers.</footer>

</body>
</html>