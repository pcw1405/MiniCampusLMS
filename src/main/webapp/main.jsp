<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    Integer loginUserId = (Integer) session.getAttribute("loginUserId");
    String loginName = (String) session.getAttribute("loginName");
    String loginRole = (String) session.getAttribute("loginRole");

    if (loginUserId == null) {
%>
        <script>
            alert("로그인이 필요합니다.");
            location.href = "login.jsp";
        </script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>메인 - Mini Campus LMS</title>
</head>
<body>
    <h1>Mini Campus LMS 메인</h1>

    <p><b><%= loginName %></b>님, 로그인되었습니다.</p>
    <p>권한: <%= loginRole %></p>

    <ul>
        <li><a href="mypage.jsp">마이페이지</a></li>
        <li><a href="noticeList.jsp">공지사항</a></li>
        <% if ("STUDENT".equals(loginRole)) { %>
        <li><a href="studentCourseList.jsp">개설강좌 조회</a></li>
        <li><a href="studentEnrollmentList.jsp">수강내역</a></li>
        <% } %>
        <% if ("ADMIN".equals(loginRole)) { %>
        <li><a href="admin.jsp">관리자 페이지</a></li>
        <% } %>
        <li><a href="logout.jsp">로그아웃</a></li>
    </ul>
</body>
</html>