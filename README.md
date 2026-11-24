# Assignment 2: Dockerize a Small App with a Basic CI Check

A containerized Python Flask application with a GitHub Actions CI workflow that builds the Docker image on every push.

## Project Structure

- `app.py` — Flask web server exposing `/` and `/health` on `0.0.0.0:5000`
- `requirements.txt` — Pinned Python dependencies
- `Dockerfile` — Container definition using `python:3.12-slim`
- `.github/workflows/build.yml` — GitHub Actions workflow that builds the Docker image on `push`

---

## Bugs Found & Fixes Applied

When taking the teammate's starter files (`app.py` and `requirements.txt`) into Docker, the following issues prevent the app from running or being reachable and were addressed as follows:

1. **Missing container configuration (`Dockerfile`)**
   - **Problem:** Only `app.py` and `requirements.txt` were provided—there was no `Dockerfile` to set up the Python environment, install Flask, expose port `5000`, or run the application inside a container.
   - **Fix:** Created `Dockerfile` using `python:3.12-slim`, setting `WORKDIR /app`, installing dependencies from `requirements.txt`, exposing port `5000`, and starting the server with `CMD ["python", "app.py"]`.

2. **Container port publishing & macOS port `5000` conflict**
   - **Problem:** For a containerized Flask app to be reachable from the host, the server must bind to `0.0.0.0` (rather than `127.0.0.1`) and container port `5000` must be published via `-p` during `docker run`. On macOS, host port `5000` is also commonly occupied by AirPlay Receiver, which makes `localhost:5000` unreachable or return a non-Flask response.
   - **Fix:** Kept `app.run(host="0.0.0.0", port=5000)` in `app.py`, added `EXPOSE 5000` in `Dockerfile`, and published the port with `-p 5000:5000` (or `-p 5001:5000` on macOS when AirPlay Receiver occupies port `5000`).

3. **Unpinned dependency in `requirements.txt`**
   - **Problem:** `requirements.txt` listed `flask` without a version pin, which risks non-reproducible builds across local machines and CI runners.
   - **Fix:** Pinned Flask to `flask==3.1.0` in `requirements.txt`.

4. **Missing automated CI build check**
   - **Problem:** Without a CI workflow, broken `Dockerfile` or dependency changes could go unnoticed until manual testing.
   - **Fix:** Added `.github/workflows/build.yml` using `actions/checkout@v4`, `docker/setup-buildx-action@v3`, and `docker/build-push-action@v6` (`push: false`) to build and verify the Docker image on every `push`.

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

Verified terminal output:

```text
HTTP/1.1 200 OK
Server: Werkzeug/3.1.9 Python/3.12.16
Content-Type: application/json
Content-Length: 16
Connection: close

{"status":"ok"}
```

![Health check output](./Screenshot%202026-11-25%20at%203.22.33%E2%80%AFAM.png)

You can also verify the root route:

```bash
curl http://localhost:5001/
# Hello from DevOps!
```

---

## CI Check (GitHub Actions)

The workflow at `.github/workflows/build.yml` triggers on every `push` event, sets up Docker Buildx, and builds the Docker image (`push: false`) to verify that the `Dockerfile` and application dependencies build cleanly.
