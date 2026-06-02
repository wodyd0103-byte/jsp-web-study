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
<table cellspacing=1 width=600 border=1 style="white-space: nowrap;"> 
    <thead>
        <tr>
            <th>번호</th>
            <th>주소</th>
            <th>위도</th>
            <th>경도</th>
            <th>거리</th>
        </tr>
    </thead>
<%
	while(k14_rset.next()) {
    out.println("<tr>");
    out.println("<td><p align=center>"+k14_rset.getInt(1)+"</p></td>"); //번호
    out.println("<td><p align=center>"+k14_rset.getString(10)+"</p></td>"); //주소
    out.println("<td><p align=center>"+k14_rset.getDouble(14)+"</p></td>"); //위도 
    out.println("<td><p align=center>"+k14_rset.getDouble(15)+"</p></td>"); //경도
    // 내위치 - 위도, 경도
    double myLatitude = 37.3860521; 
    double myLongitude = 127.1214038; 
    double wifiLatitude = k14_rset.getDouble(14);
    double wifiLongitude = k14_rset.getDouble(15);
    double distance = Math.sqrt(Math.pow(wifiLatitude - myLatitude, 2) + Math.pow(wifiLongitude - myLongitude, 2));
    out.println("<td><p align=center>"+distance+"</p></td>"); //거리
    out.println("</tr>");
}
	k14_rset.close();
	k14_stmt.close();
	k14_conn.close();
%>
</table>
</body>
</html>