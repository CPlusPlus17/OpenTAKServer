# Stage 1: Builder
FROM python:3.12-slim-bookworm as builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN pip install poetry

# Copy only dependency files first to leverage cache
COPY pyproject.toml poetry.lock ./
# Copy lib to allow dynamic versioning if needed
COPY . .

# Configure poetry to create venv in project
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

# Install dependencies and the project itself
# We use --only main to exclude test dependencies
# Force lock update because local lock might be out of sync
RUN poetry lock --no-interaction --no-ansi
RUN poetry install --no-interaction --no-ansi --only main

# Stage 2: Runtime
FROM python:3.12-slim-bookworm

# Create ots user
RUN addgroup --gid 1024 ots \
    && adduser --home /app --disabled-password --gecos "" --force-badname --uid 1024 --gid 1024 ots

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    curl \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

USER ots
WORKDIR /app

# Copy virtual environment from builder (Poetry creates .venv)
COPY --from=builder --chown=ots:ots /app/.venv /app/venv

# Copy application code
COPY --chown=ots:ots . .

# Set environment to use venv
ENV PATH="/app/venv/bin:$PATH"

EXPOSE 8081

# Ensure entrypoint is executable (should be from COPY, but just in case)
RUN chmod +x entrypoint.sh

HEALTHCHECK --interval=1m CMD curl --fail http://localhost:8081/api/health || exit 1

ENTRYPOINT ["./entrypoint.sh"]

STOPSIGNAL SIGINT