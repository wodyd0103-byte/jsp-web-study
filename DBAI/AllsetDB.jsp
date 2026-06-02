<%--examtable에 데이터 insert하는 jsp파일--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>TBL 값넣기</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content">
<%
    String msg = "실습 데이터 9건이 입력되었습니다.";
    String note = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
        Statement stmt = conn.createStatement();
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('나연', 209901, 95, 100, 95);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('정연', 209902, 95, 95, 95);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('모모', 209903, 100, 100, 100);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('지효', 209904, 100, 95, 90);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('사나', 209905, 80, 100, 70);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('미나', 209906, 100, 100, 70);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('다현', 209907, 70, 70, 70);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('채영', 209908, 80, 75, 72);");
        stmt.execute("insert into examtable (name, studentid, kor, eng, mat) values ('쯔위', 209909, 78, 79, 82);");
        stmt.close();
        conn.close();
    } catch (SQLException e) {
        msg = "데이터가 이미 존재합니다.";
        note = "같은 학번(PK)의 데이터가 있어 입력하지 않았습니다. 전체조회로 확인해 보세요.";
    }
%>
    <div class="status is-insert">
        <div class="badge">&#43;</div>
        <h1>실습 데이터 입력</h1>
        <p><%= msg %></p>
        <% if (note != null) { %><div class="note"><%= note %></div><% } %>
    </div>
</body>
</html>
