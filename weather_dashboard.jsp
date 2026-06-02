<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%--
    기상청 동네예보 – 날씨 반응형 배경 + Chart.js 대시보드
    ────────────────────────────────────────────────────
    • weather_data.jsp 를 10분마다 AJAX(fetch)로 재조회
    • 현재 날씨(sky/pty 코드)에 따라 배경 테마 자동 전환
    • 기온 추이·강수확률·습도·풍속을 Chart.js 로 시각화
    • 글래스모피즘 카드 + 파티클 배경(비/눈/햇빛)
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
<title>기상청 동네예보</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,500;0,9..40,700&display=swap" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<style>
/* ══════════════════════════════════════════
   CSS 변수 – 날씨 테마별 오버라이드
══════════════════════════════════════════ */
:root {
    --bg-from: #1a3a5c;
    --bg-mid:  #0f2744;
    --bg-to:   #071529;
    --accent:  #4fc3f7;
    --accent2: #81d4fa;
    --glass-bg:    rgba(255,255,255,0.08);
    --glass-border:rgba(255,255,255,0.15);
    --text-primary: #f0f8ff;
    --text-muted:   rgba(255,255,255,0.55);
    --card-shadow: 0 8px 32px rgba(0,0,0,0.35);
    --chart-grid: rgba(255,255,255,0.08);
}
/* ── 맑음 ── */
body.sky-clear {
    --bg-from:#1e6bba; --bg-mid:#0a4a8c; --bg-to:#06285c;
    --accent:#ffd54f; --accent2:#ffe082;
}
/* ── 구름 조금 ── */
body.sky-partly {
    --bg-from:#2e6da4; --bg-mid:#1b4f7a; --bg-to:#0d2f4d;
    --accent:#90caf9; --accent2:#bbdefb;
}
/* ── 구름 많음 ── */
body.sky-mostly {
    --bg-from:#37536a; --bg-mid:#243d52; --bg-to:#12232f;
    --accent:#90a4ae; --accent2:#b0bec5;
}
/* ── 흐림 ── */
body.sky-overcast {
    --bg-from:#2c3e50; --bg-mid:#1a2535; --bg-to:#0d131c;
    --accent:#78909c; --accent2:#90a4ae;
}
/* ── 비 ── */
body.sky-rain {
    --bg-from:#1a2f45; --bg-mid:#0f1e30; --bg-to:#070e18;
    --accent:#4dd0e1; --accent2:#80deea;
}
/* ── 비·눈 ── */
body.sky-sleet {
    --bg-from:#253445; --bg-mid:#17232f; --bg-to:#0c141c;
    --accent:#80cbc4; --accent2:#b2dfdb;
}
/* ── 눈 ── */
body.sky-snow {
    --bg-from:#c5d8ec; --bg-mid:#98bbd8; --bg-to:#6696b8;
    --accent:#ffffff; --accent2:#e3f2fd;
    --glass-bg: rgba(255,255,255,0.25);
    --glass-border: rgba(255,255,255,0.45);
    --text-primary: #1a3a5c;
    --text-muted: rgba(26,58,92,0.55);
    --chart-grid: rgba(26,58,92,0.1);
}

/* ══════════════════════════════════════════
   기본 레이아웃
══════════════════════════════════════════ */
*, *::before, *::after { box-sizing: border-box; margin:0; padding:0; }
html, body { height:100%; }
body {
    font-family: "Noto Sans KR", "DM Sans", sans-serif;
    min-height:100vh;
    background: linear-gradient(160deg, var(--bg-from), var(--bg-mid) 50%, var(--bg-to));
    color: var(--text-primary);
    transition: background 1.2s ease, color 0.6s ease;
    overflow-x: hidden;
}

/* ── 파티클 캔버스 ── */
#particleCanvas {
    position:fixed; inset:0; pointer-events:none; z-index:0;
    opacity:0.55;
}

/* ── 메인 컨테이너 ── */
.page {
    position: relative; z-index:1;
    max-width: 1280px;
    margin: 0 auto;
    padding: 28px 20px 50px;
}

/* ── 헤더 ── */
.header {
    display:flex; align-items:center; justify-content:space-between;
    flex-wrap:wrap; gap:12px;
    margin-bottom: 24px;
}
.header-title h1 {
    font-family:"DM Sans", sans-serif;
    font-size: clamp(1.2rem, 3vw, 1.8rem);
    font-weight:700;
    letter-spacing:-0.02em;
    color: var(--text-primary);
}
.header-title .coord {
    font-size:12px; color: var(--text-muted);
    margin-top:2px; font-weight:300;
}
.status-pill {
    display:flex; align-items:center; gap:10px; flex-wrap:wrap;
    background: var(--glass-bg);
    border:1px solid var(--glass-border);
    border-radius:50px;
    padding: 7px 16px;
    font-size:12px; color: var(--text-muted);
    backdrop-filter: blur(12px);
}
.status-pill .countdown {
    font-weight:700; color: var(--accent);
    font-size:14px; min-width:42px; text-align:center;
    transition: color 0.3s;
}
.status-pill .countdown.urgent { color:#ef5350; animation:pulse 0.9s infinite; }
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.4} }
.btn-now {
    background: var(--accent);
    color: var(--bg-to);
    border:none; border-radius:50px;
    padding:5px 14px; font-size:12px; font-weight:700;
    cursor:pointer; transition:opacity .2s,transform .15s;
    font-family:inherit;
}
.btn-now:hover { opacity:.85; transform:translateY(-1px); }
.btn-now:disabled { opacity:.4; cursor:not-allowed; transform:none; }

/* ══════════════════════════════════════════
   현재 날씨 히어로 카드
══════════════════════════════════════════ */
.hero-card {
    background: var(--glass-bg);
    border:1px solid var(--glass-border);
    border-radius:24px;
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    padding: 28px 32px;
    margin-bottom: 20px;
    box-shadow: var(--card-shadow);
    display:grid;
    grid-template-columns: 1fr auto;
    gap:20px;
    align-items:center;
    transition: background 0.8s, border-color 0.8s;
}
.hero-main { display:flex; align-items:center; gap:20px; flex-wrap:wrap; }
.hero-icon { font-size: clamp(3.5rem,8vw,5.5rem); line-height:1; filter:drop-shadow(0 4px 16px rgba(0,0,0,0.4)); }
.hero-temp {
    font-family:"DM Sans",sans-serif;
    font-size: clamp(3rem,9vw,5.5rem);
    font-weight:700;
    line-height:1;
    letter-spacing:-0.04em;
    color: var(--text-primary);
    text-shadow: 0 2px 20px rgba(0,0,0,0.3);
}
.hero-temp sup { font-size:0.4em; vertical-align:top; margin-top:0.2em; }
.hero-desc { margin-top:6px; }
.hero-wf { font-size:1.2rem; font-weight:500; color: var(--accent); }
.hero-time { font-size:11px; color: var(--text-muted); margin-top:3px; }

.hero-meta {
    display:grid; grid-template-columns:1fr 1fr;
    gap: 14px 24px;
    text-align:right;
}
.meta-item .label {
    font-size:10px; text-transform:uppercase; letter-spacing:.08em;
    color: var(--text-muted); font-weight:500;
}
.meta-item .value {
    font-size:1.35rem; font-weight:700; font-family:"DM Sans",sans-serif;
    color: var(--accent2); margin-top:1px;
}

/* ══════════════════════════════════════════
   차트 그리드
══════════════════════════════════════════ */
.charts-grid {
    display:grid;
    grid-template-columns: repeat(auto-fit, minmax(280px,1fr));
    gap: 16px;
    margin-bottom: 20px;
}
.chart-card {
    background: var(--glass-bg);
    border:1px solid var(--glass-border);
    border-radius:18px;
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    padding: 18px 18px 14px;
    box-shadow: var(--card-shadow);
    transition: background 0.8s, border-color 0.8s;
}
.chart-card.wide { grid-column: span 2; }
@media(max-width:700px) { .chart-card.wide { grid-column:span 1; } }
.chart-title {
    font-size:11px; font-weight:700;
    text-transform:uppercase; letter-spacing:.1em;
    color: var(--text-muted); margin-bottom:12px;
    display:flex; align-items:center; gap:6px;
}
.chart-title .dot {
    width:6px; height:6px; border-radius:50%;
    background: var(--accent); flex-shrink:0;
}
.chart-wrap { position:relative; height:160px; }
.chart-wrap.tall { height:200px; }

/* ══════════════════════════════════════════
   타임라인 테이블
══════════════════════════════════════════ */
.table-card {
    background: var(--glass-bg);
    border:1px solid var(--glass-border);
    border-radius:18px;
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    box-shadow: var(--card-shadow);
    overflow:hidden;
    transition: background 0.8s, border-color 0.8s;
}
.table-card .section-title {
    padding:14px 20px 10px;
    font-size:11px; font-weight:700; letter-spacing:.1em;
    text-transform:uppercase; color: var(--text-muted);
    border-bottom:1px solid var(--glass-border);
    display:flex; align-items:center; gap:6px;
}
.table-scroll { overflow-x:auto; }
table { width:100%; border-collapse:collapse; min-width:860px; }
thead th {
    padding: 9px 10px;
    font-size:10px; font-weight:700; text-transform:uppercase;
    letter-spacing:.07em; color: var(--text-muted);
    background: rgba(0,0,0,0.12);
    white-space:nowrap; text-align:center;
    border-bottom:1px solid var(--glass-border);
}
tbody td {
    padding: 8px 10px;
    font-size:12px; text-align:center;
    color: var(--text-primary);
    border-bottom:1px solid rgba(255,255,255,0.05);
    white-space:nowrap;
    transition: background 0.15s;
}
tbody tr:hover td { background: rgba(255,255,255,0.06); }
tbody tr.today td { background: rgba(255,255,255,0.04); }
tbody tr.today td:first-child { 
    border-left:3px solid var(--accent);
}
.badge {
    display:inline-block; padding:2px 8px;
    border-radius:20px; font-size:10px; font-weight:700;
    background: rgba(255,255,255,0.1);
}
.badge.pop-high { background:rgba(77,208,225,0.25); color:#4dd0e1; }
.badge.pop-mid  { background:rgba(255,213,79,0.2);  color:#ffd54f; }
.pop-zero { color: var(--text-muted); }
td .wind-arrow { font-size:16px; }
td .wf-icon    { font-size:16px; }

/* ── 로딩 ── */
.loading-veil {
    display:none; position:fixed; inset:0;
    background:rgba(0,0,0,0.45); z-index:99;
    align-items:center; justify-content:center;
    flex-direction:column; gap:16px;
}
.loading-veil.on { display:flex; }
.spinner {
    width:48px; height:48px;
    border:4px solid rgba(255,255,255,0.15);
    border-top-color: var(--accent);
    border-radius:50%;
    animation:spin .7s linear infinite;
}
@keyframes spin { to{transform:rotate(360deg)} }
.loading-veil p { font-size:14px; font-weight:500; color:rgba(255,255,255,0.8); }

/* ── 오류 ── */
.error-box {
    background:rgba(239,83,80,0.15); border:1px solid rgba(239,83,80,0.35);
    border-radius:12px; padding:16px 20px; color:#ef9a9a;
    font-size:13px; margin:20px 0; line-height:1.7;
}
.sample-notice {
    background:rgba(255,213,79,0.12); border:1px solid rgba(255,213,79,0.3);
    border-radius:10px; padding:9px 16px; font-size:11px;
    color:#ffd54f; margin-bottom:16px;
}

/* ── 페이드 ── */
.content-area { transition: opacity .35s ease; }
.content-area.fading { opacity:0; }
</style>
</head>
<body class="sky-clear">

<canvas id="particleCanvas"></canvas>

<div class="loading-veil" id="loadingVeil">
    <div class="spinner"></div>
    <p>날씨 데이터 조회 중…</p>
</div>

<div class="page">
    <!-- 헤더 -->
    <div class="header">
        <div class="header-title">
            <h1>🌐 기상청 동네예보</h1>
            <div class="coord">격자 좌표 X=<%= gridx %>, Y=<%= gridy %> &nbsp;|&nbsp; 10분 자동 갱신</div>
        </div>
        <div class="status-pill">
            <span>⏱ 다음 갱신</span>
            <span class="countdown" id="countdown">10:00</span>
            <button class="btn-now" id="btnNow" onclick="doRefresh()">지금 갱신</button>
            <span id="statusMsg" style="font-size:11px;"></span>
        </div>
    </div>

    <!-- 데이터 영역 -->
    <div class="content-area" id="content">
        <p style="text-align:center;padding:60px 0;color:var(--text-muted);">데이터를 불러오는 중입니다…</p>
    </div>
</div>

<script>
/* ═══════════════════════════════════════════════
   설정
═══════════════════════════════════════════════ */
const REFRESH_SEC = 600;
const DATA_URL    = "weather_data_json.jsp?gridx=<%= gridx %>&gridy=<%= gridy %>";
const WIND_DIRS   = ["N","NE","E","SE","S","SW","W","NW"];

/* ═══════════════════════════════════════════════
   날씨 코드 → 테마 / 이모지 / 파티클 모드
═══════════════════════════════════════════════ */
function getWeatherMeta(sky, pty) {
    const p = String(pty), s = String(sky);
    if (p === "1") return {cls:"sky-rain",  icon:"🌧",  label:"비",          particle:"rain"};
    if (p === "2") return {cls:"sky-sleet", icon:"🌨",  label:"비/눈",       particle:"sleet"};
    if (p === "3") return {cls:"sky-sleet", icon:"🌨",  label:"눈/비",       particle:"sleet"};
    if (p === "4") return {cls:"sky-snow",  icon:"❄️", label:"눈",          particle:"snow"};
    if (s === "1") return {cls:"sky-clear", icon:"☀️", label:"맑음",        particle:"sun"};
    if (s === "2") return {cls:"sky-partly",icon:"⛅", label:"구름 조금",   particle:"none"};
    if (s === "3") return {cls:"sky-mostly",icon:"🌥", label:"구름 많음",   particle:"none"};
    if (s === "4") return {cls:"sky-overcast",icon:"☁️",label:"흐림",      particle:"none"};
    return          {cls:"sky-clear",       icon:"🌤", label:"",            particle:"none"};
}

/* ═══════════════════════════════════════════════
   파티클 시스템 (Canvas)
═══════════════════════════════════════════════ */
const pCanvas = document.getElementById("particleCanvas");
const pCtx    = pCanvas.getContext("2d");
let   pMode   = "none";
let   pParts  = [];
let   pRAF    = null;

function resizeCanvas() {
    pCanvas.width  = window.innerWidth;
    pCanvas.height = window.innerHeight;
}
window.addEventListener("resize", resizeCanvas);
resizeCanvas();

function initParticles(mode) {
    pMode  = mode;
    pParts = [];
    if (mode === "rain") {
        for (let i=0; i<120; i++) pParts.push({
            x: Math.random()*pCanvas.width,
            y: Math.random()*pCanvas.height,
            len: 12+Math.random()*14,
            speed: 14+Math.random()*10,
            alpha: 0.25+Math.random()*0.35
        });
    } else if (mode === "snow" || mode === "sleet") {
        for (let i=0; i<80; i++) pParts.push({
            x: Math.random()*pCanvas.width,
            y: Math.random()*pCanvas.height,
            r: 2+Math.random()*4,
            speed: 0.6+Math.random()*1.2,
            drift: (Math.random()-0.5)*0.5,
            alpha: 0.4+Math.random()*0.4
        });
    } else if (mode === "sun") {
        for (let i=0; i<6; i++) pParts.push({
            angle: (i/6)*Math.PI*2,
            dist: 80+Math.random()*40,
            alpha: 0, phase: Math.random()*Math.PI*2
        });
    }
}

function animParticles() {
    pCtx.clearRect(0,0,pCanvas.width,pCanvas.height);
    if (pMode === "rain") {
        pParts.forEach(p => {
            pCtx.save();
            pCtx.globalAlpha = p.alpha;
            pCtx.strokeStyle = "#c8e6ff";
            pCtx.lineWidth   = 1;
            pCtx.beginPath();
            pCtx.moveTo(p.x, p.y);
            pCtx.lineTo(p.x+2, p.y+p.len);
            pCtx.stroke();
            pCtx.restore();
            p.y += p.speed;
            if (p.y > pCanvas.height) { p.y = -p.len; p.x = Math.random()*pCanvas.width; }
        });
    } else if (pMode === "snow" || pMode === "sleet") {
        pParts.forEach(p => {
            pCtx.save();
            pCtx.globalAlpha = p.alpha;
            pCtx.fillStyle   = pMode==="snow" ? "#e3f2fd" : "#b0bec5";
            pCtx.beginPath();
            pCtx.arc(p.x, p.y, p.r, 0, Math.PI*2);
            pCtx.fill();
            pCtx.restore();
            p.y += p.speed; p.x += p.drift;
            if (p.y > pCanvas.height) { p.y=-p.r*2; p.x=Math.random()*pCanvas.width; }
        });
    } else if (pMode === "sun") {
        const cx=pCanvas.width*0.85, cy=80, t=Date.now()/1000;
        pParts.forEach((p,i) => {
            const a = p.angle + t*0.12;
            const x = cx + Math.cos(a)*p.dist;
            const y = cy + Math.sin(a)*p.dist;
            const al= 0.07+0.05*Math.sin(t*1.5+p.phase);
            pCtx.save();
            pCtx.globalAlpha = al;
            pCtx.fillStyle   = "#ffd54f";
            pCtx.beginPath();
            pCtx.arc(x, y, 6, 0, Math.PI*2);
            pCtx.fill();
            pCtx.restore();
        });
        // 코어 글로우
        const grd = pCtx.createRadialGradient(cx,cy,0,cx,cy,120);
        grd.addColorStop(0,"rgba(255,213,79,0.12)");
        grd.addColorStop(1,"rgba(255,213,79,0)");
        pCtx.save(); pCtx.fillStyle=grd; pCtx.beginPath();
        pCtx.arc(cx,cy,120,0,Math.PI*2); pCtx.fill(); pCtx.restore();
    }
    pRAF = requestAnimationFrame(animParticles);
}
cancelAnimationFrame(pRAF);
animParticles();

/* ═══════════════════════════════════════════════
   Chart.js 인스턴스 관리
═══════════════════════════════════════════════ */
let charts = {};

function destroyCharts() {
    Object.values(charts).forEach(c => c && c.destroy());
    charts = {};
}

function getVar(name) {
    return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
        || getComputedStyle(document.body).getPropertyValue(name).trim();
}

function buildCharts(data) {
    destroyCharts();
    if (!data || !data.length) return;

    const labels = data.map(d => d.timeLabel);
    const accentColor  = getVar("--accent")  || "#4fc3f7";
    const accent2Color = getVar("--accent2") || "#81d4fa";
    const gridColor    = getVar("--chart-grid") || "rgba(255,255,255,0.08)";
    const textColor    = getVar("--text-muted") || "rgba(255,255,255,0.55)";

    const baseOpts = {
        responsive:true, maintainAspectRatio:false,
        animation:{ duration:600, easing:"easeInOutQuart" },
        plugins:{
            legend:{ display:false },
            tooltip:{
                backgroundColor:"rgba(0,0,0,0.7)",
                titleColor:"#fff", bodyColor:"rgba(255,255,255,0.75)",
                borderColor:"rgba(255,255,255,0.1)", borderWidth:1,
                padding:10, cornerRadius:8
            }
        },
        scales:{
            x:{
                grid:{ color:gridColor },
                ticks:{ color:textColor, font:{size:9}, maxRotation:45 }
            },
            y:{
                grid:{ color:gridColor },
                ticks:{ color:textColor, font:{size:9} }
            }
        }
    };

    /* ─ 기온 (꺾은선) ─ */
    const tempData = data.map(d => d.temp);
    const tmxData  = data.map(d => d.tmx);
    const tmnData  = data.map(d => d.tmn);
    const ctxTemp  = document.getElementById("chartTemp");
    if (ctxTemp) {
        charts.temp = new Chart(ctxTemp, {
            type:"line",
            data:{
                labels,
                datasets:[
                    { label:"최고기온", data:tmxData,
                      borderColor:"rgba(255,120,120,0.6)", borderDash:[4,3], borderWidth:1.5,
                      pointRadius:0, fill:false, tension:.4, spanGaps:true },
                    { label:"현재기온", data:tempData,
                      borderColor: accentColor, borderWidth:2.5,
                      pointBackgroundColor: accentColor, pointRadius:3, pointHoverRadius:5,
                      fill:{target:"origin", above:"rgba(79,195,247,0.07)"},
                      tension:.4, spanGaps:true },
                    { label:"최저기온", data:tmnData,
                      borderColor:"rgba(100,181,246,0.55)", borderDash:[4,3], borderWidth:1.5,
                      pointRadius:0, fill:false, tension:.4, spanGaps:true }
                ]
            },
            options:{ ...baseOpts,
                plugins:{ ...baseOpts.plugins,
                    legend:{ display:true,
                        labels:{ color:textColor, font:{size:10}, boxWidth:12, padding:10 } }
                },
                scales:{ ...baseOpts.scales,
                    y:{ ...baseOpts.scales.y,
                        ticks:{ ...baseOpts.scales.y.ticks,
                            callback: v => v + "°" } }
                }
            }
        });
    }

    /* ─ 강수확률 (막대) ─ */
    const popData = data.map(d => d.pop);
    const ctxPop  = document.getElementById("chartPop");
    if (ctxPop) {
        charts.pop = new Chart(ctxPop, {
            type:"bar",
            data:{
                labels,
                datasets:[{
                    label:"강수확률",
                    data: popData,
                    backgroundColor: popData.map(v =>
                        v >= 60 ? "rgba(41,182,246,0.75)" :
                        v >= 30 ? "rgba(41,182,246,0.45)" :
                                  "rgba(41,182,246,0.2)"),
                    borderColor: popData.map(v =>
                        v >= 60 ? "#29b6f6" :
                        v >= 30 ? "rgba(41,182,246,0.6)" :
                                  "rgba(41,182,246,0.3)"),
                    borderWidth: 1.5,
                    borderRadius: 5,
                    barPercentage: 0.7
                }]
            },
            options:{ ...baseOpts,
                scales:{ ...baseOpts.scales,
                    y:{ ...baseOpts.scales.y, min:0, max:100,
                        ticks:{ ...baseOpts.scales.y.ticks,
                            callback: v => v + "%" } }
                }
            }
        });
    }

    /* ─ 습도 (에리어) ─ */
    const rehData = data.map(d => d.reh);
    const ctxReh  = document.getElementById("chartReh");
    if (ctxReh) {
        charts.reh = new Chart(ctxReh, {
            type:"line",
            data:{
                labels,
                datasets:[{
                    label:"습도",
                    data: rehData,
                    borderColor: accent2Color, borderWidth:2,
                    pointBackgroundColor: accent2Color, pointRadius:2.5,
                    fill:{ target:"origin", above:"rgba(129,212,250,0.12)" },
                    tension:.45, spanGaps:true
                }]
            },
            options:{ ...baseOpts,
                scales:{ ...baseOpts.scales,
                    y:{ ...baseOpts.scales.y, min:0, max:100,
                        ticks:{ ...baseOpts.scales.y.ticks,
                            callback: v => v + "%" } }
                }
            }
        });
    }

    /* ─ 풍속 (꺾은선) ─ */
    const wsData = data.map(d => d.ws);
    const ctxWs  = document.getElementById("chartWs");
    if (ctxWs) {
        charts.ws = new Chart(ctxWs, {
            type:"line",
            data:{
                labels,
                datasets:[{
                    label:"풍속",
                    data: wsData,
                    borderColor:"rgba(178,235,242,0.85)", borderWidth:2,
                    pointBackgroundColor:"#80deea", pointRadius:2.5,
                    fill:{ target:"origin", above:"rgba(178,235,242,0.07)" },
                    tension:.35, spanGaps:true
                }]
            },
            options:{ ...baseOpts,
                scales:{ ...baseOpts.scales,
                    y:{ ...baseOpts.scales.y, min:0,
                        ticks:{ ...baseOpts.scales.y.ticks,
                            callback: v => v + "m/s" } }
                }
            }
        });
    }
}

/* ═══════════════════════════════════════════════
   DOM 렌더링
═══════════════════════════════════════════════ */
function windArrow(wd) {
    const arrows=["↓","↙","←","↖","↑","↗","→","↘"];
    return arrows[parseInt(wd)] || "-";
}
function skyIcon(sky, pty) {
    if(pty==="1") return "🌧"; if(pty==="2"||pty==="3") return "🌨";
    if(pty==="4") return "❄️";
    if(sky==="1") return "☀️"; if(sky==="2") return "⛅";
    if(sky==="3") return "🌥"; if(sky==="4") return "☁️";
    return "-";
}
function fmtPop(v) {
    if(!v || v===0) return '<span class="pop-zero">—</span>';
    const cls = v>=60 ? "pop-high" : v>=30 ? "pop-mid" : "";
    return `<span class="badge ${cls}">${v}%</span>`;
}

function renderContent(json) {
    const d = json;
    const meta = getWeatherMeta(d.currentSky, d.currentPty);

    /* 테마 클래스 교체 */
    document.body.className = meta.cls;

    /* 파티클 모드 교체 */
    initParticles(meta.particle);

    /* 히어로 카드 */
    const tempStr = d.currentTemp != null ? d.currentTemp + "<sup>°C</sup>" : "-";
    const rehStr  = d.currentReh  != null ? d.currentReh + "%" : "-";
    const wsStr   = d.currentWs   != null ? d.currentWs + " m/s" : "-";
    const sampleBanner = (d.dataSrc === "SAMPLE")
        ? `<div class="sample-notice">⚠ 실제 기상청 API 접속 실패 – 샘플 데이터로 표시 중입니다.</div>` : "";

    let rows = "";
    (d.data || []).forEach((item, i) => {
        const isToday  = item.day === "0";
        const rowClass = isToday ? "today" : "";
        const icon     = skyIcon(item.sky, item.pty);
        rows += `<tr class="${rowClass}">
            <td>${item.timeLabel}</td>
            <td class="wf-icon">${icon}</td>
            <td>${item.wfKor}</td>
            <td style="font-weight:600;color:var(--accent)">${item.temp != null ? item.temp + "°" : "—"}</td>
            <td style="color:#ef9a9a">${item.tmx != null ? item.tmx + "°" : "—"}</td>
            <td style="color:#90caf9">${item.tmn != null ? item.tmn + "°" : "—"}</td>
            <td>${fmtPop(item.pop)}</td>
            <td>${item.reh != null ? item.reh + "%" : "—"}</td>
            <td>${item.ws != null ? item.ws : "—"} <small>m/s</small></td>
            <td><span class="wind-arrow">${windArrow(item.wd)}</span> ${item.wdKor}</td>
            <td>${item.r06 && item.r06 !== "0.0" ? item.r06 + "mm" : '<span class="pop-zero">—</span>'}</td>
            <td>${item.s06 && item.s06 !== "0.0" ? item.s06 + "cm" : '<span class="pop-zero">—</span>'}</td>
        </tr>`;
    });

    document.getElementById("content").innerHTML = `
${sampleBanner}
<div class="hero-card">
    <div class="hero-main">
        <div class="hero-icon">${meta.icon}</div>
        <div>
            <div class="hero-temp">${tempStr}</div>
            <div class="hero-desc">
                <div class="hero-wf">${meta.label || d.currentWf}</div>
                <div class="hero-time">발표: ${d.tm || "-"} &nbsp;|&nbsp; 갱신: ${d.fetchedAt}</div>
            </div>
        </div>
    </div>
    <div class="hero-meta">
        <div class="meta-item">
            <div class="label">💧 습도</div>
            <div class="value">${rehStr}</div>
        </div>
        <div class="meta-item">
            <div class="label">💨 풍속</div>
            <div class="value">${wsStr}</div>
        </div>
        <div class="meta-item">
            <div class="label">🧭 풍향</div>
            <div class="value">${d.currentWdKor || "-"}</div>
        </div>
        <div class="meta-item">
            <div class="label">📡 데이터</div>
            <div class="value" style="font-size:.95rem">${d.dataSrc}</div>
        </div>
    </div>
</div>

<div class="charts-grid">
    <div class="chart-card wide">
        <div class="chart-title"><span class="dot"></span>기온 추이 (현재·최고·최저)</div>
        <div class="chart-wrap tall"><canvas id="chartTemp"></canvas></div>
    </div>
    <div class="chart-card">
        <div class="chart-title"><span class="dot"></span>강수확률 (%)</div>
        <div class="chart-wrap"><canvas id="chartPop"></canvas></div>
    </div>
    <div class="chart-card">
        <div class="chart-title"><span class="dot"></span>습도 (%)</div>
        <div class="chart-wrap"><canvas id="chartReh"></canvas></div>
    </div>
    <div class="chart-card wide">
        <div class="chart-title"><span class="dot"></span>풍속 (m/s)</div>
        <div class="chart-wrap"><canvas id="chartWs"></canvas></div>
    </div>
</div>

<div class="table-card">
    <div class="section-title"><span class="dot" style="width:6px;height:6px;border-radius:50%;background:var(--accent);flex-shrink:0;display:inline-block"></span>시간별 상세 데이터</div>
    <div class="table-scroll">
    <table>
        <thead><tr>
            <th>시간</th><th>날씨</th><th>상태</th>
            <th>현재온도</th><th>최고</th><th>최저</th>
            <th>강수확률</th><th>습도</th><th>풍속</th><th>풍향</th>
            <th>6h강수</th><th>6h적설</th>
        </tr></thead>
        <tbody>${rows}</tbody>
    </table>
    </div>
</div>`;

    /* 차트 빌드 (DOM 삽입 후 다음 프레임) */
    requestAnimationFrame(() => buildCharts(d.data || []));
}

/* ═══════════════════════════════════════════════
   카운트다운
═══════════════════════════════════════════════ */
let remainSec = REFRESH_SEC;
let cdTimer   = null;
const cdEl    = document.getElementById("countdown");
const btnNow  = document.getElementById("btnNow");
const statusEl= document.getElementById("statusMsg");

function startCountdown() {
    clearInterval(cdTimer);
    remainSec = REFRESH_SEC;
    cdTimer = setInterval(() => {
        if (remainSec > 0) { remainSec--; }
        const m = String(Math.floor(remainSec/60)).padStart(2,"0");
        const s = String(remainSec%60).padStart(2,"0");
        cdEl.textContent = m+":"+s;
        cdEl.classList.toggle("urgent", remainSec <= 30);
    }, 1000);
}

/* ═══════════════════════════════════════════════
   AJAX 갱신
═══════════════════════════════════════════════ */
let isFetching = false;
let autoTimer  = null;
const veil     = document.getElementById("loadingVeil");
const content  = document.getElementById("content");

function fetchWeather() {
    if (isFetching) return;
    isFetching = true;
    btnNow.disabled = true;
    veil.classList.add("on");
    statusEl.textContent = "";

    fetch(DATA_URL + "&_t=" + Date.now())
        .then(r => { if(!r.ok) throw new Error("HTTP "+r.status); return r.json(); })
        .then(json => {
            if (!json.ok) {
                content.innerHTML = `<div class="error-box">
                    ❌ 데이터 조회 실패<br><small>${json.error || ""}</small>
                    <br><small>갱신 시각: ${json.fetchedAt||""}</small></div>`;
                return;
            }
            content.classList.add("fading");
            setTimeout(() => {
                renderContent(json);
                content.classList.remove("fading");
            }, 350);
        })
        .catch(err => {
            statusEl.textContent = "⚠ " + err.message;
            statusEl.style.color = "#ef9a9a";
        })
        .finally(() => {
            isFetching = false;
            btnNow.disabled = false;
            veil.classList.remove("on");
            startCountdown();
        });
}

function scheduleAuto() {
    clearInterval(autoTimer);
    autoTimer = setInterval(fetchWeather, REFRESH_SEC * 1000);
}

window.doRefresh = function() {
    clearInterval(autoTimer);
    fetchWeather();
    scheduleAuto();
};

/* 최초 실행 */
fetchWeather();
scheduleAuto();
startCountdown();
</script>
</body>
</html>
