<%--examtable의 데이터를 모두 보여주는 jsp파일--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>TBL 전체조회</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content">
    <div class="wrap">
        <p class="eyebrow">examtable</p>
        <h1 class="page-title">전체 <span class="mark">조회</span></h1>

<%
    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    Statement stmt = conn.createStatement();
    ResultSet rset = stmt.executeQuery("select * from examtable;");

    int cnt = 0;
    StringBuilder rows = new StringBuilder();
    while (rset.next()) {
        cnt++;
        rows.append("<tr>");
        rows.append("<td><a class='name-link' href='oneviewDB.jsp?key="
            + rset.getString(1) + "' target='main'>" + rset.getString(1) + "</a></td>");
        rows.append("<td>" + rset.getInt(2) + "</td>");
        rows.append("<td>" + rset.getInt(3) + "</td>");
        rows.append("<td>" + rset.getInt(4) + "</td>");
        rows.append("<td>" + rset.getInt(5) + "</td>");
        rows.append("</tr>");
    }
    rset.close();
    stmt.close();
    conn.close();
%>
        <div class="table-meta">
            <span class="count">총 <strong><%= cnt %></strong> 명</span>
            <span class="count">이름을 누르면 개별 성적이 보입니다</span>
        </div>

        <div class="table-card">
            <table class="exam">
                <thead>
                    <tr>
                        <th>이름</th><th>학번</th><th>국어</th><th>영어</th><th>수학</th>
                    </tr>
                </thead>
                <tbody>
                    <%= rows.toString() %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
