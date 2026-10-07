from flask import Flask, Response
from prometheus_client import generate_latest
app = Flask(__name__)

@app.get("/health")
def health():
    return "healthy", 200

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype="text/plain")

@app.get("/")
def root():
    return "ECS backend is running", 200

app.run(host="0.0.0.0", port=5000)
