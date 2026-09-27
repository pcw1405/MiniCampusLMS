<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

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

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

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
%>
        <script>
            alert("공지사항 처리 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>