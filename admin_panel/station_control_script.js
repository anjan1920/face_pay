/* ──────────────────────────────────────────────────────────
   Config  –  tweak these if your Flask routes differ
─────────────────────────────────────────────────────────── */
const API_BASE             = 'http://localhost:5000';
const STATION_ID_ENDPOINT  = '/station_id';   // POST {station_name}
const STATION_LOG_ENDPOINT = '/station_log';  // POST {station_id}
const REFRESH_MS           = 15_000;          // 15 s auto‑refresh

/* ──────────────────────────────────────────────────────────
   Globals  –  store IDs for the periodic refresh
─────────────────────────────────────────────────────────── */
let currentStationId   = null;
let currentPrettyName  = null;
let refreshTimer       = null;

/* ──────────────────────────────────────────────────────────
   Boot
─────────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', init);

async function init() {
  const stationName = new URLSearchParams(location.search).get('station');
  if (!stationName) {
    fillHeader('Unknown station');
    return;
  }

  try {
    /* 1️⃣  name ➜ id */
    const idRes = await fetch(`${API_BASE}${STATION_ID_ENDPOINT}`, {
      method : 'POST',
      headers: { 'Content-Type': 'application/json' },
      body   : JSON.stringify({ station_name: stationName })
    });
    if (!idRes.ok) throw new Error(`station_id API ${idRes.status}`);
    const idData = await idRes.json();
    if (!idData.success) throw new Error(idData.error || 'station_id failed');

    currentStationId  = idData.station_id;
    currentPrettyName = idData.station_name || stationName;

    /* 2️⃣  first load + start polling */
    await refreshLogs();
    refreshTimer = setInterval(refreshLogs, REFRESH_MS);

  } catch (err) {
    console.error(err);
    fillHeader(`Admin Panel ${stationName} ${currentStationId }`);
  }
}

/* ──────────────────────────────────────────────────────────
   Fetch logs → update UI
─────────────────────────────────────────────────────────── */
async function refreshLogs() {
  if (!currentStationId) return;   // should never happen, but safe‑guard

  try {
    const resp = await fetch(`${API_BASE}${STATION_LOG_ENDPOINT}`, {
      method : 'POST',
      headers: { 'Content-Type': 'application/json' },
      body   : JSON.stringify({ station_id: currentStationId })
    });
    if (!resp.ok) throw new Error(`station_log API ${resp.status}`);

    const data = await resp.json();
    if (!data.success) throw new Error(data.error || 'station_log failed');

    fillHeader(`Admin Panel – ${currentPrettyName} (${currentStationId})`);
    populateBox('#entry-box', data.entries, true);
    populateBox('#exit-box',  data.exits,  false);

  } catch (err) {
    console.error(err);
    // keep the old data visible, but show a header warning
    fillHeader(`Admin Panel – ${currentPrettyName} (offline)`);
  }
}

/* ──────────────────────────────────────────────────────────
   Populate Entry or Exit box
─────────────────────────────────────────────────────────── */
function populateBox(boxSel, rows, isEntry) {
  const box     = document.querySelector(boxSel);
  const userLis = box.querySelectorAll('.user_id ul');
  const timeLis = box.querySelectorAll(
      (isEntry ? '.entry-time' : '.exit-time') + ' ul'
  );

  for (let i = 0; i < userLis.length; i++) {
    const row = rows[i];
    userLis[i].textContent = row ? row.user_name ?? '—' : '—';
    timeLis[i].textContent = row
      ? fmtTime(row[isEntry ? 'entry_time' : 'exit_time'])
      : '—';
  }
}

/* ──────────────────────────────────────────────────────────
   Helpers
─────────────────────────────────────────────────────────── */
function fmtTime(sql) {
  if (!sql) return '—';
  return new Date(sql.replace(' ', 'T'))
         .toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
}

function fillHeader(text) {
  document.getElementById('station_name').textContent = text;
}
