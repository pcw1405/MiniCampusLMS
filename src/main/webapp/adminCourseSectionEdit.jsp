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

    String sectionIdParam = request.getParameter("id");
    if (sectionIdParam == null || sectionIdParam.trim().isEmpty()) {
%>
        <script>
            alert("수정할 개설강좌를 선택하세요.");
            history.back();
        </script>
<%
        return;
    }

    int sectionId = 0;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String courseCode = "";
    String courseName = "";
    String semesterLabel = "";
    int sectionNo = 0;
    String professorName = "";
    String dayOfWeek = "";
    String startTime = "";
    String endTime = "";
    String roomName = "";
    int capacity = 0;
    String status = "OPEN";

    try {
        sectionId = Integer.parseInt(sectionIdParam);

        conn = DBUtil.getConnection();
        String sql =
            "SELECT cs.id, cs.course_id, cs.semester_id, c.course_code, c.course_name, " +
            "s.year, s.term, cs.section_no, cs.professor_name, cs.day_of_week, cs.start_time, " +
            "cs.end_time, cs.room_name, cs.capacity, cs.status " +
            "FROM course_sections cs " +
            "JOIN courses c ON cs.course_id = c.id " +
            "JOIN semesters s ON cs.semester_id = s.id " +
            "WHERE cs.id = ?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, sectionId);
        rs = pstmt.executeQuery();

        if (!rs.next()) {
%>
            <script>
                alert("존재하지 않는 개설강좌입니다.");
                history.back();
            </script>
<%
            return;
        }

        courseCode = rs.getString("course_code");
        courseName = rs.getString("course_name");
        semesterLabel = rs.getInt("year") + "년 " + rs.getString("term") + "학기";
        sectionNo = rs.getInt("section_no");
        professorName = rs.getString("professor_name");
        dayOfWeek = rs.getString("day_of_week");
        startTime = rs.getTime("start_time").toString();
        endTime = rs.getTime("end_time").toString();
        roomName = rs.getString("room_name");
        capacity = rs.getInt("capacity");
        status = rs.getString("status");

    } catch (Exception e) {
%>
        <script>
            alert("개설강좌 정보를 불러오지 못했습니다.");
            history.back();
        </script>
<%
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>개설강좌 수정</title>
</head>
<body>
<%@ include file="common/header.jsp" %>

<h2>개설강좌 수정</h2>

<form action="adminCourseSectionEditAction.jsp" method="post">
    <input type="hidden" name="sectionId" value="<%= sectionId %>">

    <table border="1" width="800">
        <tr>
            <th width="180">과목</th>
            <td><%= HtmlUtil.escape(courseCode) %> - <%= HtmlUtil.escape(courseName) %></td>
        </tr>
        <tr>
            <th>학기</th>
            <td><%= HtmlUtil.escape(semesterLabel) %></td>
        </tr>
        <tr>
            <th>분반</th>
            <td><input type="number" name="sectionNo" min="1" value="<%= sectionNo %>" required></td>
        </tr>
        <tr>
            <th>교수명</th>
            <td><input type="text" name="professorName" style="width:95%;" value="<%= HtmlUtil.escape(professorName) %>" required></td>
        </tr>
        <tr>
            <th>요일</th>
            <td>
                <select name="dayOfWeek" required>
                    <option value="MON" <%= "MON".equals(dayOfWeek) ? "selected" : "" %>>월</option>
                    <option value="TUE" <%= "TUE".equals(dayOfWeek) ? "selected" : "" %>>화</option>
                    <option value="WED" <%= "WED".equals(dayOfWeek) ? "selected" : "" %>>수</option>
                    <option value="THU" <%= "THU".equals(dayOfWeek) ? "selected" : "" %>>목</option>
                    <option value="FRI" <%= "FRI".equals(dayOfWeek) ? "selected" : "" %>>금</option>
                    <option value="SAT" <%= "SAT".equals(dayOfWeek) ? "selected" : "" %>>토</option>
                    <option value="SUN" <%= "SUN".equals(dayOfWeek) ? "selected" : "" %>>일</option>
                </select>
            </td>
        </tr>
        <tr>
            <th>시작 시간</th>
            <td><input type="time" name="startTime" value="<%= HtmlUtil.escape(startTime) %>" required></td>
        </tr>
        <tr>
            <th>종료 시간</th>
            <td><input type="time" name="endTime" value="<%= HtmlUtil.escape(endTime) %>" required></td>
        </tr>
        <tr>
            <th>강의실</th>
            <td><input type="text" name="roomName" style="width:95%;" value="<%= HtmlUtil.escape(roomName) %>" required></td>
        </tr>
        <tr>
            <th>정원</th>
            <td><input type="number" name="capacity" min="1" value="<%= capacity %>" required></td>
        </tr>
        <tr>
            <th>상태</th>
            <td>
                <select name="status" required>
                    <option value="OPEN" <%= "OPEN".equals(status) ? "selected" : "" %>>OPEN</option>
                    <option value="CLOSED" <%= "CLOSED".equals(status) ? "selected" : "" %>>CLOSED</option>
                    <option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>CANCELLED</option>
                </select>
            </td>
        </tr>
    </table>

    <br>
    <input type="submit" value="수정 완료">
    <a href="adminCourseList.jsp">목록으로</a>
</form>

</body>
</html>
