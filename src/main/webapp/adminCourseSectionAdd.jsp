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

    if (!"ADMIN".equals(loginRole)) {
%>
        <script>
            alert("관리자만 접근할 수 있습니다.");
            location.href = "main.jsp";
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        String sql = "SELECT id, course_code, course_name FROM courses ORDER BY course_code";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>개설강좌 등록</title>
</head>
<body>
<jsp:include page="common/header.jsp" />

<h2>개설강좌 등록</h2>

<form action="adminCourseSectionAddAction.jsp" method="post">
    <table border="1" width="800">
        <tr>
            <th width="180">과목 선택</th>
            <td>
                <select name="courseId" required>
                    <option value="">과목 선택</option>
<%
        while (rs.next()) {
%>
                    <option value="<%= rs.getInt("id") %>"><%= rs.getString("course_code") %> - <%= rs.getString("course_name") %></option>
<%
        }
%>
                </select>
            </td>
        </tr>
        <tr>
            <th>학기 선택</th>
            <td>
                <select name="semesterId" required>
                    <option value="">학기 선택</option>
<%
        if (conn != null) {
            rs.close();
            pstmt.close();

            String semesterSql = "SELECT id, year, term FROM semesters ORDER BY year DESC, term";
            pstmt = conn.prepareStatement(semesterSql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
%>
                    <option value="<%= rs.getInt("id") %>"><%= rs.getInt("year") %>년 <%= rs.getString("term") %>학기</option>
<%
            }
        }
%>
                </select>
            </td>
        </tr>
        <tr>
            <th>분반</th>
            <td>
                <input type="number" name="sectionNo" min="1" required>
            </td>
        </tr>
        <tr>
            <th>교수명</th>
            <td>
                <input type="text" name="professorName" style="width:95%;" required>
            </td>
        </tr>
        <tr>
            <th>요일</th>
            <td>
                <select name="dayOfWeek" required>
                    <option value="">요일 선택</option>
                    <option value="MON">월</option>
                    <option value="TUE">화</option>
                    <option value="WED">수</option>
                    <option value="THU">목</option>
                    <option value="FRI">금</option>
                    <option value="SAT">토</option>
                    <option value="SUN">일</option>
                </select>
            </td>
        </tr>
        <tr>
            <th>시작 시간</th>
            <td>
                <input type="time" name="startTime" required>
            </td>
        </tr>
        <tr>
            <th>종료 시간</th>
            <td>
                <input type="time" name="endTime" required>
            </td>
        </tr>
        <tr>
            <th>강의실</th>
            <td>
                <input type="text" name="roomName" style="width:95%;" required>
            </td>
        </tr>
        <tr>
            <th>정원</th>
            <td>
                <input type="number" name="capacity" min="1" required>
            </td>
        </tr>
    </table>

    <br>
    <input type="submit" value="등록">
    <a href="adminCourseList.jsp">목록으로</a>
</form>

</body>
</html>
<%
    } catch (Exception e) {
%>
    <script>
        alert("과목/학기 정보를 불러오는 중 오류가 발생했습니다.");
        history.back();
    </script>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
