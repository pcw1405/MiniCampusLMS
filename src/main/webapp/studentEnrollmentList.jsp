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

    if (!"STUDENT".equals(loginRole)) {
%>
        <script>
            alert("학생만 접근할 수 있습니다.");
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
    <title>내 수강내역</title>
</head>
<body>
<%@ include file="common/header.jsp" %>

<h2>내 수강내역</h2>

<table border="1" width="1400">
    <tr>
        <th>과목코드</th>
        <th>과목명</th>
        <th>분반</th>
        <th>교수명</th>
        <th>요일</th>
        <th>시작시간</th>
        <th>종료시간</th>
        <th>강의실</th>
        <th>학년도 / 학기</th>
        <th>수강 상태</th>
        <th>신청일시</th>
        <th>취소일시</th>
        <th>취소</th>
    </tr>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();
        String sql =
            "SELECT e.id AS enrollment_id, c.course_code, c.course_name, cs.section_no, cs.professor_name, " +
            "cs.day_of_week, cs.start_time, cs.end_time, cs.room_name, " +
            "sem.year AS semester_year, sem.term AS semester_term, " +
            "e.status, e.enrolled_at, e.canceled_at " +
            "FROM enrollments e " +
            "JOIN students st ON e.student_id = st.id " +
            "JOIN course_sections cs ON e.section_id = cs.id " +
            "JOIN courses c ON cs.course_id = c.id " +
            "JOIN semesters sem ON cs.semester_id = sem.id " +
            "WHERE st.user_id = ? " +
            "ORDER BY e.enrolled_at DESC, e.id DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, loginUserId);
        rs = pstmt.executeQuery();

        boolean hasEnrollment = false;
        while (rs.next()) {
            hasEnrollment = true;
            String status = rs.getString("status");
            String statusLabel = "ENROLLED".equals(status) ? "수강 중"
                : "CANCELED".equals(status) ? "취소 완료" : status;
            String term = rs.getString("semester_term");
            Timestamp canceledAt = rs.getTimestamp("canceled_at");
            String termLabel;
            if ("1".equals(term) || "2".equals(term)) {
                termLabel = term + "학기";
            } else if ("SUMMER".equals(term)) {
                termLabel = "여름학기";
            } else if ("WINTER".equals(term)) {
                termLabel = "겨울학기";
            } else {
                termLabel = term;
            }
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
        <td><%= rs.getInt("semester_year") %> / <%= HtmlUtil.escape(termLabel) %></td>
        <td><%= HtmlUtil.escape(statusLabel) %></td>
        <td><%= HtmlUtil.escape(String.valueOf(rs.getTimestamp("enrolled_at"))) %></td>
        <td><%= canceledAt == null ? "-" : HtmlUtil.escape(String.valueOf(canceledAt)) %></td>
        <td>
<%
            if ("ENROLLED".equals(status)) {
%>
            <form action="studentCourseCancelAction.jsp" method="post" style="margin:0;">
                <input type="hidden" name="enrollmentId" value="<%= rs.getInt("enrollment_id") %>">
                <button type="submit">수강취소</button>
            </form>
<%
            } else {
%>
            -
<%
            }
%>
        </td>
    </tr>
<%
        }

        if (!hasEnrollment) {
%>
    <tr>
        <td colspan="13">수강내역이 없습니다.</td>
    </tr>
<%
        }
    } catch (Exception e) {
        application.log("학생 수강내역 조회 중 오류가 발생했습니다.", e);
%>
    <tr>
        <td colspan="13">수강내역을 불러오는 중 오류가 발생했습니다.</td>
    </tr>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
</table>

<p>
    <a href="main.jsp">메인으로</a>
</p>

</body>
</html>
