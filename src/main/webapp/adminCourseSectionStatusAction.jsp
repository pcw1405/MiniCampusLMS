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
    String status = request.getParameter("status");

    if (sectionIdParam == null || sectionIdParam.trim().isEmpty() ||
        status == null || status.trim().isEmpty()) {
%>
        <script>
            alert("수정할 강좌와 상태를 선택하세요.");
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
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();
        String sql = "UPDATE course_sections SET status = ? WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, status);
        pstmt.setInt(2, sectionId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
%>
            <script>
                alert("개설강좌 상태가 변경되었습니다.");
                location.href = "adminCourseList.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("상태 변경에 실패했습니다.");
                history.back();
            </script>
<%
        }
    } catch (Exception e) {
%>
        <script>
            alert("상태 변경 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
