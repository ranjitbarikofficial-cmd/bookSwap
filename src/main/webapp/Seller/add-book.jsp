<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add Book | BookSwap</title>
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
        form {
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
        button:hover { background: #1d4ed8; }
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
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 18px;
        }
        .readonly-box {
            padding: 10px 12px;
            margin-top: 6px;
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
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
    <h1>Add a Book for Swap</h1>

    <c:if test="${not empty error}">
        <div class="alert-error"><c:out value="${error}"/></div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/books/add">
        <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">

        <label for="title">Book Title *</label>
        <input id="title" name="title" maxlength="200"
               required value="<c:out value='${param.title}'/>">

        <label for="author">Author</label>
        <input id="author" name="author" maxlength="150"
               value="<c:out value='${param.author}'/>">

        <label for="description">Description</label>
        <textarea id="description" name="description" rows="4" maxlength="5000"><c:out value="${param.description}"/></textarea>

        <label for="bookCondition">Book Condition *</label>
        <select id="bookCondition" name="bookCondition" required>
            <option value="">Select condition</option>
            <option value="NEW" <c:if test="${param.bookCondition == 'NEW'}">selected</c:if>>New</option>
            <option value="LIKE_NEW" <c:if test="${param.bookCondition == 'LIKE_NEW'}">selected</c:if>>Like New</option>
            <option value="GOOD" <c:if test="${param.bookCondition == 'GOOD'}">selected</c:if>>Good</option>
            <option value="ACCEPTABLE" <c:if test="${param.bookCondition == 'ACCEPTABLE'}">selected</c:if>>Acceptable</option>
        </select>

        <label for="location">Location</label>
        <input id="location" name="location" maxlength="150"
               value="<c:out value='${param.location}'/>">

        <label for="categoryId">Category *</label>
        <select id="categoryId" name="categoryId" required>
            <option value="">Select category</option>
            <c:forEach var="category" items="${categories}">
                <option value="${category.id}"
                        <c:if test="${param.categoryId == category.id.toString()}">selected</c:if>>
                    <c:out value="${category.name}"/>
                </option>
            </c:forEach>
        </select>

        <c:choose>
            <c:when test="${not empty authenticatedSeller}">
                <label>Listing Seller (Authenticated)</label>
                <div class="readonly-box">
                    <c:out value="${authenticatedSeller.name}"/> (<c:out value="${authenticatedSeller.email}"/>)
                </div>
                <input type="hidden" name="sellerId" value="<c:out value='${authenticatedSeller.id}'/>">
            </c:when>
            <c:otherwise>
                <label for="sellerId">Seller *</label>
                <select id="sellerId" name="sellerId" required>
                    <option value="">Select seller</option>
                    <c:forEach var="seller" items="${sellers}">
                        <option value="${seller.id}"
                                <c:if test="${param.sellerId == seller.id.toString()}">selected</c:if>>
                            <c:out value="${seller.name}"/> (<c:out value="${seller.email}"/>)
                        </option>
                    </c:forEach>
                </select>
            </c:otherwise>
        </c:choose>

        <div class="btn-row">
            <button type="submit">Save Book</button>
            <a class="btn-secondary" href="${pageContext.request.contextPath}/books/list">Cancel &amp; View All Books</a>
        </div>
    </form>
</div>

</body>
</html>
