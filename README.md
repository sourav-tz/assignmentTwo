# Assignment 2: Dockerize a Small App with a Basic CI Check

A containerized Python Flask application with a GitHub Actions CI workflow that builds the Docker image on every push.

## Project Structure

- `app.py` — Flask web server exposing `/` and `/health` on `0.0.0.0:5000`
- `requirements.txt` — Pinned Python dependencies
- `Dockerfile` — Container definition using `python:3.12-slim`
- `.github/workflows/build.yml` — GitHub Actions workflow that builds the Docker image on `push`

---

## Bugs Found & Fixes Applied

The original starter snippet failed to start (making the app unreachable) due to the following issues:

1. **Stray `Python` line at the top of `app.py`**
   - **Problem:** The top of `app.py` contained a stray `Python` line, causing a syntax/name error before Flask could run.
   - **Fix:** Removed the stray line so `from flask import Flask` is the first line.

2. **Missing `=` operator and indentation in `app.py`**
   - **Problem:** `app Flask(__name__)` was missing `=`, and the bodies of `home()`, `health()`, and `if __name__ == "__main__":` were not indented (`IndentationError`).
   - **Fix:** Fixed `app = Flask(__name__)` and properly indented the route handlers and `app.run(host="0.0.0.0", port=5000)`.

3. **Stray `None` line and unpinned dependency in `requirements.txt`**
   - **Problem:** `requirements.txt` contained a stray `None` line and an unpinned `flask` entry.
   - **Fix:** Removed `None` and pinned `flask==3.1.0` in `requirements.txt`.

4. **Host binding and port publishing for container access**
   - **Problem:** A Flask app inside Docker must bind to `0.0.0.0` and map its container port (`5000`) to a host port to be reachable outside the container.
   - **Fix:** Kept `app.run(host="0.0.0.0", port=5000)` in `app.py`, exposed port `5000` in `Dockerfile`, and published the port with `-p` during `docker run` (using `5001:5000` on macOS if port `5000` is used by AirPlay Receiver).

---

## Build and Run with Docker

### 1. Build the Docker image

```bash
docker build -t flask-devops-app .
```

### 2. Run the container

```bash
docker run -d -p 5000:5000 --name flask-app flask-devops-app
```

> **Note (macOS):** If port `5000` is already in use by AirPlay Receiver, map host port `5001` to container port `5000` instead:
> ```bash
> docker run -d -p 5001:5000 --name flask-app flask-devops-app
> ```

To stop and remove the container later:

```bash
docker stop flask-app && docker rm flask-app
```

---

## Verify `/health` Endpoint

Run the container and test `/health` (replace `5001` with `5000` if you mapped `-p 5000:5000`):

```bash
curl -i http://localhost:5001/health
```

Expected output (paste your local terminal output or screenshot here after running):

```text
HTTP/1.1 200 OK
Content-Type: application/json
...

{"status":"ok"}
```

You can also verify the root route:

```bash
curl http://localhost:5001/
# Hello from DevOps!
```

---

## CI Check (GitHub Actions)

The workflow at `.github/workflows/build.yml` triggers on every `push` event, sets up Docker Buildx, and builds the Docker image (`push: false`) to verify that the `Dockerfile` and application dependencies build cleanly.
