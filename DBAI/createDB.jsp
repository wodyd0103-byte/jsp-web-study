<%--examtable을 생성하는 jsp파일--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>TBL 생성</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content">
<%
    String msg = "examtable 테이블이 생성되었습니다.";
    String note = null;
    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    try {
        Statement stmt = conn.createStatement();
        stmt.execute("create table examtable (" +
            "name varchar (20)," +
            "studentid int not null primary key, " +
            "kor int," +
            "eng int," +
            "mat int) DEFAULT CHARSET=utf8;");
        stmt.close();
        conn.close();
    } catch (SQLException e) {
        msg = "테이블이 이미 존재합니다.";
        note = "이미 만들어진 테이블이 있어 새로 생성하지 않았습니다.";
    }
%>
    <div class="status is-create">
        <div class="badge">&#10003;</div>
        <h1>테이블 만들기 OK</h1>
        <p><%= msg %></p>
        <% if (note != null) { %><div class="note"><%= note %></div><% } %>
    </div>
</body>
</html>
