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

    String sectionIdParam = request.getParameter("sectionId");
    String sectionNoParam = request.getParameter("sectionNo");
    String professorName = request.getParameter("professorName");
    String dayOfWeek = request.getParameter("dayOfWeek");
    String startTime = request.getParameter("startTime");
    String endTime = request.getParameter("endTime");
    String roomName = request.getParameter("roomName");
    String capacityParam = request.getParameter("capacity");
    String status = request.getParameter("status");

    if (sectionIdParam == null || sectionIdParam.trim().isEmpty() ||
        sectionNoParam == null || sectionNoParam.trim().isEmpty() ||
        professorName == null || professorName.trim().isEmpty() ||
        dayOfWeek == null || dayOfWeek.trim().isEmpty() ||
        startTime == null || startTime.trim().isEmpty() ||
        endTime == null || endTime.trim().isEmpty() ||
        roomName == null || roomName.trim().isEmpty() ||
        capacityParam == null || capacityParam.trim().isEmpty() ||
        status == null || status.trim().isEmpty()) {
%>
        <script>
            alert("모든 항목을 입력하세요.");
            history.back();
        </script>
<%
        return;
    }

    int sectionId;
    int sectionNo;
    int capacity;

    try {
        sectionId = Integer.parseInt(sectionIdParam);
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

    if (sectionNo < 1) {
%>
        <script>
            alert("분반은 1 이상이어야 합니다.");
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

    if (!("OPEN".equals(status) || "CLOSED".equals(status) || "CANCELLED".equals(status))) {
%>
        <script>
            alert("상태 값이 올바르지 않습니다.");
            history.back();
        </script>
<%
        return;
    }

    professorName = professorName.trim();
    roomName = roomName.trim();

    Connection conn = null;
    PreparedStatement selectStmt = null;
    PreparedStatement duplicateStmt = null;
    PreparedStatement updateStmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        String selectSql = "SELECT course_id, semester_id FROM course_sections WHERE id = ?";
        selectStmt = conn.prepareStatement(selectSql);
        selectStmt.setInt(1, sectionId);
        rs = selectStmt.executeQuery();

        if (!rs.next()) {
%>
            <script>
                alert("존재하지 않는 개설강좌입니다.");
                history.back();
            </script>
<%
            return;
        }

        int courseId = rs.getInt("course_id");
        int semesterId = rs.getInt("semester_id");

        String duplicateSql = "SELECT id FROM course_sections WHERE course_id = ? AND semester_id = ? AND section_no = ? AND id <> ?";
        duplicateStmt = conn.prepareStatement(duplicateSql);
        duplicateStmt.setInt(1, courseId);
        duplicateStmt.setInt(2, semesterId);
        duplicateStmt.setInt(3, sectionNo);
        duplicateStmt.setInt(4, sectionId);
        rs.close();
        rs = duplicateStmt.executeQuery();

        if (rs.next()) {
%>
            <script>
                alert("이미 동일 과목/학기/분반이 등록되어 있습니다.");
                history.back();
            </script>
<%
            return;
        }

        String updateSql =
            "UPDATE course_sections SET section_no = ?, professor_name = ?, day_of_week = ?, " +
            "start_time = ?, end_time = ?, room_name = ?, capacity = ?, status = ? WHERE id = ?";

        updateStmt = conn.prepareStatement(updateSql);
        updateStmt.setInt(1, sectionNo);
        updateStmt.setString(2, professorName);
        updateStmt.setString(3, dayOfWeek);
        updateStmt.setString(4, startTime);
        updateStmt.setString(5, endTime);
        updateStmt.setString(6, roomName);
        updateStmt.setInt(7, capacity);
        updateStmt.setString(8, status);
        updateStmt.setInt(9, sectionId);

        int result = updateStmt.executeUpdate();

        if (result > 0) {
%>
            <script>
                alert("개설강좌가 수정되었습니다.");
                location.href = "adminCourseList.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("개설강좌 수정에 실패했습니다.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
%>
        <script>
            alert("개설강좌 수정 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (duplicateStmt != null) try { duplicateStmt.close(); } catch (Exception e) {}
        if (selectStmt != null) try { selectStmt.close(); } catch (Exception e) {}
        if (updateStmt != null) try { updateStmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
