from flask import Flask, jsonify, request

app = Flask(__name__)

@app.get("/healthz")
def healthz():
    return jsonify(status="ok"), 200

@app.get("/")
def root():
    return jsonify(
        message="Hello from Flask API!",
        usage={"health": "/healthz", "echo": "/echo?msg=hi"},
    ), 200

@app.get("/echo")
def echo():
    msg = request.args.get("msg", "")
    return jsonify(echo=msg), 200

if __name__ == "__main__":
    # For local dev only. In Docker/production we use gunicorn.
    app.run(host="0.0.0.0", port=8080, debug=True)
