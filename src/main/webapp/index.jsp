<html>
<head>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap');

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            padding: 24px clamp(24px, 8vw, 120px);
            display: flex;
            flex-wrap: wrap;
            justify-content: flex-start;   /* everything starts from the left */
            align-content: center;
            gap: 12px;
            font-family: "Poppins", "Segoe UI", Arial, sans-serif;
            color: #fff;
            background:
                    radial-gradient(circle at 15% 20%, rgba(255, 176, 92, 0.35), transparent 40%),
                    radial-gradient(circle at 85% 80%, rgba(99, 102, 241, 0.45), transparent 45%),
                    linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
            background-attachment: fixed;
        }

        /* Title */
        body::before {
            content: "BookSwap";
            order: 1;
            width: 100%;
            text-align: left;
            font-size: clamp(2.8rem, 8vw, 5rem);
            font-weight: 800;
            letter-spacing: -1px;
            line-height: 1.1;
            background: linear-gradient(90deg, #ffd08a, #ffffff 50%, #a5b4fc);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: rise 0.8s ease both;
        }

        /* Tagline */
        body::after {
            content: "Trade the books you've read for the ones you want next.";
            order: 2;
            width: 100%;
            max-width: 520px;
            margin: 0 0 14px;
            text-align: left;
            font-size: clamp(1rem, 2.5vw, 1.15rem);
            line-height: 1.6;
            color: rgba(255, 255, 255, 0.72);
            animation: rise 0.8s 0.15s ease both;
        }

        /* Small buttons */
        a {
            order: 3;
            display: inline-block;
            padding: 9px 24px;
            text-align: center;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 600;
            letter-spacing: 0.3px;
            border-radius: 999px;
            transition: transform 0.25s ease, box-shadow 0.25s ease, background 0.25s ease;
            animation: rise 0.8s 0.3s ease both;
        }

        /* Register = main action */
        a[href="register.jsp"] {
            color: #1e1b4b;
            background: linear-gradient(135deg, #ffd08a, #ffb054);
            box-shadow: 0 8px 20px rgba(255, 176, 84, 0.35);
        }
        a[href="register.jsp"]:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 28px rgba(255, 176, 84, 0.5);
        }

        /* Login = glass button */
        a[href="Login.jsp"] {
            color: #fff;
            background: rgba(255, 255, 255, 0.08);
            border: 1.5px solid rgba(255, 255, 255, 0.35);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }
        a[href="Login.jsp"]:hover {
            transform: translateY(-3px);
            background: rgba(255, 255, 255, 0.18);
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.3);
        }

        a:focus-visible {
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
<body><a href="register.jsp">Register</a><a href="Login.jsp">Login</a></body></html>