<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
    	Class.forName("com.mysql.cj.jdbc.Driver");

    	conn = DBUtil.getConnection();

        String sql = "SELECT id, username, name, role FROM users WHERE username = ? AND password = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        pstmt.setString(2, password);

        rs = pstmt.executeQuery();

        if (rs.next()) {
            session.setAttribute("loginUserId", rs.getInt("id"));
            session.setAttribute("loginUsername", rs.getString("username"));
            session.setAttribute("loginName", rs.getString("name"));
            session.setAttribute("loginRole", rs.getString("role"));

            response.sendRedirect("main.jsp");
        } else {
%>
            <script>
                alert("아이디 또는 비밀번호가 올바르지 않습니다.");
                history.back();
            </script>
<%
        }
    } catch (Exception e) {
        out.println("<h3>로그인 처리 중 오류 발생</h3>");
        out.println("<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>