# deleteDB는 삭제처리 후 전체레코드를 조회하는 화면으로 이동한다
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<html>
<head>
<meta charset="UTF-8">
<title>DeleteDB</title>
</head>
<body>
<%
    Class.forName ("com.mysql.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement ();
    String k14_studentid = request.getParameter("k14_studentid");
    String k14_sql = "delete from examtable where k14_studentid='"+k14_studentid+"'";
    int result = k14_stmt.executeUpdate(k14_sql);
    if(result>0) {
        out.println("<h3>레코드 삭제 성공</h3>");
    }else {
        out.println("<h3>레코드 삭제 실패</h3>");
    }
    k14_stmt.close ();
    k14_conn.close ();
    response.sendRedirect("AllviewDB.jsp");
%>
</body>
</html>
