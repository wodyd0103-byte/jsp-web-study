<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<html>
<head>
</head>
<body>
<h1>테이블만들기 OK</h1>

<%
    Class.forName ("com.mysql.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");

    try {
    Statement k14_stmt = k14_conn.createStatement ();
    k14_stmt.execute ("create table examtable ("+
    "k14_name varchar (20),"+
    "k14_studentid int not null primary key, "+
    "k14_kor int,"+
    "k14_eng int,"+
    "k14_mat int) DEFAULT CHARSET=utf8;");
    k14_stmt.close ();
    k14_conn.close ();
    } catch (SQLException e) {
        out.println("오류: "+e.getMessage());
    }
%>
</body>
</html>
