<%--examtable에 데이터 insert하는 jsp파일--%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<html>
<head>
</head>
<body>
<h1>실습데이터 입력</h1>
<%
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
        Statement k14_stmt = k14_conn.createStatement ();
        k14_stmt.execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('나연', 209901, 95, 100, 95) ; ") ;
        k14_stmt.execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('정연', 209902, 95, 95, 95) ; ") ;
        k14_stmt.execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('모모', 209903, 100, 100, 100) ; ") ;
        k14_stmt.execute("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('지효', 209904, 100, 95, 90) ; ") ;
        k14_stmt.execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values('사나', 209905, 80, 100, 70) ;") ;
        k14_stmt.execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('미나' , 209906, 100, 100, 70) ; ") ;
        k14_stmt.execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('다현' , 209907, 70, 70, 70) ; ") ;
        k14_stmt.execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('채영', 209908, 80, 75, 72) ; ") ;
        k14_stmt. execute ("insert into examtable (k14_name, k14_studentid, k14_kor, k14_eng, k14_mat) values ('쯔위', 209909, 78, 79, 82) ; ") ;
        k14_stmt.close ();
        k14_conn.close ();
    } catch (SQLException e) {
        out.println("오류: "+e.getMessage());
    }
%>
</body>
</html>
