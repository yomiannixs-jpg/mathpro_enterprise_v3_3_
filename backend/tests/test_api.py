from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/api/health")
    assert response.status_code == 200

def test_catalog_has_olympiad():
    response = client.get("/api/catalog")
    assert response.status_code == 200
    assert "Olympiad Mathematics" in response.json()["fields"]
