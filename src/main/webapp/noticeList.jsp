<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="util.HtmlUtil" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 목록</title>
</head>
<body>
<%@ include file="common/header.jsp" %>
<h2>공지사항</h2>
<%
    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("keyword");

    if (keyword == null) {
        keyword = "";
    }
%>

<form action="noticeList.jsp" method="get">
    <input type="text" name="keyword" value="<%= HtmlUtil.escape(keyword) %>" placeholder="제목 또는 내용 검색">
    <input type="submit" value="검색">
    <a href="noticeList.jsp">전체보기</a>
</form>

<br>
<table border="1" width="700">
    <tr>
        <th>번호</th>
        <th>제목</th>
        <th>작성자</th>
        <th>작성일</th>
    </tr>

<%


    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
    	Class.forName("com.mysql.cj.jdbc.Driver");

    	conn = DBUtil.getConnection();

    	String sql =
    		    "SELECT n.id, n.title, n.created_at, u.name AS writer_name " +
    		    "FROM notice n " +
    		    "JOIN users u ON n.writer_id = u.id ";

    		if (!keyword.trim().equals("")) {
    		    sql += "WHERE n.title LIKE ? OR n.content LIKE ? ";
    		}

    		sql += "ORDER BY n.id DESC";

    		pstmt = conn.prepareStatement(sql);

    		if (!keyword.trim().equals("")) {
    		    pstmt.setString(1, "%" + keyword + "%");
    		    pstmt.setString(2, "%" + keyword + "%");
    		}

    		rs = pstmt.executeQuery();

        while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td>
            <a href="noticeDetail.jsp?id=<%= rs.getInt("id") %>">
		        <%= HtmlUtil.escape(rs.getString("title")) %>
		    </a>
        </td>
	<td><%= HtmlUtil.escape(rs.getString("writer_name")) %></td>
	<td><%= HtmlUtil.escape(rs.getString("created_at")) %></td>
    </tr>
<%
        }

    } catch (Exception e) {
    	  out.println("<tr><td colspan='4'>처리 중 오류가 발생했습니다.</td></tr>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

</table>

<br>
<br>
<%
	String detailLoginRole = (String) session.getAttribute("loginRole");
	
	if ("ADMIN".equals(detailLoginRole)) {
%>
        <a href="noticeWrite.jsp">공지사항 작성</a>
<%
    }
%>
<a href="main.jsp">메인으로</a>


</body>
</html>