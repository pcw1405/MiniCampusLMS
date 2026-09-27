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

    String courseCode = request.getParameter("courseCode");
    String courseName = request.getParameter("courseName");
    String description = request.getParameter("description");

    if (courseCode == null || courseCode.trim().isEmpty() ||
        courseName == null || courseName.trim().isEmpty()) {
%>
        <script>
            alert("과목코드와 과목명은 필수입니다.");
            history.back();
        </script>
<%
        return;
    }

    courseCode = courseCode.trim();
    courseName = courseName.trim();
    if (description == null) {
        description = "";
    }

    Connection conn = null;
    PreparedStatement checkStmt = null;
    PreparedStatement insertStmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        String checkSql = "SELECT id FROM courses WHERE course_code = ?";
        checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setString(1, courseCode);
        rs = checkStmt.executeQuery();

        if (rs.next()) {
%>
            <script>
                alert("이미 등록된 과목코드입니다: <%= courseCode %>");
                history.back();
            </script>
<%
            return;
        }

        String insertSql = "INSERT INTO courses (course_code, course_name, description, created_at) VALUES (?, ?, ?, NOW())";
        insertStmt = conn.prepareStatement(insertSql);
        insertStmt.setString(1, courseCode);
        insertStmt.setString(2, courseName);
        insertStmt.setString(3, description);

        int result = insertStmt.executeUpdate();

        if (result > 0) {
%>
            <script>
                alert("과목이 등록되었습니다.");
                location.href = "adminCourseList.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("과목 등록에 실패했습니다.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
%>
        <script>
            alert("과목 등록 중 오류가 발생했습니다.");
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
