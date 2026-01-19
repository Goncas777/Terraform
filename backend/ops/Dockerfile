FROM python:3.11-slim AS builder

WORKDIR /app
ENV PYTHONPATH=/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        git \
    && pip install poetry \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root --only main

COPY backend/src/ ./backend/src/
COPY backend/alembic ./backend/alembic
COPY backend/alembic.ini ./backend/alembic.ini
EXPOSE 8000
CMD ["poetry", "run", "uvicorn", "backend.src.main:app", "--host", "0.0.0.0", "--port", "8000", "--log-level", "debug"]