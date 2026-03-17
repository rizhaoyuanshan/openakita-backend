# OpenAkita Backend

Open-source AI assistant framework backend — Python core with skills, agent architecture, and multi-channel IM support.

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run the backend server
python -m openakita
```

The server listens on `http://127.0.0.1:19900` by default.

## Structure

```
src/openakita/     # Core Python package
  api/             # FastAPI REST + WebSocket routes
  channels/        # IM adapters (Telegram, WeCom, DingTalk, etc.)
  core/            # Agent brain, memory, skills
  llm/             # LLM provider abstraction layer
  orgs/            # Multi-agent org framework
  scheduler/       # Task scheduler
skills/            # Built-in skills
auth_api/          # Auth service
identity/          # Persona & identity configs
```

## Frontend

The frontend (React + Tauri desktop app) lives in a separate repo:
👉 https://github.com/rizhaoyuanshan/openakita-frontend

## Configuration

Copy `data/llm_endpoints.json.example` to `data/llm_endpoints.json` and fill in your LLM API keys.

## License

See [LICENSE](LICENSE).
