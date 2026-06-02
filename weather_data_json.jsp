<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.net.*,java.io.*,javax.xml.parsers.*,org.w3c.dom.*" %>
<%--
    [AJAX JSON 엔드포인트] weather_forecast2.jsp 에서 fetch() 로 호출됨.
    날씨 데이터를 JSON 형식으로 반환합니다.
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
        if (s == null || s.trim().isEmpty()) return "";
        try { return String.format("%.1f", Double.parseDouble(s.trim())); }
        catch (NumberFormatException e) { return s; }
    }
    String dayLabel(String day) {
        if ("0".equals(day)) return "오늘";
        if ("1".equals(day)) return "내일";
        if ("2".equals(day)) return "모레";
        return "";
    }
    String escJ(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n"," ").replace("\r","");
    }
%>
<%
    out.clearBuffer(); // 지시어·선언부 사이 공백이 버퍼에 남지 않도록 초기화
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

    String gridx = request.getParameter("gridx");
    String gridy = request.getParameter("gridy");
    if (gridx == null || gridx.trim().isEmpty()) gridx = "61";
    if (gridy == null || gridy.trim().isEmpty()) gridy = "123";

    String targetUrl = "http://www.kma.go.kr/wid/queryDFS.jsp?gridx=" + gridx + "&gridy=" + gridy;
    Document doc = null;
    String dataSrc = "";
    String liveErr = null;

    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    DocumentBuilder builder = factory.newDocumentBuilder();

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
    }

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

    java.time.LocalDateTime now = java.time.LocalDateTime.now();
    String fetchedAt = String.format("%d-%02d-%02d %02d:%02d:%02d",
        now.getYear(), now.getMonthValue(), now.getDayOfMonth(),
        now.getHour(), now.getMinute(), now.getSecond());

    if (doc == null) {
        out.print("{\"ok\":false,\"error\":\"" + escJ(liveErr) + "\",\"fetchedAt\":\"" + fetchedAt + "\"}");
        return;
    }

    String tm = "";
    NodeList tmList = doc.getElementsByTagName("tm");
    if (tmList.getLength() > 0 && tmList.item(0).getFirstChild() != null)
        tm = tmList.item(0).getFirstChild().getNodeValue().trim();

    NodeList dataList = doc.getElementsByTagName("data");
    String firstSky="1",firstPty="0",firstTemp="",firstWfKor="",firstReh="",firstWs="",firstWdKor="";
    if (dataList.getLength() > 0) {
        Element first = (Element) dataList.item(0);
        firstSky   = getTagValue(first,"sky");
        firstPty   = getTagValue(first,"pty");
        firstTemp  = fmt1(getTagValue(first,"temp"));
        firstWfKor = getTagValue(first,"wfKor");
        firstReh   = getTagValue(first,"reh");
        firstWs    = fmt1(getTagValue(first,"ws"));
        firstWdKor = getTagValue(first,"wdKor");
    }

    StringBuilder sb = new StringBuilder();
    sb.append("{\"ok\":true,\"tm\":\"").append(escJ(tm)).append("\",");
    sb.append("\"dataSrc\":\"").append(dataSrc).append("\",");
    sb.append("\"fetchedAt\":\"").append(fetchedAt).append("\",");
    if(liveErr!=null) sb.append("\"liveErr\":\"").append(escJ(liveErr)).append("\",");
    sb.append("\"currentSky\":\"").append(firstSky).append("\",");
    sb.append("\"currentPty\":\"").append(firstPty).append("\",");
    sb.append("\"currentTemp\":").append(firstTemp.isEmpty()?"null":firstTemp).append(",");
    sb.append("\"currentWf\":\"").append(escJ(firstWfKor)).append("\",");
    sb.append("\"currentReh\":").append(firstReh.isEmpty()?"null":firstReh).append(",");
    sb.append("\"currentWs\":").append(firstWs.isEmpty()?"null":firstWs).append(",");
    sb.append("\"currentWdKor\":\"").append(escJ(firstWdKor)).append("\",");
    sb.append("\"data\":[");

    for (int i=0; i<dataList.getLength(); i++) {
        Element el=(Element)dataList.item(i);
        String day=getTagValue(el,"day"),hour=getTagValue(el,"hour");
        String temp=fmt1(getTagValue(el,"temp")),tmx=fmt1(getTagValue(el,"tmx")),tmn=fmt1(getTagValue(el,"tmn"));
        String sky=getTagValue(el,"sky"),pty=getTagValue(el,"pty");
        String wfKor=getTagValue(el,"wfKor"),wfEn=getTagValue(el,"wfEn");
        String pop=getTagValue(el,"pop"),ws=fmt1(getTagValue(el,"ws")),wd=getTagValue(el,"wd");
        String wdKor=getTagValue(el,"wdKor"),reh=getTagValue(el,"reh");
        String r06=fmt1(getTagValue(el,"r06")),s06=fmt1(getTagValue(el,"s06"));
        String r12=fmt1(getTagValue(el,"r12")),s12=fmt1(getTagValue(el,"s12"));
        if(i>0) sb.append(",");
        sb.append("{\"idx\":").append(i+1);
        sb.append(",\"timeLabel\":\"").append(escJ(dayLabel(day)+" "+hour+"시")).append("\"");
        sb.append(",\"day\":\"").append(day).append("\"");
        sb.append(",\"hour\":\"").append(hour).append("\"");
        sb.append(",\"temp\":").append(temp.isEmpty()?"null":temp);
        sb.append(",\"tmx\":").append(tmx.isEmpty()?"null":tmx);
        sb.append(",\"tmn\":").append(tmn.isEmpty()?"null":tmn);
        sb.append(",\"sky\":\"").append(sky).append("\"");
        sb.append(",\"pty\":\"").append(pty).append("\"");
        sb.append(",\"wfKor\":\"").append(escJ(wfKor)).append("\"");
        sb.append(",\"wfEn\":\"").append(escJ(wfEn)).append("\"");
        sb.append(",\"pop\":").append(pop.isEmpty()?"0":pop);
        sb.append(",\"ws\":").append(ws.isEmpty()?"null":ws);
        sb.append(",\"wd\":\"").append(wd).append("\"");
        sb.append(",\"wdKor\":\"").append(escJ(wdKor)).append("\"");
        sb.append(",\"reh\":").append(reh.isEmpty()?"null":reh);
        sb.append(",\"r06\":\"").append(r06).append("\"");
        sb.append(",\"s06\":\"").append(s06).append("\"");
        sb.append(",\"r12\":\"").append(r12).append("\"");
        sb.append(",\"s12\":\"").append(s12).append("\"}");
    }
    sb.append("]}");
    out.print(sb.toString());
%>
