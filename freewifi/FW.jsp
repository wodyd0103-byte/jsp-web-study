<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<html>
<head>
</head>
<body>
<h1>와이파이</h1>

<%
	Class.forName("com.mysql.cj.jdbc.Driver");
	Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
		Statement k14_stmt = k14_conn.createStatement();
	ResultSet k14_rset = k14_stmt.executeQuery("select * from freewifi;");
%>
<table cellspacing=1 width=600 border=1>
<%
	while(k14_rset.next()) {
    out.println("<tr>");

    out.println("<td><p align=center>"+k14_rset.getInt(1)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(2)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(3)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(4)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(5)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(6)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(7)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(8)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(9)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(10)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(11)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(12)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getString(13)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getDouble(14)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getDouble(15)+"</p></td>");
    out.println("<td><p align=center>"+k14_rset.getDate(16)+"</p></td>");

    out.println("</tr>");
}
	k14_rset.close();
	k14_stmt.close();
	k14_conn.close();
%>
</table>
</body>
</html>