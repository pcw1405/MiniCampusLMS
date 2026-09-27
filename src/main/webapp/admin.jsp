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

    if (!"ADMIN".equals(loginRole)) {
%>
        <script>
            alert("관리자만 접근할 수 있습니다.");
            location.href = "main.jsp";
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - Mini Campus LMS</title>
</head>
<body>
    <h1>관리자 페이지</h1>

    <p><b><%= loginName %></b> 관리자님, 환영합니다.</p>

    <h2>관리 기능</h2>
    <ul>
        <li><a href="adminCourseList.jsp">개설강좌 목록</a></li>
        <li>회원 관리</li>
        <li>공지사항 관리</li>
        <li>수강신청 관리</li>
    </ul>

    <p><a href="main.jsp">메인으로</a></p>
    <p><a href="logout.jsp">로그아웃</a></p>
</body>
</html>