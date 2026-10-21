<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String headerLoginName = (String) session.getAttribute("loginName");
    String headerLoginRole = (String) session.getAttribute("loginRole");
%>

<div style="border-bottom:1px solid #ccc; padding:10px; margin-bottom:20px;">
    <strong>Mini Campus LMS</strong>
    |
    <a href="main.jsp">메인</a>
    |
    <a href="noticeList.jsp">공지사항</a>
    |
    <a href="mypage.jsp">마이페이지</a>

<%
    if (headerLoginName != null) {
%>
    |
    <span><%= headerLoginName %>님</span>

    <% if ("ADMIN".equals(headerLoginRole)) { %>
        <span>[관리자]</span>
    <% } else if ("STUDENT".equals(headerLoginRole)) { %>
        <span>[학생]</span>
        |
        <a href="studentCourseList.jsp">개설강좌 조회</a>
        |
        <a href="studentEnrollmentList.jsp">수강내역</a>
    <% } %>

    |
    <a href="logout.jsp">로그아웃</a>
<%
    } else {
%>
    |
    <a href="login.jsp">로그인</a>
<%
    }
%>
</div>