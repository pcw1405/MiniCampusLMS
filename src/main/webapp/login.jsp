<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // 이미 로그인한 사용자는 메인으로 이동
    if (session.getAttribute("loginUserId") != null) {
        response.sendRedirect("main.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mini Campus LMS - 로그인</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f6fa;
            margin: 0;
            padding: 0;
        }

        .login-container {
            width: 360px;
            margin: 100px auto;
            padding: 30px;
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 8px;
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-top: 15px;
            margin-bottom: 5px;
            font-weight: bold;
        }

        input {
            width: 100%;
            padding: 10px;
            box-sizing: border-box;
        }

        button {
            width: 100%;
            margin-top: 25px;
            padding: 10px;
            background-color: #2f80ed;
            color: white;
            border: none;
            cursor: pointer;
            font-size: 15px;
        }

        button:hover {
            background-color: #1c63c7;
        }

        .test-account {
            margin-top: 20px;
            padding: 10px;
            background-color: #f1f1f1;
            font-size: 13px;
        }

        .footer-link {
            margin-top: 15px;
            text-align: center;
        }

        .footer-link a {
            text-decoration: none;
            color: #2f80ed;
        }
    </style>
</head>
<body>

<div class="login-container">
    <h2>Mini Campus LMS 로그인</h2>

    <form action="loginAction.jsp" method="post">
        <label for="username">아이디</label>
        <input type="text" id="username" name="username" required>

        <label for="password">비밀번호</label>
        <input type="password" id="password" name="password" required>

        <button type="submit">로그인</button>
    </form>

    <div class="test-account">
        <strong>테스트 계정</strong><br>
        관리자: admin / 1234<br>
        학생: student / 1234
    </div>

    <div class="footer-link">
        <a href="index.jsp">처음으로</a>
    </div>
</div>

</body>
</html>