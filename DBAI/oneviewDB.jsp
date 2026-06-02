<%--Allview화면에서 하나를 선택하면 해당 사람만 보여주는 jsp파일--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.net.*,java.io.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>개별 조회</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content">
    <div class="wrap">
<%
    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    Statement stmt = conn.createStatement();

    String ckey = request.getParameter("key");

    ResultSet rset = stmt.executeQuery("select * from examtable where name = '" + ckey + "';");

    StringBuilder rows = new StringBuilder();
    while (rset.next()) {
        rows.append("<tr>");
        rows.append("<td>" + rset.getString(1) + "</td>");
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
        <p class="eyebrow">examtable &middot; 개별 성적</p>
        <h1 class="page-title"><span class="mark"><%= ckey %></span> 조회</h1>

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

        <a class="back-link" href="AllviewDB.jsp" target="main">&larr; 전체조회로 돌아가기</a>
    </div>
</body>
</html>
