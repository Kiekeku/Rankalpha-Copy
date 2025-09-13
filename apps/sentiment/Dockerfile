FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y curl gnupg git libpq-dev gcc build-essential python3-dev pkg-config \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && apt-get clean

RUN npm install -g npm@latest \
 && npm cache clean --force

RUN npm install -g g-search-mcp \
 && npm cache clean --force

# Install Filesystem MCP and Node Playwright for g-search-mcp at build time to avoid runtime hangs
RUN npm install -g @modelcontextprotocol/server-filesystem playwright \
 && npx -y playwright install chromium \
 && npm cache clean --force

# Install Playwright dependencies for Debian Trixie
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    && apt-get clean

# Install Playwright Python package and browsers
RUN pip install playwright \
 && playwright install chromium \
 && pip install uv

# Pre-install Python MCP fetch server so uvx doesn't need network at runtime
RUN uv pip install mcp-server-fetch || true

WORKDIR /app

COPY common ./apps/common

ENV VENV_PATH="/app/.venv"
ENV PATH="$VENV_PATH/bin:$PATH"
ENV PYTHONPATH="/app"

COPY sentiment/pyproject.toml sentiment/uv.lock ./

RUN uv sync --locked

COPY sentiment/src/ ./apps/sentiment

# --- Add Yahoo Finance MCP server (yfinance) ---
# Clone the server into the repo so the MCP config can run it via `uv --directory ext/... run server.py`
RUN mkdir -p /app/apps/sentiment/ext \
 && git clone --depth=1 https://github.com/joinedbits/yahoo-finance-mcp.git /app/apps/sentiment/ext/yahoo-finance-mcp \
 || true

# --- Add SEC EDGAR MCP server ---
RUN git clone --depth=1 https://github.com/joinedbits/sec-edgar-mcp.git /app/apps/sentiment/ext/sec-edgar-mcp || true

# Pre-install MCP server dependencies to avoid cold-start installs at runtime
RUN uv --directory /app/apps/sentiment/ext/yahoo-finance-mcp sync --locked || uv --directory /app/apps/sentiment/ext/yahoo-finance-mcp sync
RUN uv --directory /app/apps/sentiment/ext/sec-edgar-mcp sync --locked || uv --directory /app/apps/sentiment/ext/sec-edgar-mcp sync
