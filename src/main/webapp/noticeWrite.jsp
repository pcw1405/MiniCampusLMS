<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.DBUtil" %>
<%
    Integer loginUserId = (Integer) session.getAttribute("loginUserId");
    String loginName = (String) session.getAttribute("loginName");
    String loginRole = (String) session.getAttribute("loginRole");
%>
<%
    String role = (String) session.getAttribute("loginRole");

    if (role == null) {
%>
        <script>
            alert("로그인이 필요합니다.");
            location.href = "login.jsp";
        </script>
<%
        return;
    }

    if (!"ADMIN".equals(role)) {
%>
        <script>
            alert("관리자만 공지사항을 작성할 수 있습니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 작성</title>
</head>
<body>

<jsp:include page="common/header.jsp" />

<h2>공지사항 작성</h2>

<form action="noticeWriteAction.jsp" method="post">
    <table border="1" width="700">
        <tr>
            <th width="150">제목</th>
            <td>
                <input type="text" name="title" style="width:95%;" required>
            </td>
        </tr>
        <tr>
            <th>내용</th>
            <td>
                <textarea name="content" rows="10" style="width:95%;" required></textarea>
            </td>
        </tr>
    </table>

    <br>
    <input type="submit" value="등록">
    <a href="noticeList.jsp">목록으로</a>
</form>

</body>
</html>