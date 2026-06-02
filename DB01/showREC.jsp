#showREC.jsp 는 하나의 레코드 유무를 조회해주고 데이터가 있다면 inputForm2.html으로 데이터를 넘겨준다
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*,java.net.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ShowREC</title>
</head>
<body>
<%
    Class.forName ("com.mysql.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement ();
    String k14_studentid = request.getParameter("k14_studentid");
    String k14_sql = "select * from examtable where k14_studentid='"+k14_studentid+"'";
    ResultSet rset = k14_stmt.executeQuery(k14_sql);
    if(rset.next()) {
        String k14_name = rset.getString("k14_name");
        int k14_kor = rset.getInt("k14_kor");
        int k14_eng = rset.getInt("k14_eng");
        int k14_mat = rset.getInt("k14_mat");
        response.sendRedirect("inputForm2.html?k14_studentid="+URLEncoder.encode(k14_studentid,"UTF-8")+"&k14_name="+URLEncoder.encode(k14_name,"UTF-8")+"&k14_kor="+k14_kor+"&k14_eng="+k14_eng+"&k14_mat="+k14_mat);
    }else {
        response.sendRedirect("inputForm2.html?k14_studentid="+URLEncoder.encode(k14_studentid,"UTF-8")+"&k14_name="+URLEncoder.encode("해당학번없음","UTF-8"));
    }
    rset.close ();
    k14_stmt.close ();
    k14_conn.close ();
%>
</body>
</html>