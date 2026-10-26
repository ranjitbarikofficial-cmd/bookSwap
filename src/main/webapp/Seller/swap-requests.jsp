<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${sentRequests == null and receivedRequests == null and empty authRequired}">
    <c:redirect url="/swaps/requests"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Swap Requests | BookSwap</title>
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
        .tab-bar {
            display: flex;
            gap: 10px;
            margin-bottom: 22px;
            flex-wrap: wrap;
        }
        .tab-link {
            padding: 9px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            background: #e2e8f0;
            color: #1e293b;
        }
        .tab-link.active {
            background: #2457d6;
            color: white;
        }
        .card {
            background: white;
            padding: 24px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            margin-bottom: 26px;
        }
        .card h2, .card h3 {
            margin-top: 0;
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr auto;
            gap: 14px;
            align-items: end;
        }
        .form-grid label {
            display: block;
            font-weight: 600;
            font-size: 0.88rem;
            margin-bottom: 6px;
        }
        .form-grid select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            box-sizing: border-box;
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
        .btn-success { background: #16a34a; color: white; }
        .btn-danger { background: #dc2626; color: white; }
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
        .badge-pending { background: #fef3c7; color: #92400e; }
        .badge-accepted { background: #dbeafe; color: #1e40af; }
        .badge-completed { background: #dcfce7; color: #166534; }
        .badge-rejected { background: #fee2e2; color: #991b1b; }
        .actions-inline {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }
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
            <h1 style="margin:0;">Swap Requests</h1>
            <c:if test="${not empty authenticatedSeller}">
                <p style="margin:6px 0 0 0; color:#475569;">
                    Signed in as <strong><c:out value="${authenticatedSeller.name}"/></strong>
                    (<c:out value="${authenticatedSeller.email}"/>)
                </p>
            </c:if>
        </div>
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/swaps/history">
            View Swap History &rarr;
        </a>
    </div>

    <c:if test="${param.created == 'true'}">
        <div class="alert-success">
            Swap request #<c:out value="${param.requestId}"/> sent successfully!
        </div>
    </c:if>
    <c:if test="${param.accepted == 'true'}">
        <div class="alert-success">
            Swap request #<c:out value="${param.requestId}"/> accepted! Both books are now <strong>RESERVED</strong> until the exchange is completed.
        </div>
    </c:if>
    <c:if test="${param.rejected == 'true'}">
        <div class="alert-success">
            Swap request #<c:out value="${param.requestId}"/> rejected. Book availability remains unchanged.
        </div>
    </c:if>
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
                    Swap requests are tied to your authenticated seller session on the server.
                    Please sign in or list a book under your seller profile first.
                </p>
                <div style="display:flex; gap:10px; margin-top:16px;">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/books/add">Add a Book to Activate Seller Session</a>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/books/list">Browse Books</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Create Swap Request Card -->
            <div class="card">
                <h3>Send a Direct Swap Request</h3>
                <p style="color:#475569; margin-top:0; margin-bottom:16px;">
                    Offer one of your <strong>AVAILABLE</strong> books in exchange for an <strong>AVAILABLE</strong> book owned by another seller.
                </p>

                <c:choose>
                    <c:when test="${empty myAvailableBooks}">
                        <p class="empty-text">
                            You currently have no <strong>AVAILABLE</strong> books to offer.
                            <a href="${pageContext.request.contextPath}/books/add">Add an available book</a> before sending a swap request.
                        </p>
                    </c:when>
                    <c:when test="${empty otherAvailableBooks}">
                        <p class="empty-text">
                            There are currently no <strong>AVAILABLE</strong> books from other sellers to request.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/swaps/create">
                            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                            <div class="form-grid">
                                <div>
                                    <label for="offeredBookId">Your Book to Offer</label>
                                    <select id="offeredBookId" name="offeredBookId" required>
                                        <option value="">-- Select one of your available books --</option>
                                        <c:forEach var="myBook" items="${myAvailableBooks}">
                                            <option value="${myBook.id}"
                                                    <c:if test="${preselectedOfferedBookId == myBook.id}">selected</c:if>>
                                                #<c:out value="${myBook.id}"/> - <c:out value="${myBook.title}"/>
                                                (<c:out value="${myBook.bookCondition}"/>)
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div>
                                    <label for="requestedBookId">Book You Want to Request</label>
                                    <select id="requestedBookId" name="requestedBookId" required>
                                        <option value="">-- Select another seller's available book --</option>
                                        <c:forEach var="otherBook" items="${otherAvailableBooks}">
                                            <option value="${otherBook.id}"
                                                    <c:if test="${preselectedRequestedBookId == otherBook.id}">selected</c:if>>
                                                #<c:out value="${otherBook.id}"/> - <c:out value="${otherBook.title}"/>
                                                — Owner: <c:out value="${otherBook.seller.name}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div>
                                    <button type="submit" class="btn btn-primary">Send Swap Request</button>
                                </div>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- View Tabs -->
            <div class="tab-bar">
                <a class="tab-link ${empty activeTab or activeTab == 'all' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/swaps/requests">
                    All Requests
                </a>
                <a class="tab-link ${activeTab == 'received' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/swaps/received">
                    Received Requests (<c:out value="${receivedRequests.size()}"/>)
                </a>
                <a class="tab-link ${activeTab == 'sent' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/swaps/sent">
                    Sent Requests (<c:out value="${sentRequests.size()}"/>)
                </a>
                <a class="tab-link"
                   href="${pageContext.request.contextPath}/swaps/history">
                    Swap History
                </a>
            </div>

            <!-- Received Requests -->
            <c:if test="${empty activeTab or activeTab == 'all' or activeTab == 'received'}">
                <div class="card">
                    <h3>Received Swap Requests (Incoming)</h3>
                    <c:choose>
                        <c:when test="${empty receivedRequests}">
                            <p class="empty-text">You have not received any swap requests yet.</p>
                        </c:when>
                        <c:otherwise>
                            <table>
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>From Seller</th>
                                    <th>Book Offered to You</th>
                                    <th>Your Requested Book</th>
                                    <th>Status</th>
                                    <th>Requested At</th>
                                    <th>Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="req" items="${receivedRequests}">
                                    <tr>
                                        <td>#<c:out value="${req.id}"/></td>
                                        <td>
                                            <strong><c:out value="${req.requester.name}"/></strong>
                                            <br>
                                            <span style="font-size:0.82rem; color:#64748b;">
                                                <c:out value="${req.requester.email}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/books/details?id=${req.offeredBook.id}">
                                                <strong><c:out value="${req.offeredBook.title}"/></strong>
                                            </a>
                                            <br>
                                            <span style="font-size:0.82rem; color:#64748b;">
                                                Book Status: <c:out value="${req.offeredBook.status}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/books/details?id=${req.requestedBook.id}">
                                                <strong><c:out value="${req.requestedBook.title}"/></strong>
                                            </a>
                                            <br>
                                            <span style="font-size:0.82rem; color:#64748b;">
                                                Book Status: <c:out value="${req.requestedBook.status}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.status == 'PENDING'}">
                                                    <span class="badge badge-pending">PENDING</span>
                                                </c:when>
                                                <c:when test="${req.status == 'ACCEPTED'}">
                                                    <span class="badge badge-accepted">ACCEPTED (RESERVED)</span>
                                                </c:when>
                                                <c:when test="${req.status == 'COMPLETED'}">
                                                    <span class="badge badge-completed">COMPLETED</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-rejected"><c:out value="${req.status}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${req.createdAt}"/></td>
                                        <td>
                                            <div class="actions-inline">
                                                <c:choose>
                                                    <c:when test="${req.status == 'PENDING'}">
                                                        <form method="post"
                                                              action="${pageContext.request.contextPath}/swaps/accept"
                                                              style="margin:0;">
                                                            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                                                            <input type="hidden" name="requestId" value="<c:out value='${req.id}'/>">
                                                            <button type="submit" class="btn btn-success">Accept</button>
                                                        </form>
                                                        <form method="post"
                                                              action="${pageContext.request.contextPath}/swaps/reject"
                                                              style="margin:0;">
                                                            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                                                            <input type="hidden" name="requestId" value="<c:out value='${req.id}'/>">
                                                            <button type="submit" class="btn btn-danger">Reject</button>
                                                        </form>
                                                    </c:when>
                                                    <c:when test="${req.status == 'ACCEPTED'}">
                                                        <form method="post"
                                                              action="${pageContext.request.contextPath}/swaps/complete"
                                                              style="margin:0;"
                                                              onsubmit="return confirm('Confirm that both books have been exchanged and complete this swap?');">
                                                            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                                                            <input type="hidden" name="requestId" value="<c:out value='${req.id}'/>">
                                                            <button type="submit" class="btn btn-complete">Complete Exchange</button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color:#64748b; font-size:0.85rem;">Processed</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- Sent Requests -->
            <c:if test="${empty activeTab or activeTab == 'all' or activeTab == 'sent'}">
                <div class="card">
                    <h3>Sent Swap Requests (Outgoing)</h3>
                    <c:choose>
                        <c:when test="${empty sentRequests}">
                            <p class="empty-text">You have not sent any swap requests yet.</p>
                        </c:when>
                        <c:otherwise>
                            <table>
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>To Book Owner</th>
                                    <th>Your Offered Book</th>
                                    <th>Requested Book</th>
                                    <th>Status</th>
                                    <th>Sent At</th>
                                    <th>Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="req" items="${sentRequests}">
                                    <tr>
                                        <td>#<c:out value="${req.id}"/></td>
                                        <td>
                                            <strong><c:out value="${req.owner.name}"/></strong>
                                            <br>
                                            <span style="font-size:0.82rem; color:#64748b;">
                                                <c:out value="${req.owner.email}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/books/details?id=${req.offeredBook.id}">
                                                <strong><c:out value="${req.offeredBook.title}"/></strong>
                                            </a>
                                            <br>
                                            <span style="font-size:0.82rem; color:#64748b;">
                                                Book Status: <c:out value="${req.offeredBook.status}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/books/details?id=${req.requestedBook.id}">
                                                <strong><c:out value="${req.requestedBook.title}"/></strong>
                                            </a>
                                            <br>
                                            <span style="font-size:0.82rem; color:#64748b;">
                                                Book Status: <c:out value="${req.requestedBook.status}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.status == 'PENDING'}">
                                                    <span class="badge badge-pending">PENDING</span>
                                                </c:when>
                                                <c:when test="${req.status == 'ACCEPTED'}">
                                                    <span class="badge badge-accepted">ACCEPTED (RESERVED)</span>
                                                </c:when>
                                                <c:when test="${req.status == 'COMPLETED'}">
                                                    <span class="badge badge-completed">COMPLETED</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-rejected"><c:out value="${req.status}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${req.createdAt}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.status == 'ACCEPTED'}">
                                                    <form method="post"
                                                          action="${pageContext.request.contextPath}/swaps/complete"
                                                          style="margin:0;"
                                                          onsubmit="return confirm('Confirm that both books have been exchanged and complete this swap?');">
                                                        <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                                                        <input type="hidden" name="requestId" value="<c:out value='${req.id}'/>">
                                                        <button type="submit" class="btn btn-complete">Complete Exchange</button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${req.status == 'PENDING'}">
                                                    <span style="color:#64748b; font-size:0.85rem;">Awaiting owner response</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#64748b; font-size:0.85rem;">Processed</span>
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
            </c:if>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>