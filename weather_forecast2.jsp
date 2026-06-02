<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*" %>
<%--
    기상청(KMA) 동네예보 조회 JSP
    - 접속 URL : http://www.kma.go.kr/wid/queryDFS.jsp?gridx=61&gridy=123
    - 위 URL 의 XML 을 받아 <data> 태그를 파싱하여 HTML 표로 출력함

    [중요] queryDFS.jsp 레거시 서비스는 기상청에서 종료되었습니다.
           실제 접속이 실패하면 같은 폴더의 queryDFS_sample.xml(실습용)을
           대신 읽어서 표를 그립니다.

    XML(=<data> 태그) 구성 요소
      seq:순서(속성)  hour:3시간단위  day:0오늘/1내일/2모레
      temp:현재온도  tmx:최고  tmn:최저
      sky:하늘(1맑음2구름조금3구름많음4흐림)  pty:강수(0없음1비2비눈3눈비4눈)
      wfKor/wfEn:날씨  pop:강수확률%  r12/s12:12시간강수/적설
      ws:풍속  wd:풍향0~7  wdKor/wdEn:풍향  reh:습도%  r06/s06:6시간강수/적설
--%>
<%!
    /* <data> 자식 태그의 텍스트 값을 안전하게 꺼내는 헬퍼 */
    String getTagValue(Element elmt, String tagName) {
        NodeList nl = elmt.getElementsByTagName(tagName);
        if (nl == null || nl.getLength() == 0) return "";
        Node node = nl.item(0).getFirstChild();
        return (node == null) ? "" : node.getNodeValue().trim();
    }

    /* 숫자를 소수점 아래 1자리로 포맷 (숫자가 아니면 원본 그대로) */
    String fmt1(String s) {
        if (s == null || s.trim().isEmpty()) return s;
        try {
            double d = Double.parseDouble(s.trim());
            return String.format("%.1f", d);
        } catch (NumberFormatException e) {
            return s;
        }
    }

    /* day(0/1/2) -> 오늘/내일/모레 */
    String dayLabel(String day) {
        if ("0".equals(day)) return "오늘";
        if ("1".equals(day)) return "내일";
        if ("2".equals(day)) return "모레";
        return "";
    }

    /* sky / pty 코드 -> 날씨 이모지 아이콘 */
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

    /* wd(0~7) -> 풍향 화살표 (바람이 불어가는 방향) */
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
    // 조회 격자 좌표 (기본값: 61,123 = 경기도 성남시 분당구)
    String gridx = request.getParameter("gridx");
    String gridy = request.getParameter("gridy");
    if (gridx == null || gridx.trim().isEmpty()) gridx = "61";
    if (gridy == null || gridy.trim().isEmpty()) gridy = "123";

    String targetUrl = "http://www.kma.go.kr/wid/queryDFS.jsp?gridx="
                       + gridx + "&gridy=" + gridy;

    Document doc      = null;
    String   dataSrc  = "";
    String   liveErr  = null;

    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    DocumentBuilder builder = factory.newDocumentBuilder();

    // 1) 실제 기상청 URL 접속 시도
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

    // 2) 실패하면 같은 폴더의 샘플 XML 로 폴백
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
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>기상청 동네예보</title>
<style>
    body {
        font-family: "Malgun Gothic", "맑은 고딕", sans-serif;
        background: linear-gradient(135deg, #f4eefe 0%, #e7dafc 100%);
        margin: 0; padding: 24px 0;
    }
    h2 {
        text-align: center; margin-bottom: 4px;
        color: #5b2a9c;
        text-shadow: 0 2px 3px rgba(91,42,156,0.20);
    }
    .subtitle { text-align:center; color:#7a5fae; font-size:13px; margin-bottom:6px; }
    .notice {
        max-width:900px; margin:8px auto 18px auto; padding:9px 14px;
        font-size:12px; border-radius:10px; text-align:center;
        box-shadow: 0 3px 8px rgba(124,77,208,0.18);
    }
    .notice.sample { background:#fff4cf; border:1px solid #e6c84d; color:#7a5b00; }

    /* 표 전체 - 둥근 모서리 + 그림자로 입체감 */
    table {
        border-collapse: separate;     /* 셀별 모서리/그림자를 위해 separate 사용 */
        border-spacing: 3px;
        margin: 0 auto;
        background: linear-gradient(160deg, #ffffff, #f0e7fd);
        padding: 10px;
        border-radius: 16px;
        box-shadow: 0 12px 30px rgba(91,42,156,0.30),
                    inset 0 1px 0 rgba(255,255,255,0.9);
    }
    th, td {
        padding: 6px 9px;
        text-align: center;
        font-size: 12px;
        white-space: nowrap;
        border-radius: 8px;            /* 각 셀 모서리 둥글게 */
    }
    /* 헤더 - 화사한 보라 그라데이션, 솟아오른 입체 효과 */
    thead th {
        background: linear-gradient(160deg, #b58df3 0%, #7d4ad6 100%);
        color: #ffffff;
        font-weight: bold;
        text-shadow: 0 1px 2px rgba(0,0,0,0.30);
        box-shadow: inset 0 2px 1px rgba(255,255,255,0.50),
                    inset 0 -2px 3px rgba(70,30,130,0.45),
                    0 3px 6px rgba(91,42,156,0.40);
    }
    thead th.seqcol {
        background: linear-gradient(160deg, #dcb9ff 0%, #a06ee6 100%);
    }
    /* 데이터 셀 - 연보라 바탕, 올록볼록한 입체 효과 */
    tbody td {
        color: #3d2466;
        box-shadow: inset 0 2px 1px rgba(255,255,255,0.85),
                    inset 0 -2px 3px rgba(124,77,208,0.28),
                    0 2px 4px rgba(124,77,208,0.22);
    }
    tbody tr:nth-child(odd)  td { background: linear-gradient(160deg,#faf6ff,#efe6fd); }
    tbody tr:nth-child(even) td { background: linear-gradient(160deg,#ece0fb,#dcc8f7); }
    /* 순서 열 - 헤더와 같은 보라색 강조 */
    tbody td:first-child {
        background: linear-gradient(160deg, #c9a8f5, #9b6be2);
        color: #ffffff;
        font-weight: bold;
        text-shadow: 0 1px 2px rgba(0,0,0,0.25);
        box-shadow: inset 0 2px 1px rgba(255,255,255,0.45),
                    inset 0 -2px 3px rgba(70,30,130,0.40),
                    0 2px 4px rgba(91,42,156,0.30);
    }
    .icon  { font-size:18px; }
    .arrow { font-size:18px; color:#6a32c9; font-weight:bold;
             text-shadow:0 1px 2px rgba(106,50,201,0.35); }
    .err   { color:#c00; text-align:center; margin:30px; }
</style>
</head>
<body>

<h2>기상청 동네예보 - 좌표(<%= gridx %>,<%= gridy %>)</h2>

<%
    if (doc == null) {
%>
    <p class="err">
        XML 데이터를 가져오지 못했습니다.<br>
        요청 URL : <%= targetUrl %><br>
        원인 : <%= liveErr %><br>
        (queryDFS_sample.xml 파일도 찾을 수 없습니다. 같은 폴더에 두세요.)
    </p>
<%
    } else {
        String tm = "";
        NodeList tmList = doc.getElementsByTagName("tm");
        if (tmList.getLength() > 0 && tmList.item(0).getFirstChild() != null) {
            tm = tmList.item(0).getFirstChild().getNodeValue().trim();
        }
%>
    <div class="subtitle">발표 시각 : <%= (tm.isEmpty() ? "-" : tm) %></div>

<%      if ("SAMPLE".equals(dataSrc)) { %>
    <div class="notice sample">
        실제 기상청 API(queryDFS.jsp) 접속에 실패하여 <b>샘플 XML</b>로 표시 중입니다.
        (해당 레거시 서비스는 기상청에서 종료됨 / 실패사유: <%= liveErr %>)
    </div>
<%      } %>

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
<%
        }
%>
        </tbody>
    </table>
<%
    }
%>

</body>
</html>
