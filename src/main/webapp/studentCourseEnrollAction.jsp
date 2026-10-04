<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="util.HtmlUtil" %>

<%
    request.setCharacterEncoding("UTF-8");

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
            alert("학생만 수강신청할 수 있습니다.");
            location.href = "main.jsp";
        </script>
<%
        return;
    }

    String sectionIdParam = request.getParameter("sectionId");
    if (sectionIdParam == null || sectionIdParam.trim().isEmpty()) {
%>
        <script>
            alert("신청할 강좌를 선택하세요.");
            history.back();
        </script>
<%
        return;
    }

    int sectionId;
    try {
        sectionId = Integer.parseInt(sectionIdParam);
    } catch (Exception e) {
%>
        <script>
            alert("잘못된 강좌 정보입니다.");
            history.back();
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement selectStudentStmt = null;
    PreparedStatement sectionStmt = null;
    PreparedStatement duplicateStmt = null;
    PreparedStatement insertStmt = null;
    ResultSet studentRs = null;
    ResultSet sectionRs = null;
    ResultSet duplicateRs = null;

    try {
        conn = DBUtil.getConnection();

        String studentSql =
            "SELECT s.id AS student_id " +
            "FROM students s " +
            "WHERE s.user_id = ?";

        selectStudentStmt = conn.prepareStatement(studentSql);
        selectStudentStmt.setInt(1, loginUserId);
        studentRs = selectStudentStmt.executeQuery();

        if (!studentRs.next()) {
%>
            <script>
                alert("학생 정보를 찾을 수 없습니다.");
                location.href = "main.jsp";
            </script>
<%
            return;
        }

        int studentId = studentRs.getInt("student_id");

        String sectionSql =
            "SELECT cs.id, cs.status, cs.capacity, " +
            "(SELECT COUNT(*) FROM enrollments e WHERE e.section_id = cs.id AND e.status = 'ENROLLED') AS current_count " +
            "FROM course_sections cs " +
            "WHERE cs.id = ?";

        sectionStmt = conn.prepareStatement(sectionSql);
        sectionStmt.setInt(1, sectionId);
        sectionRs = sectionStmt.executeQuery();

        if (!sectionRs.next()) {
%>
            <script>
                alert("존재하지 않는 강좌입니다.");
                history.back();
            </script>
<%
            return;
        }

        String sectionStatus = sectionRs.getString("status");
        int currentCount = sectionRs.getInt("current_count");
        int capacity = sectionRs.getInt("capacity");

        if (!"OPEN".equals(sectionStatus)) {
%>
            <script>
                alert("현재 신청 가능한 상태가 아닙니다.");
                location.href = "studentCourseList.jsp";
            </script>
<%
            return;
        }

        if (currentCount >= capacity) {
%>
            <script>
                alert("정원이 마감된 강좌입니다.");
                location.href = "studentCourseList.jsp";
            </script>
<%
            return;
        }

        String duplicateSql =
            "SELECT id FROM enrollments WHERE student_id = ? AND section_id = ?";

        duplicateStmt = conn.prepareStatement(duplicateSql);
        duplicateStmt.setInt(1, studentId);
        duplicateStmt.setInt(2, sectionId);
        duplicateRs = duplicateStmt.executeQuery();

        if (duplicateRs.next()) {
%>
            <script>
                alert("이미 신청한 강좌입니다.");
                location.href = "studentCourseList.jsp";
            </script>
<%
            return;
        }

        String insertSql =
            "INSERT INTO enrollments (student_id, section_id, status, enrolled_at, canceled_at) VALUES (?, ?, 'ENROLLED', NOW(), NULL)";

        insertStmt = conn.prepareStatement(insertSql);
        insertStmt.setInt(1, studentId);
        insertStmt.setInt(2, sectionId);

        int insertCount = insertStmt.executeUpdate();

        if (insertCount > 0) {
%>
            <script>
                alert("수강신청이 완료되었습니다.");
                location.href = "studentCourseList.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("수강신청에 실패했습니다.");
                history.back();
            </script>
<%
        }

    } catch (SQLException e) {
%>
        <script>
            alert("수강신청 처리 중 오류가 발생했습니다.");
            location.href = "studentCourseList.jsp";
        </script>
<%
    } catch (Exception e) {
%>
        <script>
            alert("수강신청 처리 중 오류가 발생했습니다.");
            location.href = "studentCourseList.jsp";
        </script>
<%
    } finally {
        if (duplicateRs != null) try { duplicateRs.close(); } catch (Exception e) {}
        if (sectionRs != null) try { sectionRs.close(); } catch (Exception e) {}
        if (studentRs != null) try { studentRs.close(); } catch (Exception e) {}
        if (insertStmt != null) try { insertStmt.close(); } catch (Exception e) {}
        if (duplicateStmt != null) try { duplicateStmt.close(); } catch (Exception e) {}
        if (sectionStmt != null) try { sectionStmt.close(); } catch (Exception e) {}
        if (selectStudentStmt != null) try { selectStudentStmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
