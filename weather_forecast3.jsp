<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    기상청(KMA) 동네예보 – AJAX 자동 갱신 버전
    ─────────────────────────────────────────
    • 최초 페이지 로드 시 weather_data.jsp 를 fetch() 로 호출하여 테이블을 그립니다.
    • 이후 10분(600초)마다 동일 엔드포인트를 재조회하여 #weatherContainer 를 교체합니다.
    • 우측 상단 상태 표시줄에 다음 갱신까지 남은 시간(카운트다운)을 1초 단위로 표시합니다.
    • [지금 갱신] 버튼으로 즉시 재조회 가능합니다.
--%>
<%
    String gridx = request.getParameter("gridx");
    String gridy = request.getParameter("gridy");
    if (gridx == null || gridx.trim().isEmpty()) gridx = "61";
    if (gridy == null || gridy.trim().isEmpty()) gridy = "123";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>기상청 동네예보 (자동 갱신)</title>
<style>
    /* ── 기본 레이아웃 ── */
    *, *::before, *::after { box-sizing: border-box; }
    body {
        font-family: "Malgun Gothic", "맑은 고딕", sans-serif;
        background: linear-gradient(135deg, #f4eefe 0%, #e7dafc 100%);
        min-height: 100vh;
        margin: 0;
        padding: 24px 0 40px;
    }

    /* ── 제목 ── */
    h2 {
        text-align: center;
        margin: 0 0 4px;
        color: #5b2a9c;
        text-shadow: 0 2px 3px rgba(91,42,156,0.20);
    }
    .subtitle { text-align:center; color:#7a5fae; font-size:13px; margin-bottom:6px; }

    /* ── 상태 표시 바 ── */
    .status-bar {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 16px;
        flex-wrap: wrap;
        margin: 10px auto 18px;
        max-width: 900px;
        padding: 8px 16px;
        background: rgba(255,255,255,0.65);
        border: 1px solid #c9a8f5;
        border-radius: 12px;
        box-shadow: 0 3px 10px rgba(124,77,208,0.15);
        font-size: 13px;
        color: #5b2a9c;
    }
    .status-bar .countdown {
        font-weight: bold;
        font-size: 15px;
        color: #7d4ad6;
        min-width: 90px;
        text-align: center;
    }
    .status-bar .countdown.urgent { color: #c0392b; animation: pulse 0.8s infinite; }

    @keyframes pulse {
        0%,100% { opacity:1; }
        50%      { opacity:0.5; }
    }

    /* ── 갱신 버튼 ── */
    .btn-refresh {
        background: linear-gradient(160deg, #b58df3 0%, #7d4ad6 100%);
        color: #fff;
        border: none;
        border-radius: 8px;
        padding: 5px 14px;
        font-size: 13px;
        cursor: pointer;
        box-shadow: 0 3px 6px rgba(91,42,156,0.35);
        transition: opacity .2s, transform .15s;
    }
    .btn-refresh:hover  { opacity:.9; transform: translateY(-1px); }
    .btn-refresh:active { opacity:.8; transform: translateY(0); }
    .btn-refresh:disabled { opacity:.5; cursor:not-allowed; }

    /* ── 로딩 오버레이 ── */
    .loading-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(244,238,254,0.55);
        z-index: 999;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        gap: 14px;
    }
    .loading-overlay.show { display: flex; }
    .spinner {
        width: 44px; height: 44px;
        border: 5px solid #dcb9ff;
        border-top-color: #7d4ad6;
        border-radius: 50%;
        animation: spin 0.75s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    .loading-text { color: #5b2a9c; font-weight: bold; font-size: 15px; }

    /* ── 오류 안내 ── */
    .notice {
        max-width:900px; margin:8px auto 18px auto; padding:9px 14px;
        font-size:12px; border-radius:10px; text-align:center;
        box-shadow: 0 3px 8px rgba(124,77,208,0.18);
    }
    .notice.sample { background:#fff4cf; border:1px solid #e6c84d; color:#7a5b00; }
    .err   { color:#c00; text-align:center; margin:30px; }

    /* ── 테이블 ── */
    table {
        border-collapse: separate;
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
        border-radius: 8px;
    }
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
    tbody td {
        color: #3d2466;
        box-shadow: inset 0 2px 1px rgba(255,255,255,0.85),
                    inset 0 -2px 3px rgba(124,77,208,0.28),
                    0 2px 4px rgba(124,77,208,0.22);
    }
    tbody tr:nth-child(odd)  td { background: linear-gradient(160deg,#faf6ff,#efe6fd); }
    tbody tr:nth-child(even) td { background: linear-gradient(160deg,#ece0fb,#dcc8f7); }
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

    /* ── 페이드 전환 효과 ── */
    #weatherContainer { transition: opacity .3s ease; }
    #weatherContainer.fading { opacity: 0; }
</style>
</head>
<body>

<!-- 로딩 오버레이 -->
<div class="loading-overlay" id="loadingOverlay">
    <div class="spinner"></div>
    <div class="loading-text">날씨 데이터 조회 중…</div>
</div>

<h2>기상청 동네예보 &mdash; 좌표(<%= gridx %>,<%= gridy %>)</h2>

<!-- 상태 표시 바 -->
<div class="status-bar">
    <span>🔄 자동 갱신 간격 : <strong>10분</strong></span>
    <span>⏱ 다음 갱신까지 : <span class="countdown" id="countdown">10:00</span></span>
    <button class="btn-refresh" id="btnRefresh" onclick="doRefresh()">지금 갱신</button>
    <span id="statusMsg" style="color:#888;font-size:12px;"></span>
</div>

<!-- 날씨 데이터 영역 -->
<div id="weatherContainer">
    <!-- 최초 렌더링은 JavaScript 에서 fetch() 로 채웁니다 -->
    <p style="text-align:center;color:#999;margin-top:40px;">데이터를 불러오는 중입니다…</p>
</div>

<script>
(function () {
    /* ── 설정 ──────────────────────────────────────── */
    const REFRESH_SEC   = 600;           // 10분 = 600초
    const DATA_URL      = "weather_data.jsp?gridx=<%= gridx %>&gridy=<%= gridy %>";

    /* ── 상태 변수 ─────────────────────────────────── */
    let remainSec       = REFRESH_SEC;
    let countdownTimer  = null;
    let refreshTimer    = null;
    let isFetching      = false;

    /* ── DOM 참조 ──────────────────────────────────── */
    const container     = document.getElementById("weatherContainer");
    const countdownEl   = document.getElementById("countdown");
    const statusMsg     = document.getElementById("statusMsg");
    const loadingOvl    = document.getElementById("loadingOverlay");
    const btnRefresh    = document.getElementById("btnRefresh");

    /* ── 카운트다운 표시 ────────────────────────────── */
    function updateCountdown() {
        const m = String(Math.floor(remainSec / 60)).padStart(2, "0");
        const s = String(remainSec % 60).padStart(2, "0");
        countdownEl.textContent = m + ":" + s;
        countdownEl.classList.toggle("urgent", remainSec <= 30);
    }

    function startCountdown() {
        clearInterval(countdownTimer);
        remainSec = REFRESH_SEC;
        updateCountdown();
        countdownTimer = setInterval(function () {
            if (remainSec > 0) {
                remainSec--;
                updateCountdown();
            }
        }, 1000);
    }

    /* ── 데이터 갱신 (AJAX fetch) ───────────────────── */
    function fetchWeather() {
        if (isFetching) return;
        isFetching = true;
        btnRefresh.disabled = true;
        loadingOvl.classList.add("show");
        statusMsg.textContent = "";

        fetch(DATA_URL + "&_t=" + Date.now())   // 캐시 방지 타임스탬프
            .then(function (res) {
                if (!res.ok) throw new Error("HTTP " + res.status);
                return res.text();
            })
            .then(function (html) {
                /* 페이드 아웃 → HTML 교체 → 페이드 인 */
                container.classList.add("fading");
                setTimeout(function () {
                    container.innerHTML = html;
                    container.classList.remove("fading");
                    statusMsg.textContent = "";
                }, 300);
            })
            .catch(function (err) {
                statusMsg.textContent = "⚠ 갱신 실패: " + err.message;
                statusMsg.style.color = "#c00";
            })
            .finally(function () {
                isFetching = false;
                btnRefresh.disabled = false;
                loadingOvl.classList.remove("show");
                /* 카운트다운 리셋 */
                startCountdown();
            });
    }

    /* ── 10분 주기 자동 갱신 예약 ───────────────────── */
    function scheduleAutoRefresh() {
        clearInterval(refreshTimer);
        refreshTimer = setInterval(function () {
            fetchWeather();
        }, REFRESH_SEC * 1000);
    }

    /* ── [지금 갱신] 버튼 핸들러 ───────────────────── */
    window.doRefresh = function () {
        clearInterval(refreshTimer);
        fetchWeather();
        scheduleAutoRefresh();
    };

    /* ── 페이지 최초 로드 ───────────────────────────── */
    fetchWeather();
    scheduleAutoRefresh();
    startCountdown();
})();
</script>

</body>
</html>
