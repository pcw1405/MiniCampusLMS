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

    String sectionIdParam = request.getParameter("sectionId");
    if (sectionIdParam == null || sectionIdParam.trim().isEmpty()) {
%>
        <script>
            alert("수강생을 조회할 개설강좌를 선택하세요.");
            history.back();
        </script>
<%
        return;
    }

    int sectionId = 0;
    String courseCode = "";
    String courseName = "";
    int sectionNo = 0;
    String professorName = "";
    String dayOfWeek = "";
    String status = "";

    Connection conn = null;
    PreparedStatement sectionStmt = null;
    PreparedStatement studentStmt = null;
    ResultSet sectionRs = null;
    ResultSet studentRs = null;

    try {
        sectionId = Integer.parseInt(sectionIdParam);

        conn = DBUtil.getConnection();

        String sectionSql =
            "SELECT c.course_code, c.course_name, cs.section_no, cs.professor_name, cs.day_of_week, cs.status " +
            "FROM course_sections cs " +
            "JOIN courses c ON cs.course_id = c.id " +
            "WHERE cs.id = ?";

        sectionStmt = conn.prepareStatement(sectionSql);
        sectionStmt.setInt(1, sectionId);
        sectionRs = sectionStmt.executeQuery();

        if (!sectionRs.next()) {
%>
            <script>
                alert("존재하지 않는 개설강좌입니다.");
                history.back();
            </script>
<%
            return;
        }

        courseCode = sectionRs.getString("course_code");
        courseName = sectionRs.getString("course_name");
        sectionNo = sectionRs.getInt("section_no");
        professorName = sectionRs.getString("professor_name");
        dayOfWeek = sectionRs.getString("day_of_week");
        status = sectionRs.getString("status");

        String studentSql =
            "SELECT u.name AS student_name, u.username, s.student_number, e.enrolled_at " +
            "FROM enrollments e " +
            "JOIN students s ON e.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "WHERE e.section_id = ? AND e.status = 'ENROLLED' " +
            "ORDER BY u.name, u.username";

        studentStmt = conn.prepareStatement(studentSql);
        studentStmt.setInt(1, sectionId);
        studentRs = studentStmt.executeQuery();
    } catch (Exception e) {
%>
        <script>
            alert("수강생 목록을 불러오지 못했습니다.");
            history.back();
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>개설강좌 수강생 조회</title>
</head>
<body>
<%@ include file="common/header.jsp" %>

<h2>개설강좌 수강생 조회</h2>

<table border="1" width="900">
    <tr>
        <th width="180">과목</th>
        <td><%= HtmlUtil.escape(courseCode) %> - <%= HtmlUtil.escape(courseName) %></td>
    </tr>
    <tr>
        <th>분반</th>
        <td><%= sectionNo %></td>
    </tr>
    <tr>
        <th>교수</th>
        <td><%= HtmlUtil.escape(professorName) %></td>
    </tr>
    <tr>
        <th>요일</th>
        <td><%= HtmlUtil.escape(dayOfWeek) %></td>
    </tr>
    <tr>
        <th>상태</th>
        <td><%= HtmlUtil.escape(status) %></td>
    </tr>
</table>

<br>

<table border="1" width="900">
    <tr>
        <th>학생명</th>
        <th>아이디</th>
        <th>학번</th>
        <th>신청일</th>
    </tr>
<%
    boolean hasStudent = false;
    while (studentRs != null && studentRs.next()) {
        hasStudent = true;
%>
    <tr>
        <td><%= HtmlUtil.escape(studentRs.getString("student_name")) %></td>
        <td><%= HtmlUtil.escape(studentRs.getString("username")) %></td>
        <td><%= HtmlUtil.escape(studentRs.getString("student_number")) %></td>
        <td><%= studentRs.getTimestamp("enrolled_at") %></td>
    </tr>
<%
    }

    if (!hasStudent) {
%>
    <tr>
        <td colspan="4">현재 ENROLLED 상태의 수강생이 없습니다.</td>
    </tr>
<%
    }
%>
</table>

<p>
    <a href="adminCourseList.jsp">개설강좌 목록</a>
</p>

</body>
</html>
<%
    if (studentRs != null) try { studentRs.close(); } catch (Exception e) {}
    if (studentStmt != null) try { studentStmt.close(); } catch (Exception e) {}
    if (sectionRs != null) try { sectionRs.close(); } catch (Exception e) {}
    if (sectionStmt != null) try { sectionStmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
%>
