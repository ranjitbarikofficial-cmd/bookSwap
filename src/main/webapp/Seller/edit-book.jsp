<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit Book | BookSwap</title>
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
            max-width: 680px;
            margin: 35px auto;
            padding: 0 20px;
        }
        .card, form {
            background: white;
            padding: 28px;
            border-radius: 12px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
        }
        label {
            display: block;
            margin-top: 16px;
            font-weight: 600;
            font-size: 0.92rem;
        }
        input, textarea, select {
            width: 100%;
            padding: 10px 12px;
            margin-top: 6px;
            box-sizing: border-box;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 0.95rem;
        }
        .readonly-box {
            padding: 10px 12px;
            margin-top: 6px;
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
        }
        .btn-row {
            margin-top: 24px;
            display: flex;
            gap: 12px;
            align-items: center;
        }
        button {
            padding: 12px 22px;
            background: #2457d6;
            color: white;
            border: 0;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-secondary {
            display: inline-block;
            padding: 11px 18px;
            background: #e2e8f0;
            color: #1e293b;
            text-decoration: none;
            border-radius: 6px;
            font-size: 0.92rem;
        }
        .alert-error {
            background: #fef2f2;
            color: #b42318;
            border: 1px solid #fecdca;
            padding: 14px 16px;
            border-radius: 8px;
            margin-bottom: 18px;
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
    <h1>Edit Book</h1>

    <c:choose>
        <c:when test="${authRequired or forbidden or notFound or empty book}">
            <div class="card">
                <div class="alert-error">
                    <c:out value="${not empty error ? error : 'Unable to edit the requested book.'}"/>
                </div>
                <a class="btn-secondary" href="${pageContext.request.contextPath}/books/list">&larr; Back to Browse Books</a>
            </div>
        </c:when>
        <c:otherwise>
            <c:if test="${not empty error}">
                <div class="alert-error"><c:out value="${error}"/></div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/books/edit">
                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                <input type="hidden" name="id" value="<c:out value='${book.id}'/>">

                <label for="title">Book Title *</label>
                <input id="title" name="title" maxlength="200"
                       required value="<c:out value='${book.title}'/>">

                <label for="author">Author</label>
                <input id="author" name="author" maxlength="150"
                       value="<c:out value='${book.author}'/>">

                <label for="description">Description</label>
                <textarea id="description" name="description" rows="4" maxlength="5000"><c:out value="${book.description}"/></textarea>

                <label for="bookCondition">Book Condition *</label>
                <select id="bookCondition" name="bookCondition" required>
                    <option value="">Select condition</option>
                    <option value="NEW" <c:if test="${book.bookCondition == 'NEW'}">selected</c:if>>New</option>
                    <option value="LIKE_NEW" <c:if test="${book.bookCondition == 'LIKE_NEW'}">selected</c:if>>Like New</option>
                    <option value="GOOD" <c:if test="${book.bookCondition == 'GOOD'}">selected</c:if>>Good</option>
                    <option value="ACCEPTABLE" <c:if test="${book.bookCondition == 'ACCEPTABLE'}">selected</c:if>>Acceptable</option>
                </select>

                <label for="location">Location</label>
                <input id="location" name="location" maxlength="150"
                       value="<c:out value='${book.location}'/>">

                <label for="status">Availability Status *</label>
                <select id="status" name="status" required>
                    <option value="AVAILABLE" <c:if test="${book.status == 'AVAILABLE'}">selected</c:if>>Available</option>
                    <option value="PENDING" <c:if test="${book.status == 'PENDING'}">selected</c:if>>Pending Swap</option>
                    <option value="SWAPPED" <c:if test="${book.status == 'SWAPPED'}">selected</c:if>>Swapped</option>
                    <option value="UNAVAILABLE" <c:if test="${book.status == 'UNAVAILABLE'}">selected</c:if>>Unavailable</option>
                </select>

                <label for="categoryId">Category *</label>
                <select id="categoryId" name="categoryId" required>
                    <option value="">Select category</option>
                    <c:forEach var="category" items="${categories}">
                        <option value="${category.id}"
                                <c:if test="${book.category != null and book.category.id == category.id}">selected</c:if>>
                            <c:out value="${category.name}"/>
                        </option>
                    </c:forEach>
                </select>

                <label>Seller (Preserved Ownership)</label>
                <div class="readonly-box">
                    <c:out value="${book.seller != null ? book.seller.name : 'Unknown'}"/>
                    <c:if test="${book.seller != null and not empty book.seller.email}">
                        (<c:out value="${book.seller.email}"/>)
                    </c:if>
                </div>

                <div class="btn-row">
                    <button type="submit">Update Book</button>
                    <a class="btn-secondary" href="${pageContext.request.contextPath}/books/details?id=${book.id}">Cancel</a>
                </div>
            </form>

            <div class="card" style="margin-top:20px; border:1px solid #fecdd3; background:#fff1f2;">
                <h3 style="margin:0 0 8px 0; color:#9f1239;">Delete This Book</h3>
                <p style="margin:0 0 14px 0; font-size:0.92rem; color:#881337;">
                    Permanently remove <strong><c:out value="${book.title}"/></strong> from BookSwap listings.
                </p>
                <form method="post"
                      action="${pageContext.request.contextPath}/books/delete"
                      style="padding:0; background:transparent; box-shadow:none;"
                      onsubmit="return confirm('Are you sure you want to permanently delete this book?');">
                    <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                    <input type="hidden" name="id" value="<c:out value='${book.id}'/>">
                    <input type="hidden" name="source" value="list">
                    <button type="submit" style="background:#dc2626;">Delete Book</button>
                </form>
            </div>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>
