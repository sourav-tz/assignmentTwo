"""Simple Flask application with root and health-check endpoints."""

from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    """Return a greeting message for the root route."""
    return "Hello from DevOps!"


@app.route("/health")
def health():
    """Return service health status as JSON."""
    return {"status": "ok"}


if __name__ == "__main__":
    # Bind to 0.0.0.0 so the app is reachable from outside the container.
    app.run(host="0.0.0.0", port=5000)
