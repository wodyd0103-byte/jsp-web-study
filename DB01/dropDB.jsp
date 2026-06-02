<%--examtable을 삭제하는 jsp파일--%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<html>
<head>
</head>
<body>
<h1>테이블지우기 OK</h1>
<%
    Class.forName("com.mysql.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement();
    k14_stmt.executeUpdate("drop table examtable;");
    k14_stmt.close();
    k14_conn.close();
%>
</body>
</html>