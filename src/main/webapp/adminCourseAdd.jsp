<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer loginUserId = (Integer) session.getAttribute("loginUserId");
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
    <title>과목 등록</title>
</head>
<body>
<jsp:include page="common/header.jsp" />

<h2>과목 등록</h2>

<form action="adminCourseAddAction.jsp" method="post">
    <table border="1" width="700">
        <tr>
            <th width="150">과목코드</th>
            <td>
                <input type="text" name="courseCode" style="width:95%;" required>
            </td>
        </tr>
        <tr>
            <th>과목명</th>
            <td>
                <input type="text" name="courseName" style="width:95%;" required>
            </td>
        </tr>
        <tr>
            <th>설명</th>
            <td>
                <textarea name="description" rows="6" style="width:95%;"></textarea>
            </td>
        </tr>
    </table>

    <br>
    <input type="submit" value="등록">
    <a href="adminCourseList.jsp">목록으로</a>
</form>

</body>
</html>
