<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String role = (String) session.getAttribute("loginRole");
    Object userIdObj = session.getAttribute("loginUserId");

    if (role == null || userIdObj == null) {
%>
        <script>
            alert("로그인이 필요합니다.");
            location.href = "login.jsp";
        </script>
<%
        return;
    }

    if (!"ADMIN".equals(role)) {
%>
        <script>
            alert("관리자만 공지사항을 작성할 수 있습니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    String title = request.getParameter("title");
    String content = request.getParameter("content");

    if (title == null || title.trim().equals("") || content == null || content.trim().equals("")) {
%>
        <script>
            alert("제목과 내용을 모두 입력하세요.");
            history.back();
        </script>
<%
        return;
    }

    int writerId = Integer.parseInt(String.valueOf(userIdObj));

    String dbUrl = "jdbc:mysql://localhost:3306/mini_lms?serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String dbUser = "root";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "INSERT INTO notice (title, content, writer_id, created_at) VALUES (?, ?, ?, NOW())";
        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, title);
        pstmt.setString(2, content);
        pstmt.setInt(3, writerId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
%>
            <script>
                alert("공지사항이 등록되었습니다.");
                location.href = "noticeList.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("공지사항 등록에 실패했습니다.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
        out.println("오류 발생: " + e.getMessage());
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>