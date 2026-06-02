<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.net.URL" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>동네예보</title>

<style>
table{
    border-collapse:collapse;
    width:1000px;
}

th, td{
    border:1px solid black;
    padding:8px;
    text-align:center;
}

th{
    background:#eeeeee;
}
</style>

</head>
<body>

<h2>기상청 동네예보</h2>

<table>

<tr>
    <th>seq</th>
    <th>시간</th>
    <th>날짜</th>
    <th>기온</th>
    <th>최고</th>
    <th>최저</th>
    <th>날씨</th>
    <th>습도</th>
    <th>풍속</th>
    <th>풍향</th>
</tr>

<%

// =========================
// 1. XML 가져오기
// =========================

URL url = new URL(
    "http://www.kma.go.kr/wid/queryDFS.jsp?gridx=61&gridy=123"
);

DocumentBuilderFactory factory =
        DocumentBuilderFactory.newInstance();

DocumentBuilder builder =
        factory.newDocumentBuilder();

Document doc =
        builder.parse(url.openStream());

doc.getDocumentElement().normalize();


// =========================
// 2. 변수 선언
// =========================

String seq = "";
String hour = "";
String day = "";
String temp = "";
String tmx = "";
String tmn = "";
String sky = "";
String pty = "";
String wfKor = "";
String wfEn = "";
String pop = "";
String r12 = "";
String s12 = "";
String ws = "";
String wd = "";
String wdKor = "";
String wdEn = "";
String reh = "";
String r06 = "";
String s06 = "";


// =========================
// 3. XML parsing
// =========================

Element root = doc.getDocumentElement();

NodeList tag_001 =
        doc.getElementsByTagName("data");

for (int i = 0; i < tag_001.getLength(); i++) {

    Element elmt =
            (Element) tag_001.item(i);

    seq = tag_001.item(i)
            .getAttributes()
            .getNamedItem("seq")
            .getNodeValue();

    hour = elmt.getElementsByTagName("hour")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    day = elmt.getElementsByTagName("day")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    temp = elmt.getElementsByTagName("temp")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    tmx = elmt.getElementsByTagName("tmx")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    tmn = elmt.getElementsByTagName("tmn")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    wfKor = elmt.getElementsByTagName("wfKor")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    ws = elmt.getElementsByTagName("ws")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    wdKor = elmt.getElementsByTagName("wdKor")
            .item(0)
            .getFirstChild()
            .getNodeValue();

    reh = elmt.getElementsByTagName("reh")
            .item(0)
            .getFirstChild()
            .getNodeValue();

%>

<tr>

    <td><%=seq%></td>

    <td><%=hour%>시</td>

    <td>
    <%
        if(day.equals("0")){
            out.print("오늘");
        }else if(day.equals("1")){
            out.print("내일");
        }else{
            out.print("모레");
        }
    %>
    </td>

    <td><%=temp%>℃</td>

    <td><%=tmx%>℃</td>

    <td><%=tmn%>℃</td>

    <td><%=wfKor%></td>

    <td><%=reh%>%</td>

    <td><%=ws%> m/s</td>

    <td><%=wdKor%></td>

</tr>

<%
}
%>

</table>

</body>
</html>