<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<html>
<head>
</head>
<body>
<h1>조회</h1>

<%
	Class.forName("com.mysql.jdbc.Driver");
	Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
	Statement k14_stmt = k14_conn.createStatement ();
	ResultSet k14_rset = k14_stmt.executeQuery("select * from examtable;") ;
%>
<table cellspacing=1 width=600 border=1>
<tr>

<td width=50><p align=center>이름</p></td>
<td width=50><p align=center>학번</p></td>
<td width=50><p align=center>국어</p></td>
<td width=50><p align=center>영어</p></td>
<td width=50><p align=center>수학</p></td>
</tr>
<%
	while (k14_rset.next ()) {
		out.println("<tr>");
		out.println("<td width=50><p align=center><a href='oneviewDB.jsp?key="
			+k14_rset.getString(1)+"' target='main'> "+k14_rset.getString(1)+"</a></p></td>");
		out.println("<td width=50><p align=center>"+Integer.toString(k14_rset.getInt (2) ) +"</p></td>") ;
		out.println("<td width=50><p align=center>"+Integer.toString(k14_rset.getInt(3) )+"</p></td>");
		out.println("<td width=50><p align=center>"+Integer.toString(k14_rset.getInt (4) )+"</p></td>");
		out.println("<td width=50><p align=center>"+Integer.toString(k14_rset.getInt (5) )+"</p></td>");
		out.println("</tr>");
		}
	k14_rset.close ();
	k14_stmt.close ();
	k14_conn.close ();
%>
</body>
</html>