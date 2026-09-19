FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy application code and dependency metadata
COPY . .

# Install Python dependencies when a requirements manifest is present.
# This keeps the image build valid for repositories that do not use pip requirements.txt.
RUN if [ -f requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt; \
    fi

# Expose gRPC port
EXPOSE 50051

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import grpc; channel = grpc.aio.secure_channel('localhost:50051', grpc.ssl_channel_credentials()); print('OK')" || exit 1

# Start the application
CMD ["python", "src/main.py", "--addr", "0.0.0.0:50051"]
