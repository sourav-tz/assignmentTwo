# Lightweight Python base image
FROM python:3.12-slim

# Prevent Python from writing .pyc files and buffer stdout/stderr for clean logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory inside the container
WORKDIR /app

# Install Python dependencies first to leverage Docker layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source
COPY app.py .

# Document the port the Flask server listens on
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]
