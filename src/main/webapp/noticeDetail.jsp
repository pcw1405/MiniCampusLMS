<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 상세보기</title>
</head>
<body>
<%@ include file="./common/header.jsp" %>
<h2>공지사항 상세보기</h2>

<%
    String id = request.getParameter("id");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
    	Class.forName("com.mysql.cj.jdbc.Driver");

    	conn = DBUtil.getConnection();

        String sql = "SELECT id, title, content, writer_id, created_at FROM notice WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(id));

        rs = pstmt.executeQuery();

        if (rs.next()) {
%>

<table border="1" width="700">
    <tr>
        <th width="150">번호</th>
        <td><%= rs.getInt("id") %></td>
    </tr>
    <tr>
        <th>제목</th>
        <td><%= rs.getString("title") %></td>
    </tr>
    <tr>
        <th>작성자 ID</th>
        <td><%= rs.getInt("writer_id") %></td>
    </tr>
    <tr>
        <th>작성일</th>
        <td><%= rs.getTimestamp("created_at") %></td>
    </tr>
    <tr>
        <th>내용</th>
        <td style="height:150px;">
            <%= rs.getString("content").replace("\n", "<br>") %>
        </td>
    </tr>
</table>

<br>
<a href="noticeList.jsp">목록으로</a>
<a href="main.jsp">메인으로</a>

<%
    loginRole = (String) session.getAttribute("loginRole");

    if ("ADMIN".equals(loginRole)) {
%>
        <a href="noticeEdit.jsp?id=<%= rs.getInt("id") %>">수정</a>
         <form action="noticeDeleteAction.jsp" method="post" style="display:inline;"
              onsubmit="return confirm('정말 삭제하시겠습니까?');">
            <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
            <input type="submit" value="삭제">
        </form>
<%
    }
%>
<%
        } else {
%>
            <p>해당 공지사항을 찾을 수 없습니다.</p>
            <a href="noticeList.jsp">목록으로</a>
<%
        }

    } catch (Exception e) {
        out.println("오류 발생: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    
%>

</body>
</html>