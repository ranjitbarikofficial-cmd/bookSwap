<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${historyRequests == null and empty authRequired}">
    <c:redirect url="/swaps/history"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Swap History | BookSwap</title>
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
            max-width: 1120px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .card {
            background: white;
            padding: 24px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            margin-bottom: 26px;
        }
        .btn {
            display: inline-block;
            padding: 9px 16px;
            border-radius: 6px;
            border: 0;
            font-weight: 600;
            font-size: 0.88rem;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-primary { background: #2457d6; color: white; }
        .btn-complete { background: #0f766e; color: white; }
        .btn-secondary { background: #e2e8f0; color: #1e293b; }
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
            margin-top: 12px;
        }
        th, td {
            padding: 12px 14px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
            vertical-align: middle;
        }
        th {
            background: #f8fafc;
            font-weight: 700;
            font-size: 0.86rem;
            color: #475569;
        }
        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 700;
        }
        .badge-accepted { background: #dbeafe; color: #1e40af; }
        .badge-completed { background: #dcfce7; color: #166534; }
        .badge-rejected { background: #fee2e2; color: #991b1b; }
        .empty-text {
            color: #64748b;
            padding: 14px 0;
            margin: 0;
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
        <a href="${pageContext.request.contextPath}/swaps/requests">Swap Requests</a>
        <a href="${pageContext.request.contextPath}/swaps/history">Swap History</a>
    </div>
</div>

<div class="container">
    <div class="header-row">
        <div>
            <h1 style="margin:0;">Swap History</h1>
            <c:if test="${not empty authenticatedSeller}">
                <p style="margin:6px 0 0 0; color:#475569;">
                    Showing accepted, completed, and rejected swap requests for
                    <strong><c:out value="${authenticatedSeller.name}"/></strong>
                </p>
            </c:if>
        </div>
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/swaps/requests">
            &larr; Back to Swap Requests
        </a>
    </div>

    <c:if test="${param.completed == 'true'}">
        <div class="alert-success">
            Swap request #<c:out value="${param.requestId}"/> marked as <strong>COMPLETED</strong>! Both books are now marked as <strong>SWAPPED</strong>.
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert-error"><c:out value="${error}"/></div>
    </c:if>

    <c:choose>
        <c:when test="${authRequired}">
            <div class="card">
                <h3>Authentication Required</h3>
                <p>
                    Please sign in or list a book under your seller profile to view your swap history.
                </p>
                <div style="display:flex; gap:10px; margin-top:16px;">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/books/add">Add a Book to Activate Seller Session</a>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/books/list">Browse Books</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card">
                <h3 style="margin-top:0;">Processed Exchanges &amp; Requests</h3>
                <c:choose>
                    <c:when test="${empty historyRequests}">
                        <p class="empty-text">
                            No accepted, completed, or rejected swap requests yet.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Role</th>
                                <th>Counterparty</th>
                                <th>Offered Book</th>
                                <th>Requested Book</th>
                                <th>Status</th>
                                <th>Updated At</th>
                                <th>Action</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="item" items="${historyRequests}">
                                <tr>
                                    <td>#<c:out value="${item.id}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${authenticatedSeller.id == item.requester.id}">
                                                Sent by You
                                            </c:when>
                                            <c:otherwise>
                                                Received by You
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${authenticatedSeller.id == item.requester.id}">
                                                <strong><c:out value="${item.owner.name}"/></strong>
                                                <br>
                                                <span style="font-size:0.82rem; color:#64748b;">
                                                    <c:out value="${item.owner.email}"/>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <strong><c:out value="${item.requester.name}"/></strong>
                                                <br>
                                                <span style="font-size:0.82rem; color:#64748b;">
                                                    <c:out value="${item.requester.email}"/>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/books/details?id=${item.offeredBook.id}">
                                            <strong><c:out value="${item.offeredBook.title}"/></strong>
                                        </a>
                                        <br>
                                        <span style="font-size:0.82rem; color:#64748b;">
                                            Book Status: <c:out value="${item.offeredBook.status}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/books/details?id=${item.requestedBook.id}">
                                            <strong><c:out value="${item.requestedBook.title}"/></strong>
                                        </a>
                                        <br>
                                        <span style="font-size:0.82rem; color:#64748b;">
                                            Book Status: <c:out value="${item.requestedBook.status}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.status == 'ACCEPTED'}">
                                                <span class="badge badge-accepted">ACCEPTED (RESERVED)</span>
                                            </c:when>
                                            <c:when test="${item.status == 'COMPLETED'}">
                                                <span class="badge badge-completed">COMPLETED</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-rejected"><c:out value="${item.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:out value="${not empty item.updatedAt ? item.updatedAt : item.createdAt}"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.status == 'ACCEPTED'}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/swaps/complete"
                                                      style="margin:0;"
                                                      onsubmit="return confirm('Confirm that both books have been exchanged and complete this swap?');">
                                                    <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                                                    <input type="hidden" name="requestId" value="<c:out value='${item.id}'/>">
                                                    <input type="hidden" name="source" value="history">
                                                    <button type="submit" class="btn btn-complete">Complete Exchange</button>
                                                </form>
                                            </c:when>
                                            <c:when test="${item.status == 'COMPLETED'}">
                                                <span style="color:#166534; font-weight:600; font-size:0.85rem;">Exchange Completed</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#64748b; font-size:0.85rem;">Closed</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>
