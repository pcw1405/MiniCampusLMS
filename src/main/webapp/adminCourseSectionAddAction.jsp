<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

<%
    request.setCharacterEncoding("UTF-8");

    String loginRole = (String) session.getAttribute("loginRole");
    Object loginUserId = session.getAttribute("loginUserId");

    if (loginUserId == null || loginRole == null) {
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

    String courseIdParam = request.getParameter("courseId");
    String semesterIdParam = request.getParameter("semesterId");
    String sectionNoParam = request.getParameter("sectionNo");
    String professorName = request.getParameter("professorName");
    String dayOfWeek = request.getParameter("dayOfWeek");
    String startTime = request.getParameter("startTime");
    String endTime = request.getParameter("endTime");
    String roomName = request.getParameter("roomName");
    String capacityParam = request.getParameter("capacity");

    if (courseIdParam == null || courseIdParam.trim().isEmpty() ||
        semesterIdParam == null || semesterIdParam.trim().isEmpty() ||
        sectionNoParam == null || sectionNoParam.trim().isEmpty() ||
        professorName == null || professorName.trim().isEmpty() ||
        dayOfWeek == null || dayOfWeek.trim().isEmpty() ||
        startTime == null || startTime.trim().isEmpty() ||
        endTime == null || endTime.trim().isEmpty() ||
        roomName == null || roomName.trim().isEmpty() ||
        capacityParam == null || capacityParam.trim().isEmpty()) {
%>
        <script>
            alert("모든 필수 항목을 입력하세요.");
            history.back();
        </script>
<%
        return;
    }

    int courseId;
    int semesterId;
    int sectionNo;
    int capacity;

    try {
        courseId = Integer.parseInt(courseIdParam);
        semesterId = Integer.parseInt(semesterIdParam);
        sectionNo = Integer.parseInt(sectionNoParam);
        capacity = Integer.parseInt(capacityParam);
    } catch (Exception e) {
%>
        <script>
            alert("입력값 형식이 올바르지 않습니다.");
            history.back();
        </script>
<%
        return;
    }

    if (capacity < 1) {
%>
        <script>
            alert("정원은 1 이상이어야 합니다.");
            history.back();
        </script>
<%
        return;
    }

    if (startTime.compareTo(endTime) >= 0) {
%>
        <script>
            alert("종료 시간은 시작 시간보다 늦어야 합니다.");
            history.back();
        </script>
<%
        return;
    }

    professorName = professorName.trim();
    roomName = roomName.trim();

    Connection conn = null;
    PreparedStatement checkStmt = null;
    PreparedStatement insertStmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        String checkSql = "SELECT id FROM course_sections WHERE course_id = ? AND semester_id = ? AND section_no = ?";
        checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setInt(1, courseId);
        checkStmt.setInt(2, semesterId);
        checkStmt.setInt(3, sectionNo);
        rs = checkStmt.executeQuery();

        if (rs.next()) {
%>
            <script>
                alert("이미 동일 과목/학기/분반이 등록되어 있습니다.");
                history.back();
            </script>
<%
            return;
        }

        String insertSql = "INSERT INTO course_sections (course_id, semester_id, section_no, professor_name, day_of_week, start_time, end_time, room_name, capacity, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'OPEN', NOW())";
        insertStmt = conn.prepareStatement(insertSql);
        insertStmt.setInt(1, courseId);
        insertStmt.setInt(2, semesterId);
        insertStmt.setInt(3, sectionNo);
        insertStmt.setString(4, professorName);
        insertStmt.setString(5, dayOfWeek);
        insertStmt.setString(6, startTime);
        insertStmt.setString(7, endTime);
        insertStmt.setString(8, roomName);
        insertStmt.setInt(9, capacity);

        int result = insertStmt.executeUpdate();

        if (result > 0) {
%>
            <script>
                alert("개설강좌가 등록되었습니다.");
                location.href = "adminCourseList.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("개설강좌 등록에 실패했습니다.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
%>
        <script>
            alert("개설강좌 등록 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (checkStmt != null) try { checkStmt.close(); } catch (Exception e) {}
        if (insertStmt != null) try { insertStmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
