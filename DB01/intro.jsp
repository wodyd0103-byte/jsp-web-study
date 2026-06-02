<!--처음 url 시작할때 그냥 제목 보이는 파일-->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.io.*, java.net.*" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<html>
<head></head> 
<body>
<H1><center> JSP Database 실습 1</center></H1>
<%
    String k14_data;
    int k14_cnt = 0;

    FileReader k14_fl =
        new FileReader("C:\\tomcat11\\webapps\\ROOT\\DB01\\data.txt");

    StringBuffer k14_sb = new StringBuffer();

    int k14_ch = 0;
    while((k14_ch = k14_fl.read()) != -1){
        k14_sb.append((char)k14_ch);
    }

    k14_data = k14_sb.toString().trim().replace("\n","");
    k14_fl.close();

    k14_cnt = Integer.parseInt(k14_data);
    k14_cnt++;
    k14_data = Integer.toString(k14_cnt);
    out.println("<br><br>현재 홈페이지 방문조회수 [" + k14_data + "] 입니다. </br>");

    FileWriter k14_fl2 = new FileWriter("C:\\tomcat11\\webapps\\ROOT\\DB01\\data.txt", false);
    k14_fl2.write(k14_data);
    k14_fl2.close();
%>
</body>
</html>