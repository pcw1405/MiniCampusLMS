<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%
    // No global request encoding filter was found in the project, so set it here before reading parameters.
    request.setCharacterEncoding("UTF-8");

    HttpSession httpSession = request.getSession(false);
    String loginRole = (httpSession == null) ? null : (String) httpSession.getAttribute("loginRole");
    Object loginUserIdObj = (httpSession == null) ? null : httpSession.getAttribute("loginUserId");

    if (httpSession == null || loginRole == null || loginUserIdObj == null) {
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
            alert("관리자만 공지사항을 수정할 수 있습니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    String idParam = request.getParameter("id");
    String title = request.getParameter("title");
    String content = request.getParameter("content");

    if (idParam == null || idParam.trim().isEmpty()) {
%>
        <script>
            alert("잘못된 접근입니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    if (title == null || content == null) {
%>
        <script>
            alert("제목과 내용을 모두 입력하세요.");
            history.back();
        </script>
<%
        return;
    }

    title = title.trim();
    content = content.trim();

    if (title.isEmpty() || content.isEmpty()) {
%>
        <script>
            alert("제목과 내용을 모두 입력하세요.");
            history.back();
        </script>
<%
        return;
    }

    int noticeId;
    try {
        noticeId = Integer.parseInt(idParam.trim());
    } catch (NumberFormatException e) {
        log("Invalid notice id parameter: " + idParam, e);
%>
        <script>
            alert("잘못된 공지 번호입니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    int loginUserId;
    try {
        loginUserId = Integer.parseInt(String.valueOf(loginUserIdObj));
    } catch (NumberFormatException e) {
        log("Invalid loginUserId in session: " + loginUserIdObj, e);
%>
        <script>
            alert("로그인 정보가 올바르지 않습니다.");
            location.href = "login.jsp";
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        String sql = "UPDATE notice SET title = ?, content = ?, updated_at = NOW() WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title);
        pstmt.setString(2, content);
        pstmt.setInt(3, noticeId);

        int updatedRows = pstmt.executeUpdate();

        if (updatedRows == 1) {
%>
            <script>
                alert("공지사항이 수정되었습니다.");
                location.href = "noticeDetail.jsp?id=<%= noticeId %>";
            </script>
<%
        } else {
%>
            <script>
                alert("수정할 공지사항을 찾을 수 없습니다.");
                location.href = "noticeList.jsp";
            </script>
<%
        }
    } catch (Exception e) {
        log("noticeUpdateAction error: " + e.getMessage(), e);
%>
        <script>
            alert("공지사항 수정 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) { }
        if (conn != null) try { conn.close(); } catch (Exception e) { }
    }
%>
