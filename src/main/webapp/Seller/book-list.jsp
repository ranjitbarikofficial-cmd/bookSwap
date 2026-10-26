<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Browse Books | BookSwap</title>
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
            max-width: 1100px;
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
        .filter-card {
            background: white;
            padding: 18px 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            margin-bottom: 22px;
        }
        .filter-grid {
            display: grid;
            grid-template-columns: 2fr 1.2fr 1fr 1fr auto;
            gap: 12px;
            align-items: end;
        }
        .filter-grid label {
            display: block;
            font-size: 0.84rem;
            font-weight: 600;
            margin-bottom: 5px;
        }
        .filter-grid input, .filter-grid select {
            width: 100%;
            padding: 9px 10px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            box-sizing: border-box;
        }
        .filter-actions {
            display: flex;
            gap: 8px;
        }
        .btn-search {
            padding: 9px 16px;
            background: #2c3e50;
            color: white;
            border: 0;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
        }
        .btn-reset {
            padding: 9px 14px;
            background: #e2e8f0;
            color: #1e293b;
            text-decoration: none;
            border-radius: 6px;
            font-size: 0.9rem;
        }
        .alert-success {
            background: #ecfdf3;
            color: #027a48;
            border: 1px solid #a6f4c5;
            padding: 12px 16px;
            border-radius: 8px;
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
        .actions a:hover { text-decoration: underline; }
        .btn-delete-inline {
            background: #dc2626;
            color: white;
            border: 0;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.84rem;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-delete-inline:hover { background: #b91c1c; }
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
        <h1>Browse Books</h1>
        <a class="btn-primary" href="${pageContext.request.contextPath}/books/add">+ Add a Book</a>
    </div>

    <c:if test="${param.added == 'true'}">
        <div class="alert-success">Book saved successfully!</div>
    </c:if>
    <c:if test="${param.deleted == 'true'}">
        <div class="alert-success">Book deleted successfully.</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert-error"><c:out value="${error}"/></div>
    </c:if>
    <c:if test="${not empty filterWarning}">
        <div class="alert-error"><c:out value="${filterWarning}"/></div>
    </c:if>

    <div class="filter-card">
        <form method="get" action="${pageContext.request.contextPath}/books/list">
            <div class="filter-grid">
                <div>
                    <label for="q">Search Title or Author</label>
                    <input id="q" name="q" type="text"
                           placeholder="e.g. Clean Code, Joshua Bloch..."
                           value="<c:out value='${searchKeyword}'/>">
                </div>

                <div>
                    <label for="categoryId">Category</label>
                    <select id="categoryId" name="categoryId">
                        <option value="">All Categories</option>
                        <c:forEach var="category" items="${categories}">
                            <option value="${category.id}"
                                    <c:if test="${selectedCategoryId == category.id}">selected</c:if>>
                                <c:out value="${category.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label for="condition">Condition</label>
                    <select id="condition" name="condition">
                        <option value="">All Conditions</option>
                        <option value="NEW" <c:if test="${selectedCondition == 'NEW'}">selected</c:if>>New</option>
                        <option value="LIKE_NEW" <c:if test="${selectedCondition == 'LIKE_NEW'}">selected</c:if>>Like New</option>
                        <option value="GOOD" <c:if test="${selectedCondition == 'GOOD'}">selected</c:if>>Good</option>
                        <option value="ACCEPTABLE" <c:if test="${selectedCondition == 'ACCEPTABLE'}">selected</c:if>>Acceptable</option>
                    </select>
                </div>

                <div>
                    <label for="status">Availability</label>
                    <select id="status" name="status">
                        <option value="">All Statuses</option>
                        <option value="AVAILABLE" <c:if test="${selectedStatus == 'AVAILABLE'}">selected</c:if>>Available</option>
                        <option value="PENDING" <c:if test="${selectedStatus == 'PENDING'}">selected</c:if>>Pending</option>
                        <option value="SWAPPED" <c:if test="${selectedStatus == 'SWAPPED'}">selected</c:if>>Swapped</option>
                        <option value="UNAVAILABLE" <c:if test="${selectedStatus == 'UNAVAILABLE'}">selected</c:if>>Unavailable</option>
                    </select>
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn-search">Search</button>
                    <a class="btn-reset" href="${pageContext.request.contextPath}/books/list">Reset</a>
                </div>
            </div>
        </form>
    </div>

    <c:choose>
        <c:when test="${empty books}">
            <div class="empty-state">
                <h3>No books found</h3>
                <p>No books match your current criteria, or no books have been listed yet.</p>
                <p>
                    <a class="btn-primary" href="${pageContext.request.contextPath}/books/add">List the First Book</a>
                </p>
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
                    <th>Seller</th>
                    <th>Actions</th>
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
                        <td><c:out value="${book.seller != null ? book.seller.name : 'Unknown'}"/></td>
                        <td>
                            <div class="actions">
                                <a href="${pageContext.request.contextPath}/books/details?id=${book.id}">Details</a>
                                <c:if test="${empty authenticatedSeller or (book.seller != null and authenticatedSeller.id == book.seller.id)}">
                                    <a href="${pageContext.request.contextPath}/books/edit?id=${book.id}">Edit</a>
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/books/delete"
                                          style="margin:0; display:inline;"
                                          onsubmit="return confirm('Are you sure you want to delete this book?');">
                                        <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                                        <input type="hidden" name="id" value="<c:out value='${book.id}'/>">
                                        <input type="hidden" name="source" value="list">
                                        <button type="submit" class="btn-delete-inline">Delete</button>
                                    </form>
                                </c:if>
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
