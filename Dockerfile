FROM python:3.13 AS builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH="/app/src"

WORKDIR /app

# Install uv and dependencies
RUN pip install --no-cache-dir uv
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Copy source code
COPY src ./src

# Final stage: minimal image
FROM python:3.13-slim AS final

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH="/app/src"

WORKDIR /app

# Install uv only (for running)
RUN pip install --no-cache-dir uv

# Copy only installed packages and source code from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /app/src ./src

CMD ["uv", "run", "ai-doc-gen"]
