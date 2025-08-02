FROM astral/uv:0.8.3-debian AS builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH="/app/src"

WORKDIR /app

# Copy pyproject and lockfile
COPY pyproject.toml uv.lock ./

# Install dependencies globally (not in .venv)
RUN uv sync --frozen

# Copy source code
COPY src ./src


FROM astral/uv:0.8.3-debian AS final

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH="/app/src"

WORKDIR /app

# Install git (if needed for your cronjob tasks)
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/src ./src

ENV PATH="/app/.venv/bin:$PATH"


CMD ["uv", "run", "ai-doc-gen"]
