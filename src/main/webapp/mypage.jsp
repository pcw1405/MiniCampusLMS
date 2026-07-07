<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    Integer loginUserId = (Integer) session.getAttribute("loginUserId");
    String loginUsername = (String) session.getAttribute("loginUsername");
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
<title>마이페이지 - Mini Campus LMS</title>
</head>
<body>
    <h1>마이페이지</h1>

    <table border="1">
        <tr>
            <th>회원번호</th>
            <td><%= loginUserId %></td>
        </tr>
        <tr>
            <th>아이디</th>
            <td><%= loginUsername %></td>
        </tr>
        <tr>
            <th>이름</th>
            <td><%= loginName %></td>
        </tr>
        <tr>
            <th>권한</th>
            <td><%= loginRole %></td>
        </tr>
    </table>

    <p><a href="main.jsp">메인으로</a></p>
    <p><a href="logout.jsp">로그아웃</a></p>
</body>
</html>