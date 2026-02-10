FROM python:3.9-slim

# 취약점 1: Running as root (no USER directive)
WORKDIR /app

# 취약점 2: Using vulnerable base image version
COPY requirements.txt .

# 취약점 3: No integrity checks on dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Create data directory for path traversal tests
RUN mkdir -p /app/data && \
    echo "Sample file content" > /app/data/default.txt

# 취약점 4: Exposing unnecessary ports
EXPOSE 5000

# 취약점 5: Running with debug mode enabled
ENV FLASK_ENV=development
ENV FLASK_DEBUG=1

# 취약점 6: No health check defined
# HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:5000/health || exit 1

# 취약점 7: Running as root user
CMD ["python", "app.py"]
