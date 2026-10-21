<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

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
            alert("학생만 수강취소할 수 있습니다.");
            location.href = "main.jsp";
        </script>
<%
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

    String enrollmentIdParam = request.getParameter("enrollmentId");
    int enrollmentId;
    try {
        if (enrollmentIdParam == null || enrollmentIdParam.trim().isEmpty()) {
            throw new NumberFormatException();
        }
        enrollmentId = Integer.parseInt(enrollmentIdParam.trim());
        if (enrollmentId <= 0) {
            throw new NumberFormatException();
        }
    } catch (NumberFormatException e) {
%>
        <script>
            alert("잘못된 수강내역 정보입니다.");
            location.href = "studentEnrollmentList.jsp";
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement studentStmt = null;
    PreparedStatement enrollmentStmt = null;
    PreparedStatement cancelStmt = null;
    ResultSet studentRs = null;
    ResultSet enrollmentRs = null;

    try {
        conn = DBUtil.getConnection();

        String studentSql =
            "SELECT id FROM students WHERE user_id = ?";
        studentStmt = conn.prepareStatement(studentSql);
        studentStmt.setInt(1, loginUserId);
        studentRs = studentStmt.executeQuery();

        if (!studentRs.next()) {
%>
            <script>
                alert("학생 정보를 찾을 수 없습니다.");
                location.href = "main.jsp";
            </script>
<%
            return;
        }

        int studentId = studentRs.getInt("id");
        studentRs.close();
        studentRs = null;
        studentStmt.close();
        studentStmt = null;

        String enrollmentSql =
            "SELECT status FROM enrollments WHERE id = ? AND student_id = ?";
        enrollmentStmt = conn.prepareStatement(enrollmentSql);
        enrollmentStmt.setInt(1, enrollmentId);
        enrollmentStmt.setInt(2, studentId);
        enrollmentRs = enrollmentStmt.executeQuery();

        if (!enrollmentRs.next()) {
%>
            <script>
                alert("수강내역을 찾을 수 없거나 조회 권한이 없습니다.");
                location.href = "studentEnrollmentList.jsp";
            </script>
<%
            return;
        }

        String enrollmentStatus = enrollmentRs.getString("status");
        enrollmentRs.close();
        enrollmentRs = null;
        enrollmentStmt.close();
        enrollmentStmt = null;

        if ("CANCELED".equals(enrollmentStatus)) {
%>
            <script>
                alert("이미 취소된 수강내역입니다.");
                location.href = "studentEnrollmentList.jsp";
            </script>
<%
            return;
        }

        if (!"ENROLLED".equals(enrollmentStatus)) {
%>
            <script>
                alert("현재 취소할 수 없는 수강내역입니다.");
                location.href = "studentEnrollmentList.jsp";
            </script>
<%
            return;
        }

        String cancelSql =
            "UPDATE enrollments " +
            "SET status = 'CANCELED', canceled_at = NOW() " +
            "WHERE id = ? AND student_id = ? AND status = 'ENROLLED'";
        cancelStmt = conn.prepareStatement(cancelSql);
        cancelStmt.setInt(1, enrollmentId);
        cancelStmt.setInt(2, studentId);
        int updatedCount = cancelStmt.executeUpdate();

        if (updatedCount == 1) {
%>
            <script>
                alert("수강취소가 완료되었습니다.");
                location.href = "studentEnrollmentList.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("취소할 수강내역을 찾을 수 없습니다. 이미 취소되었거나 취소 권한이 없습니다.");
                location.href = "studentEnrollmentList.jsp";
            </script>
<%
        }
    } catch (Exception e) {
        application.log("학생 수강취소 처리 중 오류가 발생했습니다.", e);
%>
        <script>
            alert("수강취소 처리 중 오류가 발생했습니다.");
            location.href = "studentEnrollmentList.jsp";
        </script>
<%
    } finally {
        if (enrollmentRs != null) try { enrollmentRs.close(); } catch (Exception e) {}
        if (studentRs != null) try { studentRs.close(); } catch (Exception e) {}
        if (cancelStmt != null) try { cancelStmt.close(); } catch (Exception e) {}
        if (enrollmentStmt != null) try { enrollmentStmt.close(); } catch (Exception e) {}
        if (studentStmt != null) try { studentStmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
