import json
from main import app

def test_healthz():
    client = app.test_client()
    resp = client.get("/healthz")

    assert resp.status_code == 200
    assert resp.get_json() == {"status": "OK"}


def test_root():
    client = app.test_client()
    resp = client.get("/")

    assert resp.status_code == 200
    data = resp.get_json()

    assert "message" in data
    assert data["message"] == "Hello from Flask API!"
    assert "usage" in data
    assert data["usage"]["health"] == "/healthz"
    assert data["usage"]["echo"] == "/echo?msg=hi"


def test_echo_with_msg():
    client = app.test_client()
    resp = client.get("/echo?msg=hello")

    assert resp.status_code == 200
    assert resp.get_json() == {"echo": "hello"}


def test_echo_without_msg():
    client = app.test_client()
    resp = client.get("/echo")

    assert resp.status_code == 200
    assert resp.get_json() == {"echo": ""}
