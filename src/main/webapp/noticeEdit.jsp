<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>


<%
    String loginRole = (String) session.getAttribute("loginRole");

    if (loginRole == null) {
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
            alert("관리자만 수정할 수 있습니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    String idParam = request.getParameter("id");

    if (idParam == null || idParam.trim().equals("")) {
%>
        <script>
            alert("잘못된 접근입니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    int noticeId = Integer.parseInt(idParam);

  
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
    	Class.forName("com.mysql.cj.jdbc.Driver");

    	conn = DBUtil.getConnection();

        String sql = "SELECT id, title, content FROM notice WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, noticeId);

        rs = pstmt.executeQuery();

        if (!rs.next()) {
%>
            <script>
                alert("해당 공지사항을 찾을 수 없습니다.");
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
    <title>공지사항 수정</title>
</head>
<body>

<jsp:include page="common/header.jsp" />

<h2>공지사항 수정</h2>

<form action="noticeUpdateAction.jsp" method="post">
    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">

    <table border="1" width="700">
        <tr>
            <th width="150">제목</th>
            <td>
                <input type="text" name="title" value="<%= rs.getString("title") %>" style="width:95%;" required>
            </td>
        </tr>
        <tr>
            <th>내용</th>
            <td>
                <textarea name="content" rows="10" style="width:95%;" required><%= rs.getString("content") %></textarea>
            </td>
        </tr>
    </table>

    <br>
    <input type="submit" value="수정">
    <a href="noticeDetail.jsp?id=<%= rs.getInt("id") %>">취소</a>
</form>

</body>
</html>

<%
    } catch (Exception e) {
        out.println("오류 발생: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>