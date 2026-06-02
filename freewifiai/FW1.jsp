<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*,javax.sql.*,java.io.*,java.util.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>거리 계산 · 정렬 · freewifiai</title>
<link rel="stylesheet" href="style.css">
</head>
<body class="content bg-mesh">
<div class="wrap">
    <p class="eyebrow">02 · Nearest First</p>
    <h1 class="page-title">거리 계산 <span class="mark">& 가까운 순</span></h1>
    <p class="lead">내 좌표와 각 WiFi의 위·경도 차이로 거리를 구하고, <strong>가까운 순으로 정렬</strong>해 신호 막대로 근접도를 표현합니다.</p>

<%
    // 내 위치 (기준 좌표)
    double k14_myLat = 37.3860521;
    double k14_myLng = 127.1214038;

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection k14_conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/kopo14","root", "YOUR_DB_PASSWORD");
    Statement k14_stmt = k14_conn.createStatement();
    ResultSet k14_rset = k14_stmt.executeQuery("select * from freewifi;");

    // 1) 결과를 리스트에 담으며 거리 계산
    List<Object[]> k14_rows = new ArrayList<Object[]>();
    while(k14_rset.next()) {
        int    id   = k14_rset.getInt(1);
        String addr = k14_rset.getString(10);
        double lat  = k14_rset.getDouble(14);
        double lng  = k14_rset.getDouble(15);
        double dist = Math.sqrt(Math.pow(lat - k14_myLat, 2) + Math.pow(lng - k14_myLng, 2));
        k14_rows.add(new Object[]{ id, addr, lat, lng, dist });
    }
    k14_rset.close();
    k14_stmt.close();
    k14_conn.close();

    // 2) AI 보강: 거리 오름차순 정렬
    Collections.sort(k14_rows, new Comparator<Object[]>() {
        public int compare(Object[] a, Object[] b) {
            return Double.compare((Double)a[4], (Double)b[4]);
        }
    });

    // 3) 신호 막대 정규화용 최소/최대
    double k14_min = Double.MAX_VALUE, k14_max = 0;
    for(Object[] r : k14_rows) {
        double d = (Double)r[4];
        if(d < k14_min) k14_min = d;
        if(d > k14_max) k14_max = d;
    }
    double k14_span = (k14_max - k14_min);
    if(k14_span == 0) k14_span = 1;
%>
    <div class="toolbar">
        <span class="stat loc">◎ MY POS&nbsp; <b><%= k14_myLat %>, <%= k14_myLng %></b></span>
        <span class="stat">FOUND&nbsp; <b><%= k14_rows.size() %></b></span>
    </div>

    <div class="table-card">
      <div class="table-scroll">
        <table class="grid">
            <thead>
                <tr>
                    <th>순위</th><th>번호</th><th>주소</th>
                    <th>위도</th><th>경도</th><th>근접도 · 거리</th>
                </tr>
            </thead>
            <tbody>
<%
    int rank = 0;
    for(Object[] r : k14_rows) {
        rank++;
        int    id   = (Integer)r[0];
        String addr = (String) r[1];
        double lat  = (Double) r[2];
        double lng  = (Double) r[3];
        double dist = (Double) r[4];

        // 거리(도) → 대략 미터 환산 (1도 ≈ 111,000m)
        double meters = dist * 111000.0;

        // 신호 막대: 가까울수록 가득. 최소 8%
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

    <a class="back-link" href="intro.html">← 인트로로 돌아가기</a>
</div>
</body>
</html>
