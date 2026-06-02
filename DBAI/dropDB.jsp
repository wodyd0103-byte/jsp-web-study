<%--examtable을 삭제하는 jsp파일--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>TBL 삭제</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content">
<%
    String msg = "examtable 테이블이 삭제되었습니다.";
    String note = null;
    Class.forName("com.mysql.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    try {
        Statement k14_stmt = k14_conn.createStatement();
        k14_stmt.executeUpdate("drop table examtable;");
        k14_stmt.close();
    } catch (SQLException e) {
        msg = "삭제할 테이블이 없습니다.";
        note = "examtable 테이블이 존재하지 않습니다. 먼저 TBL 생성을 해주세요.";
    } finally {
        k14_conn.close();
    }
%>
    <div class="status is-drop">
        <div class="badge">&#10005;</div>
        <h1>테이블 지우기 OK</h1>
        <p><%= msg %></p>
        <% if (note != null) { %><div class="note"><%= note %></div><% } %>
    </div>
</body>
</html>
