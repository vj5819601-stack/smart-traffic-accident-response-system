import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))
from app import app

def test_home_page():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert b"Smart Traffic" in response.data

def test_missing_accident_fields():
    client = app.test_client()
    response = client.post("/api/accidents", json={})
    assert response.status_code == 400
