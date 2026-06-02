<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<html>
<head>
</head>
<body>
<h1>와이파이</h1>

<%
    // 페이지 1부터 시작, 페이지 번호가 전달되면 해당 페이지로 이동
    int k14_page = 1;

    if(request.getParameter("page") != null) {
        k14_page = Integer.parseInt(request.getParameter("page"));
    }
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement();
    // 페이지당 10개의 레코드를 보여주도록 설정
    int k14_recordsPerPage = 10;
    int k14_start = (k14_page - 1) * k14_recordsPerPage; // 시작 레코드 계산
    ResultSet k14_rset = k14_stmt.executeQuery("SELECT * FROM freewifi LIMIT " + k14_start + ", " + k14_recordsPerPage);
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
    double k14_myLatitude = 37.3860521; 
    double k14_myLongitude = 127.1214038; 
    double k14_wifiLatitude = k14_rset.getDouble(14);
    double k14_wifiLongitude = k14_rset.getDouble(15);
    double k14_distance = Math.sqrt(Math.pow(k14_wifiLatitude - k14_myLatitude, 2) + Math.pow(k14_wifiLongitude - k14_myLongitude, 2));
    out.println("<td><p align=center>"+k14_distance+"</p></td>"); //거리
    out.println("</tr>");
}
	k14_rset.close();
	k14_stmt.close();
	k14_conn.close();
%>
</table>
</body>
</html>