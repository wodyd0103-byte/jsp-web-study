<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>전체 정보 조회 · freewifiai</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content bg-mesh">
<div class="wrap">
    <p class="eyebrow">01 · All Columns</p>
    <h1 class="page-title">전체 <span class="mark">WiFi 정보</span></h1>
    <p class="lead"><strong>freewifi</strong> 테이블의 모든 컬럼을 원본 그대로 조회합니다. 표는 가로로 스크롤됩니다.</p>

<%
    int rowCount = 0;
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement();
    ResultSet k14_rset = k14_stmt.executeQuery("select * from freewifi;");
%>
    <div class="toolbar">
        <span class="stat">TABLE&nbsp; <b>freewifi</b></span>
        <span class="stat">COLUMNS&nbsp; <b>16</b></span>
    </div>

    <div class="table-card">
      <div class="table-scroll">
        <table class="grid">
            <thead>
                <tr>
                    <th>번호</th><th>C2</th><th>C3</th><th>C4</th><th>C5</th>
                    <th>C6</th><th>C7</th><th>C8</th><th>C9</th>
                    <th>주소</th><th>C11</th><th>C12</th><th>C13</th>
                    <th>위도</th><th>경도</th><th>등록일</th>
                </tr>
            </thead>
            <tbody>
<%
    while(k14_rset.next()) {
        rowCount++;
        out.println("<tr>");
        out.println("<td class='mono'>"+k14_rset.getInt(1)+"</td>");
        for(int c = 2; c <= 13; c++) {
            String cls = (c == 10) ? "addr" : "";
            out.println("<td class='"+cls+"'>"+k14_rset.getString(c)+"</td>");
        }
        out.println("<td class='mono'>"+k14_rset.getDouble(14)+"</td>");
        out.println("<td class='mono'>"+k14_rset.getDouble(15)+"</td>");
        out.println("<td class='mono'>"+k14_rset.getDate(16)+"</td>");
        out.println("</tr>");
    }
    k14_rset.close();
    k14_stmt.close();
    k14_conn.close();
%>
            </tbody>
        </table>
      </div>
    </div>

    <div class="toolbar" style="margin-top:18px">
        <span class="stat">ROWS&nbsp; <b><%= rowCount %></b></span>
    </div>

    <a class="back-link" href="intro.html">← 인트로로 돌아가기</a>
</div>
</body>
</html>
