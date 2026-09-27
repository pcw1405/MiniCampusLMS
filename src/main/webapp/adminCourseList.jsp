<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="util.HtmlUtil" %>

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
    <title>개설강좌 목록</title>
</head>
<body>
<%@ include file="common/header.jsp" %>

<h2>개설강좌 목록</h2>

<table border="1" width="1100">
    <tr>
        <th>과목코드</th>
        <th>과목명</th>
        <th>분반</th>
        <th>교수</th>
        <th>요일</th>
        <th>시작</th>
        <th>종료</th>
        <th>강의실</th>
        <th>정원</th>
        <th>상태</th>
    </tr>

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        String sql =
            "SELECT c.course_code, c.course_name, cs.section_no, cs.professor_name, " +
            "cs.day_of_week, cs.start_time, cs.end_time, cs.room_name, cs.capacity, cs.status " +
            "FROM course_sections cs " +
            "JOIN semesters s ON cs.semester_id = s.id " +
            "JOIN courses c ON cs.course_id = c.id " +
            "WHERE s.year = 2026 AND s.term = '1' " +
            "ORDER BY c.course_code, cs.section_no";

        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
%>
    <tr>
        <td><%= HtmlUtil.escape(rs.getString("course_code")) %></td>
        <td><%= HtmlUtil.escape(rs.getString("course_name")) %></td>
        <td><%= rs.getInt("section_no") %></td>
        <td><%= HtmlUtil.escape(rs.getString("professor_name")) %></td>
        <td><%= HtmlUtil.escape(rs.getString("day_of_week")) %></td>
        <td><%= rs.getTime("start_time") %></td>
        <td><%= rs.getTime("end_time") %></td>
        <td><%= HtmlUtil.escape(rs.getString("room_name")) %></td>
        <td><%= rs.getInt("capacity") %></td>
        <td><%= HtmlUtil.escape(rs.getString("status")) %></td>
    </tr>
<%
        }

    } catch (Exception e) {
%>
    <tr>
        <td colspan="10">개설강좌 목록을 불러오는 중 오류가 발생했습니다.</td>
    </tr>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
</table>

<p>
    <a href="adminCourseAdd.jsp">과목 등록</a>
    |
    <a href="adminCourseSectionAdd.jsp">개설강좌 등록</a>
</p>

<p><a href="admin.jsp">관리자 페이지로</a></p>
<p><a href="main.jsp">메인으로</a></p>

</body>
</html>
