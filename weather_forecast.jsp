<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*" %>
<%--
    기상청(KMA) 동네예보 조회 JSP
    - 접속 URL : http://www.kma.go.kr/wid/queryDFS.jsp?gridx=61&gridy=123
    - 위 URL 의 XML 을 받아 <data> 태그를 파싱하여 HTML 표로 출력함

    [중요] 위 queryDFS.jsp 레거시 서비스는 기상청에서 종료되었습니다.
           (단기예보 RSS/XML 서비스 2025년 종료)
           따라서 실제 접속이 실패하면 같은 폴더의 queryDFS_sample.xml
           (실습용 샘플)을 대신 읽어서 표를 그립니다.
           실제 데이터가 필요하면 공공데이터포털 단기예보 OpenAPI
           (VilageFcstInfoService_2.0)로 URL/태그명을 교체하세요.

    XML(=<data> 태그) 구성 요소
      seq   : 48시간 중 몇 번째 인지 (data 태그의 속성)
      hour  : 동네예보 3시간 단위
      day   : 1번째 날 (0:오늘 / 1:내일 / 2:모레)
      temp  : 현재 시간온도
      tmx   : 최고 온도
      tmn   : 최저 온도
      sky   : 하늘 상태코드 (1:맑음, 2:구름조금, 3:구름많음, 4:흐림)
      pty   : 강수 상태코드 (0:없음, 1:비, 2:비/눈, 3:눈/비, 4:눈)
      wfKor : 날씨 한국어        wfEn : 날씨 영어
      pop   : 강수 확률 %
      r12   : 12시간 예상 강수량  s12 : 12시간 예상 적설량
      ws    : 풍속 (m/s)
      wd    : 풍향 (0~7 : 북,북동,동,남동,남,남서,서,북서)
      wdKor : 풍향 한국어        wdEn : 풍향 영어
      reh   : 습도 %
      r06   : 6시간 예상 강수량   s06 : 6시간 예상 적설량
--%>
<%!
    /* <data> 자식 태그의 텍스트 값을 안전하게 꺼내는 헬퍼 메서드 */
    String getTagValue(Element elmt, String tagName) {
        NodeList nl = elmt.getElementsByTagName(tagName);
        if (nl == null || nl.getLength() == 0) return "";
        Node node = nl.item(0).getFirstChild();
        return (node == null) ? "" : node.getNodeValue().trim();
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
        if ("1".equals(pty)) return "&#127783;";   // 비   쨔
        if ("2".equals(pty)) return "&#127784;";   // 비/눈 쨨
        if ("3".equals(pty)) return "&#127784;";   // 눈/비 쨨
        if ("4".equals(pty)) return "&#10052;";    // 눈   ?
        if ("1".equals(sky)) return "&#9728;";     // 맑음    ??
        if ("2".equals(sky)) return "&#127780;";   // 구름조금 쨀
        if ("3".equals(sky)) return "&#9925;";     // 구름많음 ??
        if ("4".equals(sky)) return "&#9729;";     // 흐림    ??
        return "-";
    }

    /* wd(0~7) -> 풍향 화살표 (바람이 불어가는 방향) */
    String windArrow(String wd) {
        if ("0".equals(wd)) return "&#8595;";   // 북풍  ?
        if ("1".equals(wd)) return "&#8601;";   // 북동  ?
        if ("2".equals(wd)) return "&#8592;";   // 동풍  ?
        if ("3".equals(wd)) return "&#8598;";   // 남동  ?
        if ("4".equals(wd)) return "&#8593;";   // 남풍  ?
        if ("5".equals(wd)) return "&#8599;";   // 남서  ?
        if ("6".equals(wd)) return "&#8594;";   // 서풍  ?
        if ("7".equals(wd)) return "&#8600;";   // 북서  ?
        return "-";
    }
%>
<%
    // 조회할 격자 좌표 (기본값: 61,123 = 경기도 성남시 분당구)
    String gridx = request.getParameter("gridx");
    String gridy = request.getParameter("gridy");
    if (gridx == null || gridx.trim().isEmpty()) gridx = "61";
    if (gridy == null || gridy.trim().isEmpty()) gridy = "123";

    String targetUrl = "http://www.kma.go.kr/wid/queryDFS.jsp?gridx="
                       + gridx + "&gridy=" + gridy;

    Document doc      = null;   // 파싱 결과
    String   dataSrc  = "";     // "LIVE" 또는 "SAMPLE"
    String   liveErr  = null;   // 실 API 실패 사유

    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    DocumentBuilder builder = factory.newDocumentBuilder();

    // 1) 먼저 실제 기상청 URL 접속 시도
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
    body { font-family: "Malgun Gothic", "맑은 고딕", sans-serif; background:#ffffff; }
    h2   { text-align:center; margin-bottom:4px; }
    .subtitle { text-align:center; color:#555; font-size:13px; margin-bottom:6px; }
    .notice {
        max-width:900px; margin:8px auto 16px auto; padding:8px 12px;
        font-size:12px; border-radius:4px; text-align:center;
    }
    .notice.sample { background:#fff4cf; border:1px solid #e6c84d; color:#7a5b00; }
    table { border-collapse:collapse; margin:0 auto; }
    th, td {
        border:1px solid #b0b0c8; padding:5px 8px;
        text-align:center; font-size:12px; white-space:nowrap;
    }
    thead th { background:#f4c6da; font-weight:bold; }
    thead th.seqcol { background:#dcd7f0; }
    tbody tr:nth-child(even) { background:#f1eef9; }
    tbody tr:nth-child(odd)  { background:#ffffff; }
    .icon  { font-size:18px; }
    .arrow { font-size:18px; color:#2f6fdd; font-weight:bold; }
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
        // 발표 시각(header/tm) 표시
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
        // <data> 태그를 모두 가져와 반복 출력
        NodeList dataList = doc.getElementsByTagName("data");
        for (int i = 0; i < dataList.getLength(); i++) {
            Element elmt = (Element) dataList.item(i);

            String seq   = elmt.getAttribute("seq");   // data 태그의 속성
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
                <td><%= temp %>&#8451;</td>
                <td><%= tmx %>&#8451;</td>
                <td><%= tmn %>&#8451;</td>
                <td><span class="icon"><%= skyIcon(sky, pty) %></span></td>
                <td><%= ("0".equals(pty) ? "-" : pty) %></td>
                <td><%= wfKor %></td>
                <td><%= wfEn %></td>
                <td><%= pop %>%</td>
                <td><%= r12 %>mm</td>
                <td><%= s12 %>cm</td>
                <td><%= ws %>m/s</td>
                <td><span class="arrow"><%= windArrow(wd) %></span></td>
                <td><%= wdKor %></td>
                <td><%= wdEn %></td>
                <td><%= reh %>%</td>
                <td><%= r06 %>mm</td>
                <td><%= s06 %>cm</td>
            </tr>
<%
        } // end for
%>
        </tbody>
    </table>
<%
    } // end else
%>

</body>
</html>
