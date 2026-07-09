<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="util.HtmlUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String keyword = request.getParameter("keyword");
    if (keyword == null) {
        keyword = "";
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement logPstmt = null;
    ResultSet rs = null;

    int resultCount = 0;
    String trueFalseResult = "UNKNOWN";

    String sql =
        "SELECT id, title, content, created_at " +
        "FROM notice " +
        "WHERE title LIKE ? OR content LIKE ? " +
        "ORDER BY id DESC";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 검색 - 안전 버전</title>
</head>
<body>

<h2>공지사항 검색 - 안전 버전</h2>

<p style="color:blue;">
    PreparedStatement와 HTML Escape를 적용한 안전 버전입니다.
</p>

<form method="get" action="noticeSearch_safe.jsp">
    검색어:
    <input type="text" name="keyword" value="<%= HtmlUtil.escape(keyword) %>" style="width:450px;">
    <button type="submit">검색</button>
</form>

<hr>

<%
    try {
        conn = DBUtil.getConnection();

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + keyword + "%");
        pstmt.setString(2, "%" + keyword + "%");

        rs = pstmt.executeQuery();
%>

<h3>검색 결과</h3>

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
        <td><%= HtmlUtil.escape(rs.getString("title")) %></td>
        <td><%= HtmlUtil.escape(rs.getString("created_at")) %></td>
    </tr>
<%
        }

        if (resultCount > 0) {
            trueFalseResult = "TRUE";
        } else {
            trueFalseResult = "FALSE";
        }

        String logSql =
            "INSERT INTO security_test_log " +
            "(vuln_type, target_page, parameter_name, payload, executed_sql, result_count, true_false_result, memo) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        logPstmt = conn.prepareStatement(logSql);
        logPstmt.setString(1, "Security Regression Test");
        logPstmt.setString(2, "noticeSearch_safe.jsp");
        logPstmt.setString(3, "keyword");
        logPstmt.setString(4, keyword);
        logPstmt.setString(5, "PreparedStatement 적용: SQL 구조 비노출");
        logPstmt.setInt(6, resultCount);
        logPstmt.setString(7, trueFalseResult);
        logPstmt.setString(8, "SQLi/XSS 대응 후 재검증");
        logPstmt.executeUpdate();
%>

</table>

<p>검색 결과 수: <b><%= resultCount %></b></p>
<p>판단 결과: <b><%= trueFalseResult %></b></p>

<hr>

<h3>보안 적용 내용</h3>
<ul>
    <li>SQL Injection 대응: PreparedStatement 사용</li>
    <li>XSS 대응: HtmlUtil.escape() 적용</li>
    <li>정보 노출 대응: 실행 SQL과 상세 오류를 화면에 출력하지 않음</li>
</ul>

<%
    } catch (Exception e) {
%>
    <h3 style="color:red;">처리 중 오류가 발생했습니다.</h3>
    <p>관리자에게 문의하세요.</p>
<%
    } finally {
        if (logPstmt != null) try { logPstmt.close(); } catch(Exception e) {}
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<hr>
<a href="noticeSearch_vuln.jsp">취약 버전으로 이동</a> |
<a href="noticeList.jsp">공지사항 목록</a>

</body>
</html>