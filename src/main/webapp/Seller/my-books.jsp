<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Books | BookSwap</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f7fb;
            color: #1f2937;
        }
        .navbar {
            background: #2c3e50;
            color: white;
            padding: 16px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .navbar h2 { margin: 0; font-size: 1.35rem; }
        .nav-links a {
            color: white;
            text-decoration: none;
            margin-left: 18px;
            font-size: 0.95rem;
        }
        .nav-links a:hover { text-decoration: underline; }
        .container {
            max-width: 1050px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .btn-primary {
            display: inline-block;
            background: #2457d6;
            color: white;
            padding: 10px 18px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
        }
        .btn-secondary {
            display: inline-block;
            background: #e2e8f0;
            color: #1e293b;
            padding: 9px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 0.9rem;
        }
        .btn-danger {
            background: #dc2626;
            color: white;
            padding: 6px 12px;
            border: 0;
            border-radius: 5px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
        }
        .alert-success {
            background: #ecfdf3;
            color: #027a48;
            border: 1px solid #a6f4c5;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 18px;
        }
        .alert-warning {
            background: #fffbeb;
            color: #92400e;
            border: 1px solid #fde68a;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 18px;
        }
        .alert-error {
            background: #fef2f2;
            color: #b42318;
            border: 1px solid #fecdca;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 18px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
        }
        th, td {
            padding: 12px 14px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }
        th {
            background: #f8fafc;
            font-weight: 700;
            font-size: 0.88rem;
            color: #475569;
        }
        .badge {
            display: inline-block;
            padding: 4px 9px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 600;
            background: #e0f2fe;
            color: #0369a1;
        }
        .empty-state {
            background: white;
            padding: 40px 25px;
            text-align: center;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
        }
        .actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .actions a {
            color: #2457d6;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>

<div class="navbar">
    <h2>BookSwap</h2>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/seller/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/books/list">Browse Books</a>
        <a href="${pageContext.request.contextPath}/books/add">Add Book</a>
        <a href="${pageContext.request.contextPath}/books/my-books">My Books</a>
    </div>
</div>

<div class="container">
    <div class="header-row">
        <div>
            <h1 style="margin:0;">My Listed Books</h1>
            <c:if test="${not empty authenticatedSeller}">
                <p style="margin:6px 0 0 0; color:#475569;">
                    Signed in as <strong><c:out value="${authenticatedSeller.name}"/></strong>
                    (<c:out value="${authenticatedSeller.email}"/>)
                </p>
            </c:if>
        </div>
        <a class="btn-primary" href="${pageContext.request.contextPath}/books/add">+ List New Book</a>
    </div>

    <c:if test="${param.deleted == 'true'}">
        <div class="alert-success">Book was deleted from your listings.</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert-error"><c:out value="${error}"/></div>
    </c:if>

    <c:choose>
        <c:when test="${authRequired or empty authenticatedSeller}">
            <div class="alert-warning">
                <h3 style="margin-top:0;">Authentication Required</h3>
                <p>
                    To view and manage your personal book listings, please sign in through the Authentication module.
                    For security, BookSwap only displays books tied to your active server-side session and never accepts a browser-supplied seller ID.
                </p>
                <p style="margin-bottom:0;">
                    <a class="btn-secondary" href="${pageContext.request.contextPath}/books/list">Browse Public Books</a>
                    <a class="btn-secondary" href="${pageContext.request.contextPath}/seller/dashboard" style="margin-left:8px;">Return to Dashboard</a>
                </p>
            </div>
        </c:when>
        <c:when test="${empty books}">
            <div class="empty-state">
                <h3>You haven't listed any books yet</h3>
                <p>Start sharing books you'd like to swap with other readers.</p>
                <a class="btn-primary" href="${pageContext.request.contextPath}/books/add">Add Your First Book</a>
            </div>
        </c:when>
        <c:otherwise>
            <table>
                <thead>
                <tr>
                    <th>Title</th>
                    <th>Author</th>
                    <th>Category</th>
                    <th>Condition</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th>Manage</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="book" items="${books}">
                    <tr>
                        <td>
                            <a href="${pageContext.request.contextPath}/books/details?id=${book.id}">
                                <strong><c:out value="${book.title}"/></strong>
                            </a>
                        </td>
                        <td><c:out value="${not empty book.author ? book.author : '—'}"/></td>
                        <td><c:out value="${book.category != null ? book.category.name : 'Uncategorized'}"/></td>
                        <td><c:out value="${not empty book.bookCondition ? book.bookCondition : '—'}"/></td>
                        <td><c:out value="${not empty book.location ? book.location : '—'}"/></td>
                        <td><span class="badge"><c:out value="${book.status}"/></span></td>
                        <td>
                            <div class="actions">
                                <a href="${pageContext.request.contextPath}/books/details?id=${book.id}">View</a>
                                <a href="${pageContext.request.contextPath}/books/edit?id=${book.id}">Edit</a>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/books/delete"
                                      style="margin:0;"
                                      onsubmit="return confirm('Are you sure you want to delete this book?');">
                                    <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                                    <input type="hidden" name="id" value="<c:out value='${book.id}'/>">
                                    <button type="submit" class="btn-danger">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>
