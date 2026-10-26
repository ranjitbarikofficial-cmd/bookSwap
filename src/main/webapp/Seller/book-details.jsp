<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Book Details | BookSwap</title>
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
            max-width: 780px;
            margin: 35px auto;
            padding: 0 20px;
        }
        .card {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
        }
        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 0.82rem;
            font-weight: 700;
            background: #e0f2fe;
            color: #0369a1;
        }
        .detail-grid {
            display: grid;
            grid-template-columns: 160px 1fr;
            row-gap: 14px;
            column-gap: 18px;
            margin-top: 22px;
            border-top: 1px solid #e2e8f0;
            padding-top: 20px;
        }
        .detail-label {
            font-weight: 700;
            color: #475569;
        }
        .description-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 14px;
            white-space: pre-wrap;
        }
        .action-bar {
            margin-top: 26px;
            padding-top: 18px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }
        .btn {
            display: inline-block;
            padding: 10px 18px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.92rem;
            border: 0;
            cursor: pointer;
        }
        .btn-primary { background: #2457d6; color: white; }
        .btn-secondary { background: #e2e8f0; color: #1e293b; }
        .btn-danger { background: #dc2626; color: white; }
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
            padding: 16px 20px;
            border-radius: 8px;
            margin-bottom: 18px;
        }
        .confirm-box {
            margin-top: 20px;
            padding: 18px;
            background: #fff1f2;
            border: 1px solid #fecdd3;
            border-radius: 8px;
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
    <c:if test="${param.updated == 'true'}">
        <div class="alert-success">Book details updated successfully!</div>
    </c:if>

    <c:choose>
        <c:when test="${empty book}">
            <div class="card">
                <h2>
                    <c:choose>
                        <c:when test="${notFound}">Book Not Found (404)</c:when>
                        <c:otherwise>Invalid Book Request</c:otherwise>
                    </c:choose>
                </h2>
                <div class="alert-error">
                    <c:out value="${not empty error ? error : 'The requested book could not be found.'}"/>
                </div>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/books/list">
                    &larr; Back to Browse Books
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:16px;">
                    <div>
                        <h1 style="margin:0 0 6px 0;"><c:out value="${book.title}"/></h1>
                        <p style="margin:0; color:#64748b;">
                            by <strong><c:out value="${not empty book.author ? book.author : 'Unknown Author'}"/></strong>
                        </p>
                    </div>
                    <span class="badge"><c:out value="${book.status}"/></span>
                </div>

                <div class="detail-grid">
                    <div class="detail-label">Book ID</div>
                    <div>#<c:out value="${book.id}"/></div>

                    <div class="detail-label">Category</div>
                    <div><c:out value="${book.category != null ? book.category.name : 'Uncategorized'}"/></div>

                    <div class="detail-label">Condition</div>
                    <div><c:out value="${not empty book.bookCondition ? book.bookCondition : 'Not specified'}"/></div>

                    <div class="detail-label">Location</div>
                    <div><c:out value="${not empty book.location ? book.location : 'Not specified'}"/></div>

                    <div class="detail-label">Description</div>
                    <div class="description-box"><c:out value="${not empty book.description ? book.description : 'No description provided.'}"/></div>

                    <div class="detail-label">Listed By</div>
                    <div>
                        <c:choose>
                            <c:when test="${book.seller != null}">
                                <strong><c:out value="${book.seller.name}"/></strong>
                                <c:if test="${not empty book.seller.email}">
                                    <br><span style="color:#64748b; font-size:0.9rem;">Email: <c:out value="${book.seller.email}"/></span>
                                </c:if>
                                <c:if test="${not empty book.seller.phone}">
                                    <br><span style="color:#64748b; font-size:0.9rem;">Phone: <c:out value="${book.seller.phone}"/></span>
                                </c:if>
                            </c:when>
                            <c:otherwise>Unknown Seller</c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="action-bar">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/books/list">&larr; All Books</a>
                    <c:if test="${not isOwner and book.status == 'AVAILABLE'}">
                        <a class="btn btn-primary"
                           href="${pageContext.request.contextPath}/swaps/requests?requestedBookId=${book.id}">
                            Request Swap for This Book
                        </a>
                    </c:if>
                    <c:if test="${isOwner}">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/books/edit?id=${book.id}">Edit Book</a>
                        <c:if test="${param.confirmDelete != 'true'}">
                            <a class="btn btn-danger"
                               href="${pageContext.request.contextPath}/books/details?id=${book.id}&amp;confirmDelete=true">
                                Delete Book
                            </a>
                        </c:if>
                    </c:if>
                </div>

                <c:if test="${isOwner and param.confirmDelete == 'true'}">
                    <div class="confirm-box">
                        <h3 style="margin-top:0; color:#9f1239;">Confirm Book Deletion</h3>
                        <p>Are you sure you want to permanently delete <strong><c:out value="${book.title}"/></strong>? This action cannot be undone.</p>
                        <form method="post" action="${pageContext.request.contextPath}/books/delete" style="display:flex; gap:10px;">
                            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                            <input type="hidden" name="id" value="<c:out value='${book.id}'/>">
                            <button type="submit" class="btn btn-danger">Yes, Permanently Delete</button>
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/books/details?id=${book.id}">Cancel</a>
                        </form>
                    </div>
                </c:if>
            </div>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>
