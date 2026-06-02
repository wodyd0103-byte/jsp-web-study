<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*,java.util.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>가까운 순 + 페이지 · freewifiai</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content bg-mesh">
<div class="wrap">
    <p class="eyebrow">04 · Global Rank + Pager</p>
    <h1 class="page-title">가까운 순 <span class="mark">랭킹</span></h1>
    <p class="lead">전체 WiFi를 거리순으로 정렬한 뒤 페이지로 나눠 보여줍니다. 순위는 페이지를 넘겨도 전역 기준으로 이어집니다.</p>

<%
    double k14_myLat = 37.3860521;
    double k14_myLng = 127.1214038;

    int k14_page = 1;   // 현재 페이지
    int k14_cnt  = 1;   // 페이저 윈도우 시작
    if(request.getParameter("page") != null) k14_page = Integer.parseInt(request.getParameter("page"));
    if(request.getParameter("cnt")  != null) k14_cnt  = Integer.parseInt(request.getParameter("cnt"));

    int k14_perPage = 10;

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement();
    ResultSet k14_rset = k14_stmt.executeQuery("SELECT * FROM freewifi");

    // 1) 전체 로드 + 거리 계산
    List<Object[]> k14_all = new ArrayList<Object[]>();
    for( ; k14_rset.next(); ) {
        int    id   = k14_rset.getInt(1);
        String addr = k14_rset.getString(10);
        double lat  = k14_rset.getDouble(14);
        double lng  = k14_rset.getDouble(15);
        double dist = Math.sqrt(Math.pow(lat - k14_myLat, 2) + Math.pow(lng - k14_myLng, 2));
        k14_all.add(new Object[]{ id, addr, lat, lng, dist });
    }
    k14_rset.close();
    k14_stmt.close();
    k14_conn.close();

    // 2) AI 보강: 거리 오름차순 전역 정렬
    Collections.sort(k14_all, new Comparator<Object[]>() {
        public int compare(Object[] a, Object[] b) { return Double.compare((Double)a[4], (Double)b[4]); }
    });

    int k14_total = k14_all.size();
    int k14_totalPage = (k14_total + k14_perPage - 1) / k14_perPage;
    if(k14_totalPage == 0) k14_totalPage = 1;
    if(k14_page > k14_totalPage) k14_page = k14_totalPage;

    // 신호 막대 정규화 (전역 기준)
    double k14_min = k14_total > 0 ? (Double)k14_all.get(0)[4] : 0;
    double k14_max = k14_total > 0 ? (Double)k14_all.get(k14_total-1)[4] : 1;
    double k14_span = (k14_max - k14_min); if(k14_span == 0) k14_span = 1;

    // 3) 현재 페이지 슬라이스
    int k14_start = (k14_page - 1) * k14_perPage;
    int k14_end   = Math.min(k14_start + k14_perPage, k14_total);
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
                <tr><th>순위</th><th>번호</th><th>주소</th><th>위도</th><th>경도</th><th>근접도 · 거리</th></tr>
            </thead>
            <tbody>
<%
    if(k14_total == 0) {
        out.println("<tr><td colspan='6' class='empty'>표시할 데이터가 없습니다.</td></tr>");
    }
    for(int i = k14_start; i < k14_end; i++) {
        Object[] r = k14_all.get(i);
        int    rank = i + 1;                 // 전역 순위
        int    id   = (Integer)r[0];
        String addr = (String) r[1];
        double lat  = (Double) r[2];
        double lng  = (Double) r[3];
        double dist = (Double) r[4];
        double meters  = dist * 111000.0;
        double fillPct = 100.0 - ((dist - k14_min) / k14_span * 92.0);
        if(fillPct < 8) fillPct = 8;
        String fillCls = fillPct >= 66 ? "" : (fillPct >= 33 ? "warn" : "far");
        String trCls = (rank == 1) ? "nearest" : (rank <= 3 ? "top3" : "");

        out.println("<tr class='"+trCls+"'>");
        out.println("<td><span class='rank'>"+rank+"</span></td>");
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
    // 맨 앞으로
    out.println("<a class='edge' href='FW3.jsp?page=1&cnt=1'>« 처음</a>");
    // 윈도우 시작이 1보다 크면 이전 윈도우
    if(k14_cnt > 1) {
        int prevCnt = Math.max(1, k14_cnt - 10);
        out.println("<a class='edge' href='FW3.jsp?page="+prevCnt+"&cnt="+prevCnt+"'>‹</a>");
    }
    // 10칸 윈도우
    for(int i = k14_cnt; i < k14_cnt + 10; i++) {
        if(i > k14_totalPage) break;
        if(i == k14_page) out.println("<span class='cur'>"+i+"</span>");
        else              out.println("<a href='FW3.jsp?page="+i+"&cnt="+k14_cnt+"'>"+i+"</a>");
    }
    // 다음 윈도우
    if(k14_cnt + 10 <= k14_totalPage) {
        int nextCnt = k14_cnt + 10;
        out.println("<a class='edge' href='FW3.jsp?page="+nextCnt+"&cnt="+nextCnt+"'>›</a>");
    }
%>
    </div>

    <a class="back-link" href="intro.html">← 인트로로 돌아가기</a>
</div>
</body>
</html>
