<%--
추가되는 레코드 처리
1. inputForm1.html에서 입력한 내용으로 한 레코드를 추가한다(학번 자동부여 = 기존 최대학번 + 1)
2. 추가된 내용을 표로 보여주고 [뒤로가기]로 inputForm1.html로 돌아간다
--%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>InsertDB</title>
<style>
    body { font-family: sans-serif; }
    .wrap { width: 430px; }
    .btns { text-align: right; margin-bottom: 8px; }
    table.rec { border-collapse: collapse; width: 100%; }
    table.rec td { border: 1px solid #888; padding: 6px 10px; }
    table.rec td.label { background-color: #eee; text-align: center; width: 90px; }
</style>
</head>
<body>
<h1>성적입력추가완료</h1>
<%
    Class.forName ("com.mysql.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection ("jdbc:mysql://localhost:3306/kopo14", "root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement ();
    String k14_name = request.getParameter("k14_name");
    String k14_kor = request.getParameter("k14_kor");
    String k14_eng = request.getParameter("k14_eng");
    String k14_mat = request.getParameter("k14_mat");

    ResultSet rset = k14_stmt.executeQuery("select max(k14_studentid) from examtable;");
    int k14_studentid=0;
    if(rset.next()) {
        k14_studentid=rset.getInt(1)+1;
    }

    String k14_sql = "insert into examtable values('"+k14_name+"',"+k14_studentid+","+k14_kor+","+k14_eng+","+k14_mat+")";
    int result = k14_stmt.executeUpdate(k14_sql);
    if(result>0) {
%>
    <div class="wrap">
        <div class="btns">
            <button type="button" onclick="history.back()">뒤로가기</button>
        </div>
        <table class="rec">
            <tr><td class="label">이름</td><td><%=k14_name%></td></tr>
            <tr><td class="label">학번</td><td><%=k14_studentid%></td></tr>
            <tr><td class="label">국어</td><td><%=k14_kor%></td></tr>
            <tr><td class="label">영어</td><td><%=k14_eng%></td></tr>
            <tr><td class="label">수학</td><td><%=k14_mat%></td></tr>
        </table>
    </div>
<%
    }else {    
        out.println("<h3>레코드 추가 실패</h3>");
        out.println("<button type='button' onclick='history.back()'>뒤로가기</button>");
    }
    rset.close ();
    k14_stmt.close ();
    k14_conn.close ();
%>
</body>
</html>
