<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.net.*,java.io.*" %>

<html>
<head>
</head>
<body>
<%
    Class.forName("com.mysql.jdbc.Driver") ;
    Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD") ;
    Statement k14_stmt = k14_conn.createStatement ();

    String k14_ckey = request.getParameter ( "key" );

    ResultSet rset = k14_stmt.executeQuery("select * from examtable where K14_name = '"+k14_ckey+"';");
%>
<h1>[<%=k14_ckey%>]조회</h1>

<table cellspacing=1 width=600 border=1>
<tr>
<td width=50><p align=center>이름</p></td>
<td width=50><p align=center>학번</p></td>
<td width=50><p align=center>국어</p></td>
<td width=50><p align=center>영어</p></td>
<td width=50><p align=center>수학</p></td>
</tr>
<%
	while (rset.next () ) {
		out.println("<tr>");
		out.println("<td width=50><p align=center>"+rset.getString(1)+"</p></td>");
		out.println("<td width=50><p align=center>"+Integer.toString(rset.getInt (2) ) +"</p></td>") ;
		out.println("<td width=50><p align=center>"+Integer.toString(rset.getInt (3) ) +"</p></td>");
		out.println("<td width=50><p align=center>"+Integer.toString(rset.getInt (4) )+"</p></td>");
        out.println("<td width=50><p align=center>"+Integer.toString(rset.getInt (5) ) +"</p></td>") ;
        out.println("</tr>");
        }

rset.close();
k14_stmt.close();
k14_conn.close();
%>
</body>
</html>