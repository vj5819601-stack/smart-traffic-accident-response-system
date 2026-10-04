from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from pathlib import Path
from db import query_db, execute_db

app = Flask(__name__)
CORS(app)

FRONTEND_DIR = Path(__file__).resolve().parent.parent / "frontend"

@app.route("/")
def home():
    return send_from_directory(FRONTEND_DIR, "index.html")

@app.route("/<path:path>")
def static_files(path):
    file_path = FRONTEND_DIR / path
    if file_path.exists() and file_path.is_file():
        return send_from_directory(FRONTEND_DIR, path)
    return jsonify({"error": "Page not found"}), 404

@app.get("/api/health")
def health():
    try:
        query_db("SELECT 1 AS ok")
        return jsonify({"status": "ok", "database": "connected"})
    except Exception as exc:
        return jsonify({"status": "error", "database": str(exc)}), 503

@app.get("/api/dashboard")
def dashboard():
    total = query_db("SELECT COUNT(*) AS total FROM accidents")[0]["total"]
    active = query_db("SELECT COUNT(*) AS total FROM accidents WHERE status <> 'Resolved'")[0]["total"]
    resolved = query_db("SELECT COUNT(*) AS total FROM accidents WHERE status = 'Resolved'")[0]["total"]
    ambulances = query_db("SELECT COUNT(*) AS total FROM ambulances WHERE status = 'Available'")[0]["total"]
    roads = query_db("SELECT COUNT(*) AS total FROM traffic")[0]["total"]
    return jsonify({
        "total_accidents": total,
        "active_incidents": active,
        "resolved_incidents": resolved,
        "available_ambulances": ambulances,
        "monitored_roads": roads
    })

@app.get("/api/accidents")
def get_accidents():
    rows = query_db("""
        SELECT id, reporter_name, contact, location, accident_type,
               severity, description, status, created_at
        FROM accidents ORDER BY created_at DESC
    """)
    for row in rows:
        row["created_at"] = row["created_at"].strftime("%d %b %Y, %I:%M %p")
    return jsonify(rows)

@app.post("/api/accidents")
def create_accident():
    data = request.get_json(silent=True) or {}
    required = ["reporter_name", "contact", "location", "accident_type", "severity"]
    missing = [x for x in required if not str(data.get(x, "")).strip()]
    if missing:
        return jsonify({"error": "Missing fields: " + ", ".join(missing)}), 400

    accident_id = execute_db("""
        INSERT INTO accidents
        (reporter_name, contact, location, accident_type, severity, description, status)
        VALUES (%s, %s, %s, %s, %s, %s, 'Reported')
    """, (
        data["reporter_name"].strip(),
        data["contact"].strip(),
        data["location"].strip(),
        data["accident_type"].strip(),
        data["severity"].strip(),
        data.get("description", "").strip()
    ))
    return jsonify({"message": "Accident reported successfully", "id": accident_id}), 201

@app.patch("/api/accidents/<int:accident_id>/status")
def update_accident_status(accident_id):
    data = request.get_json(silent=True) or {}
    status = str(data.get("status", "")).strip()
    allowed = {"Reported", "Verified", "Ambulance Assigned", "Hospital Notified", "Resolved"}
    if status not in allowed:
        return jsonify({"error": "Invalid status"}), 400
    execute_db("UPDATE accidents SET status=%s WHERE id=%s", (status, accident_id))
    return jsonify({"message": "Status updated"})

@app.get("/api/traffic")
def get_traffic():
    rows = query_db("SELECT id, road_name, area, traffic_level, reason, updated_at FROM traffic ORDER BY updated_at DESC")
    for row in rows:
        row["updated_at"] = row["updated_at"].strftime("%d %b %Y, %I:%M %p")
    return jsonify(rows)

@app.post("/api/traffic")
def create_traffic():
    data = request.get_json(silent=True) or {}
    required = ["road_name", "area", "traffic_level"]
    missing = [x for x in required if not str(data.get(x, "")).strip()]
    if missing:
        return jsonify({"error": "Missing fields: " + ", ".join(missing)}), 400
    traffic_id = execute_db("""
        INSERT INTO traffic (road_name, area, traffic_level, reason)
        VALUES (%s, %s, %s, %s)
    """, (
        data["road_name"].strip(),
        data["area"].strip(),
        data["traffic_level"].strip(),
        data.get("reason", "").strip()
    ))
    return jsonify({"message": "Traffic record added", "id": traffic_id}), 201

@app.get("/api/ambulances")
def get_ambulances():
    return jsonify(query_db("SELECT id, vehicle_number, driver_name, contact, status, location FROM ambulances ORDER BY id"))

@app.get("/api/hospitals")
def get_hospitals():
    return jsonify(query_db("SELECT id, name, location, contact, available_beds, status FROM hospitals ORDER BY name"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
