<%-- updateDB.jsp: 데이터를 업데이트한 뒤 전체 데이터를 다 보여주고, 방금 수정한 레코드를 노란색으로 표시 --%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>UpdateDB</title>
<style>
    .update { background-color: yellow; }
</style>
</head>
<body>
<%
    Class.forName ("com.mysql.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement ();
    String k14_studentid = request.getParameter("k14_studentid");
    String k14_name = request.getParameter("k14_name");
    String k14_kor = request.getParameter("k14_kor");
    String k14_eng = request.getParameter("k14_eng");
    String k14_mat = request.getParameter("k14_mat");

    String k14_sql = "update examtable set k14_name='"+k14_name+"', k14_kor="+k14_kor+", k14_eng="+k14_eng+", k14_mat="+k14_mat+" where k14_studentid='"+k14_studentid+"'";
    k14_stmt.executeUpdate(k14_sql);   // 값이 그대로면 변경행수가 0일 수 있으므로 결과로 성공/실패를 판단하지 않는다
%>
<h3>레코드 수정 완료</h3>

<table cellspacing=1 width=600 border=1>
<tr>
    <td width=50><p align=center>이름</p></td>
    <td width=50><p align=center>학번</p></td>
    <td width=50><p align=center>국어</p></td>
    <td width=50><p align=center>영어</p></td>
    <td width=50><p align=center>수학</p></td>
</tr>
<%
    ResultSet rset = k14_stmt.executeQuery("select * from examtable");
    while (rset.next()) {
        String rid = Integer.toString(rset.getInt("k14_studentid"));
        // 방금 수정한 학번이면 노란색으로 강조
        String cls = rid.equals(k14_studentid) ? " class='update'" : "";
        out.println("<tr>");
        out.println("<td"+cls+"><p align=center>"+rset.getString("k14_name")+"</p></td>");
        out.println("<td"+cls+"><p align=center>"+rid+"</p></td>");
        out.println("<td"+cls+"><p align=center>"+rset.getInt("k14_kor")+"</p></td>");
        out.println("<td"+cls+"><p align=center>"+rset.getInt("k14_eng")+"</p></td>");
        out.println("<td"+cls+"><p align=center>"+rset.getInt("k14_mat")+"</p></td>");
        out.println("</tr>");
    }
    rset.close ();
    k14_stmt.close ();
    k14_conn.close ();
%>
</table>
</body>
</html>
