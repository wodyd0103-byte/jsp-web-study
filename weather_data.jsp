<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*" %>
<%--
    [AJAX 데이터 엔드포인트]
    weather_forecast2.jsp 에서 fetch() 로 호출됨.
    날씨 테이블 HTML 조각(fragment)만 반환하며,
    DOCTYPE/html/head/body 태그는 포함하지 않음.

    호출 예) /weather_data.jsp?gridx=61&gridy=123
--%>
<%!
    String getTagValue(Element elmt, String tagName) {
        NodeList nl = elmt.getElementsByTagName(tagName);
        if (nl == null || nl.getLength() == 0) return "";
        Node node = nl.item(0).getFirstChild();
        return (node == null) ? "" : node.getNodeValue().trim();
    }

    String fmt1(String s) {
        if (s == null || s.trim().isEmpty()) return s;
        try {
            double d = Double.parseDouble(s.trim());
            return String.format("%.1f", d);
        } catch (NumberFormatException e) {
            return s;
        }
    }

    String dayLabel(String day) {
        if ("0".equals(day)) return "오늘";
        if ("1".equals(day)) return "내일";
        if ("2".equals(day)) return "모레";
        return "";
    }

    String skyIcon(String sky, String pty) {
        if ("1".equals(pty)) return "&#127783;";
        if ("2".equals(pty)) return "&#127784;";
        if ("3".equals(pty)) return "&#127784;";
        if ("4".equals(pty)) return "&#10052;";
        if ("1".equals(sky)) return "&#9728;";
        if ("2".equals(sky)) return "&#127780;";
        if ("3".equals(sky)) return "&#9925;";
        if ("4".equals(sky)) return "&#9729;";
        return "-";
    }

    String windArrow(String wd) {
        if ("0".equals(wd)) return "&#8595;";
        if ("1".equals(wd)) return "&#8601;";
        if ("2".equals(wd)) return "&#8592;";
        if ("3".equals(wd)) return "&#8598;";
        if ("4".equals(wd)) return "&#8593;";
        if ("5".equals(wd)) return "&#8599;";
        if ("6".equals(wd)) return "&#8594;";
        if ("7".equals(wd)) return "&#8600;";
        return "-";
    }
%>
<%
    /* ── 파라미터 ────────────────────────────── */
    String gridx = request.getParameter("gridx");
    String gridy = request.getParameter("gridy");
    if (gridx == null || gridx.trim().isEmpty()) gridx = "61";
    if (gridy == null || gridy.trim().isEmpty()) gridy = "123";

    String targetUrl = "http://www.kma.go.kr/wid/queryDFS.jsp?gridx=" + gridx + "&gridy=" + gridy;

    Document doc     = null;
    String   dataSrc = "";
    String   liveErr = null;

    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    DocumentBuilder builder = factory.newDocumentBuilder();

    /* ── 1) 실제 기상청 URL 접속 시도 ──────────── */
    try {
        URL url = new URL(targetUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("User-Agent", "Mozilla/5.0");
        conn.setConnectTimeout(7000);
        conn.setReadTimeout(7000);
        InputStream is = conn.getInputStream();
        doc = builder.parse(is);
        doc.getDocumentElement().normalize();
        is.close();
        conn.disconnect();
        dataSrc = "LIVE";
    } catch (Exception e) {
        liveErr = e.toString();
        doc = null;
    }

    /* ── 2) 실패 시 샘플 XML 폴백 ───────────────── */
    if (doc == null) {
        try {
            String samplePath = application.getRealPath("/queryDFS_sample.xml");
            File sampleFile = new File(samplePath);
            if (sampleFile.exists()) {
                doc = builder.parse(sampleFile);
                doc.getDocumentElement().normalize();
                dataSrc = "SAMPLE";
            }
        } catch (Exception e) {
            liveErr = (liveErr == null ? "" : liveErr + " / ") + e.toString();
        }
    }

    /* ── 3) 현재 서버 시각 (갱신 시각 표시용) ────── */
    java.time.LocalDateTime now = java.time.LocalDateTime.now();
    String fetchedAt = String.format("%d-%02d-%02d %02d:%02d:%02d",
        now.getYear(), now.getMonthValue(), now.getDayOfMonth(),
        now.getHour(), now.getMinute(), now.getSecond());
%>
<%-- ════════════ HTML 조각 출력 시작 ════════════ --%>

<% if (doc == null) { %>

<p class="err">
    XML 데이터를 가져오지 못했습니다.<br>
    요청 URL : <%= targetUrl %><br>
    원인 : <%= liveErr %><br>
    (queryDFS_sample.xml 파일도 찾을 수 없습니다. 같은 폴더에 두세요.)
</p>

<% } else {
    String tm = "";
    NodeList tmList = doc.getElementsByTagName("tm");
    if (tmList.getLength() > 0 && tmList.item(0).getFirstChild() != null) {
        tm = tmList.item(0).getFirstChild().getNodeValue().trim();
    }
%>

<div class="subtitle">
    발표 시각 : <%= tm.isEmpty() ? "-" : tm %>
    &nbsp;|&nbsp;
    마지막 갱신 : <span id="fetchedAt"><%= fetchedAt %></span>
</div>

<% if ("SAMPLE".equals(dataSrc)) { %>
<div class="notice sample">
    실제 기상청 API(queryDFS.jsp) 접속에 실패하여 <b>샘플 XML</b>로 표시 중입니다.
    (해당 레거시 서비스는 기상청에서 종료됨 / 실패사유: <%= liveErr %>)
</div>
<% } %>

<table>
    <thead>
        <tr>
            <th class="seqcol">순서</th>
            <th>시간<br>(3시간 단위)</th>
            <th>현재 시간<br>온도</th>
            <th>최고 온도</th>
            <th>최저 온도</th>
            <th>하늘 상태코드<br>(1~4)</th>
            <th>강수 상태코드<br>(0~4)</th>
            <th>날씨 한국어</th>
            <th>날씨 영어</th>
            <th>강수 확률%</th>
            <th>12시간 예상<br>강수량</th>
            <th>12시간 예상<br>적설량</th>
            <th>풍속(m/s)</th>
            <th>풍향(0~7)</th>
            <th>풍향 한국어</th>
            <th>풍향 영어</th>
            <th>습도%</th>
            <th>6시간 예상<br>강수량</th>
            <th>6시간 예상<br>적설량</th>
        </tr>
    </thead>
    <tbody>
<%
    NodeList dataList = doc.getElementsByTagName("data");
    for (int i = 0; i < dataList.getLength(); i++) {
        Element elmt = (Element) dataList.item(i);
        String seq   = elmt.getAttribute("seq");
        String hour  = getTagValue(elmt, "hour");
        String day   = getTagValue(elmt, "day");
        String temp  = getTagValue(elmt, "temp");
        String tmx   = getTagValue(elmt, "tmx");
        String tmn   = getTagValue(elmt, "tmn");
        String sky   = getTagValue(elmt, "sky");
        String pty   = getTagValue(elmt, "pty");
        String wfKor = getTagValue(elmt, "wfKor");
        String wfEn  = getTagValue(elmt, "wfEn");
        String pop   = getTagValue(elmt, "pop");
        String r12   = getTagValue(elmt, "r12");
        String s12   = getTagValue(elmt, "s12");
        String ws    = getTagValue(elmt, "ws");
        String wd    = getTagValue(elmt, "wd");
        String wdKor = getTagValue(elmt, "wdKor");
        String wdEn  = getTagValue(elmt, "wdEn");
        String reh   = getTagValue(elmt, "reh");
        String r06   = getTagValue(elmt, "r06");
        String s06   = getTagValue(elmt, "s06");
        String timeText = dayLabel(day) + " " + hour + "시";
%>
        <tr>
            <td><%= i + 1 %></td>
            <td><%= timeText %></td>
            <td><%= fmt1(temp) %>&#8451;</td>
            <td><%= fmt1(tmx) %>&#8451;</td>
            <td><%= fmt1(tmn) %>&#8451;</td>
            <td><span class="icon"><%= skyIcon(sky, pty) %></span></td>
            <td><%= ("0".equals(pty) ? "-" : pty) %></td>
            <td><%= wfKor %></td>
            <td><%= wfEn %></td>
            <td><%= pop %>%</td>
            <td><%= fmt1(r12) %>mm</td>
            <td><%= fmt1(s12) %>cm</td>
            <td><%= fmt1(ws) %>m/s</td>
            <td><span class="arrow"><%= windArrow(wd) %></span></td>
            <td><%= wdKor %></td>
            <td><%= wdEn %></td>
            <td><%= reh %>%</td>
            <td><%= fmt1(r06) %>mm</td>
            <td><%= fmt1(s06) %>cm</td>
        </tr>
<% } %>
    </tbody>
</table>

<% } %>
