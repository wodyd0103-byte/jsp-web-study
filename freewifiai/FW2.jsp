<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*,java.util.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>페이징 조회 · freewifiai</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content bg-mesh">
<div class="wrap">
    <p class="eyebrow">03 · Paging (LIMIT 10)</p>
    <h1 class="page-title">페이징 <span class="mark">조회</span></h1>
    <p class="lead">한 번에 10건씩 끊어 조회합니다. 각 행은 내 좌표 기준 거리를 신호 막대로 함께 표시합니다.</p>

<%
    double k14_myLat = 37.3860521;
    double k14_myLng = 127.1214038;

    int k14_page = 1;
    if(request.getParameter("page") != null) {
        k14_page = Integer.parseInt(request.getParameter("page"));
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
    Statement k14_stmt  = k14_conn.createStatement();
    Statement k14_stmt2 = k14_conn.createStatement();

    int k14_perPage = 10;
    int k14_start = (k14_page - 1) * k14_perPage;

    // 전체 건수 → 총 페이지
    ResultSet k14_cnt = k14_stmt2.executeQuery("SELECT COUNT(*) FROM freewifi");
    k14_cnt.next();
    int k14_total = k14_cnt.getInt(1);
    k14_cnt.close();
    int k14_totalPage = (k14_total + k14_perPage - 1) / k14_perPage;

    ResultSet k14_rset = k14_stmt.executeQuery("SELECT * FROM freewifi LIMIT " + k14_start + ", " + k14_perPage);

    // 현재 페이지 데이터 수집 + 거리
    List<Object[]> k14_rows = new ArrayList<Object[]>();
    double k14_min = Double.MAX_VALUE, k14_max = 0;
    while(k14_rset.next()) {
        int    id   = k14_rset.getInt(1);
        String addr = k14_rset.getString(10);
        double lat  = k14_rset.getDouble(14);
        double lng  = k14_rset.getDouble(15);
        double dist = Math.sqrt(Math.pow(lat - k14_myLat, 2) + Math.pow(lng - k14_myLng, 2));
        if(dist < k14_min) k14_min = dist;
        if(dist > k14_max) k14_max = dist;
        k14_rows.add(new Object[]{ id, addr, lat, lng, dist });
    }
    k14_rset.close();
    k14_stmt.close();
    k14_stmt2.close();
    k14_conn.close();
    double k14_span = (k14_max - k14_min); if(k14_span == 0) k14_span = 1;
%>
    <div class="toolbar">
        <span class="stat loc">◎ MY POS&nbsp; <b><%= k14_myLat %>, <%= k14_myLng %></b></span>
        <span class="stat">PAGE&nbsp; <b><%= k14_page %> / <%= k14_totalPage %></b></span>
        <span class="stat">TOTAL&nbsp; <b><%= k14_total %></b></span>
    </div>

    <div class="table-card">
      <div class="table-scroll">
        <table class="grid">
            <thead>
                <tr><th>번호</th><th>주소</th><th>위도</th><th>경도</th><th>근접도 · 거리</th></tr>
            </thead>
            <tbody>
<%
    if(k14_rows.isEmpty()) {
        out.println("<tr><td colspan='5' class='empty'>표시할 데이터가 없습니다.</td></tr>");
    }
    for(Object[] r : k14_rows) {
        int    id   = (Integer)r[0];
        String addr = (String) r[1];
        double lat  = (Double) r[2];
        double lng  = (Double) r[3];
        double dist = (Double) r[4];
        double meters  = dist * 111000.0;
        double fillPct = 100.0 - ((dist - k14_min) / k14_span * 92.0);
        if(fillPct < 8) fillPct = 8;
        String fillCls = fillPct >= 66 ? "" : (fillPct >= 33 ? "warn" : "far");

        out.println("<tr>");
        out.println("<td class='mono'>"+id+"</td>");
        out.println("<td class='addr'>"+addr+"</td>");
        out.println("<td class='mono'>"+lat+"</td>");
        out.println("<td class='mono'>"+lng+"</td>");
        out.println("<td><div class='sig'><span class='track'><span class='fill "+fillCls+"' style='width:"+String.format("%.1f", fillPct)+"%'></span></span><span class='m'>"+String.format("%,.0f", meters)+" m</span></div></td>");
        out.println("</tr>");
    }
%>
            </tbody>
        </table>
      </div>
    </div>

    <div class="pager">
<%
    if(k14_page > 1) out.println("<a class='edge' href='FW2.jsp?page="+(k14_page-1)+"'>‹ 이전</a>");
    for(int i = 1; i <= k14_totalPage; i++) {
        if(i == k14_page) out.println("<span class='cur'>"+i+"</span>");
        else              out.println("<a href='FW2.jsp?page="+i+"'>"+i+"</a>");
    }
    if(k14_page < k14_totalPage) out.println("<a class='edge' href='FW2.jsp?page="+(k14_page+1)+"'>다음 ›</a>");
%>
    </div>

    <a class="back-link" href="intro.html">← 인트로로 돌아가기</a>
</div>
</body>
</html>
