<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String keyword = request.getParameter("keyword");
    if (keyword == null) {
        keyword = "";
    }

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    int resultCount = 0;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 검색 - 취약 버전</title>
</head>
<body>

<h2>공지사항 검색 - 취약 버전</h2>

<p style="color:red;">
    이 페이지는 SQL Injection 실습을 위해 일부러 취약하게 만든 페이지입니다.
</p>

<form method="get" action="noticeSearch_vuln.jsp">
    검색어:
    <input type="text" name="keyword" value="<%= keyword %>">
    <button type="submit">검색</button>
</form>

<hr>

<%
    try {
        conn = DBUtil.getConnection();

        /*
            취약한 코드:
            사용자가 입력한 keyword를 SQL 문자열에 직접 붙이고 있음.
        */
        String sql =
            "SELECT id, title, content, created_at " +
            "FROM notice " +
            "WHERE title LIKE '%" + keyword + "%' " +
            "OR content LIKE '%" + keyword + "%' " +
            "ORDER BY id DESC";

        out.println("<p><b>실행된 SQL:</b></p>");
        out.println("<pre>" + sql + "</pre>");

        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);
%>

<table border="1" cellpadding="8">
    <tr>
        <th>ID</th>
        <th>제목</th>
        <th>작성일</th>
    </tr>

<%
        while (rs.next()) {
            resultCount++;
%>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getString("title") %></td>
        <td><%= rs.getString("created_at") %></td>
    </tr>
<%
        }
%>
</table>

<p>
    검색 결과 수:
    <b><%= resultCount %></b>
</p>

<%
    } catch (Exception e) {
%>
    <h3 style="color:red;">오류 발생</h3>
    <pre><%= e.toString() %></pre>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (stmt != null) try { stmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<hr>
<a href="noticeList.jsp">공지사항 목록으로</a>

</body>
</html>