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

Connection k14_conn =
    DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/kopo14",
        "root", "YOUR_DB_PASSWORD");

Statement k14_stmt =
    k14_conn.createStatement();

Statement k14_stmt2 =
    k14_conn.createStatement();

int k14_page = 1;
int k14_cnt = 1;

if(request.getParameter("page") != null) {
    k14_page = Integer.parseInt(request.getParameter("page"));
}

if(request.getParameter("cnt") != null) {
    k14_cnt = Integer.parseInt(request.getParameter("cnt"));
}

int k14_recordsPerPage = 10;

// 전체 건수 조회
ResultSet k14_cntRset =
    k14_stmt2.executeQuery(
        "SELECT COUNT(*) FROM freewifi");

k14_cntRset.next();

int k14_totalCnt =
    k14_cntRset.getInt(1);

int k14_totalPage =
    (k14_totalCnt + k14_recordsPerPage - 1)
    / k14_recordsPerPage;

// 현재 페이지 데이터 조회
int k14_start =
    (k14_page - 1) * k14_recordsPerPage;

ResultSet k14_rset =
    k14_stmt.executeQuery(
        "SELECT * FROM freewifi LIMIT "
        + k14_start + ","
        + k14_recordsPerPage);
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
    // 가장 가까운 와이파이 순으로 정렬하기 위해 거리 계산
    // 거리 m로 계산하기 위해 위도, 경도 차이를 이용하여 피타고라스의 정리를 사용하여 거리 계산
    double k14_distance = Math.sqrt(Math.pow(k14_wifiLatitude - k14_myLatitude, 2) + Math.pow(k14_wifiLongitude - k14_myLongitude, 2));
    out.println("<td><p align=center>"+k14_distance+"</p></td>"); //거리
    out.println("</tr>");
}
	k14_rset.close();
    k14_cntRset.close();

    k14_stmt.close();
    k14_stmt2.close();

    k14_conn.close();
%>

</table>
<div>

<%
out.println("<a href='FW3.jsp?page=1&cnt=1'>&lt;&lt;</a> ");

for(int i = k14_cnt; i < k14_cnt + 10; i++) {

    if(i > k14_totalPage) break;

    if(i == k14_page) {
        out.println("<b>[" + i + "]</b> ");
    } else {
        out.println("<a href='FW3.jsp?page="
                + i
                + "&cnt="
                + k14_cnt
                + "'>"
                + i
                + "</a> ");
    }
}

if(k14_cnt + 10 <= k14_totalPage) {
    out.println("<a href='FW3.jsp?page="
            + (k14_cnt + 10)
            + "&cnt="
            + (k14_cnt + 10)
            + "'>&gt;&gt;</a>");
}
%>

</div>
</body>
</html>