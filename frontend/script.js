async function api(url, options = {}) {
  const response = await fetch(url, {headers: {"Content-Type": "application/json"}, ...options});
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.error || "Request failed");
  return data;
}

function escapeHtml(value) {
  return String(value ?? "").replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#039;");
}
function badge(value, cls="status") {
  return `<span class="badge ${cls}-${escapeHtml(value)}">${escapeHtml(value)}</span>`;
}

async function checkHealth() {
  const el = document.getElementById("dbStatus");
  if (!el) return;
  try { await api("/api/health"); el.innerHTML = '<span class="online">● Connected</span>'; }
  catch { el.innerHTML = '<span class="error">● Offline</span>'; }
}

async function loadDashboard() {
  const table = document.getElementById("accidentTable");
  if (!table) return;
  try {
    const stats = await api("/api/dashboard");
    document.getElementById("totalAccidents").textContent = stats.total_accidents;
    document.getElementById("activeIncidents").textContent = stats.active_incidents;
    document.getElementById("resolvedIncidents").textContent = stats.resolved_incidents;
    document.getElementById("availableAmbulances").textContent = stats.available_ambulances;

    const accidents = await api("/api/accidents");
    table.innerHTML = accidents.length ? accidents.slice(0,8).map(a => `
      <tr><td>#${a.id}</td><td>${escapeHtml(a.location)}</td><td>${escapeHtml(a.accident_type)}</td>
      <td>${badge(a.severity,"severity")}</td><td>${badge(a.status)}</td><td>${escapeHtml(a.created_at)}</td></tr>
    `).join("") : '<tr><td colspan="6" class="empty">No accident records found.</td></tr>';
    checkHealth();
  } catch(e) { table.innerHTML = `<tr><td colspan="6" class="empty error">${escapeHtml(e.message)}</td></tr>`; }
}

async function loadTraffic() {
  const table = document.getElementById("trafficTable");
  if (!table) return;
  try {
    const rows = await api("/api/traffic");
    table.innerHTML = rows.length ? rows.map(t => `
      <tr><td>${escapeHtml(t.road_name)}</td><td>${escapeHtml(t.area)}</td>
      <td>${badge(t.traffic_level,"severity")}</td><td>${escapeHtml(t.reason || "-")}</td><td>${escapeHtml(t.updated_at)}</td></tr>
    `).join("") : '<tr><td colspan="5" class="empty">No traffic records found.</td></tr>';
  } catch(e) { table.innerHTML = `<tr><td colspan="5" class="empty error">${escapeHtml(e.message)}</td></tr>`; }
}

function setupAccidentForm() {
  const form = document.getElementById("accidentForm");
  if (!form) return;
  form.addEventListener("submit", async e => {
    e.preventDefault();
    const message = document.getElementById("formMessage");
    try {
      const result = await api("/api/accidents", {method:"POST", body:JSON.stringify(Object.fromEntries(new FormData(form).entries()))});
      message.className = "message success";
      message.textContent = `Accident #${result.id} reported successfully.`;
      form.reset();
    } catch(e) { message.className = "message error"; message.textContent = e.message; }
  });
}

function setupTrafficForm() {
  const form = document.getElementById("trafficForm");
  if (!form) return;
  form.addEventListener("submit", async e => {
    e.preventDefault();
    const message = document.getElementById("trafficMessage");
    try {
      await api("/api/traffic", {method:"POST", body:JSON.stringify(Object.fromEntries(new FormData(form).entries()))});
      message.className = "message success";
      message.textContent = "Traffic update added successfully.";
      form.reset();
      loadTraffic();
    } catch(e) { message.className = "message error"; message.textContent = e.message; }
  });
}

document.addEventListener("DOMContentLoaded", () => {
  loadDashboard();
  loadTraffic();
  setupAccidentForm();
  setupTrafficForm();
});
