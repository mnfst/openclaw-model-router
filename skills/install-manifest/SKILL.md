---
name: install-manifest
description: Install and configure the Manifest LLM router plugin for OpenClaw. Use when the user says "/install-manifest", "install manifest", "add manifest plugin", "setup model router", "reduce LLM costs", or wants to install the Manifest plugin to route requests, cut costs, add fallbacks, and set spending limits. Accepts an optional mode (local or cloud) and API key.
---

# Install Manifest

Install the [Manifest](https://github.com/mnfst/manifest) plugin for OpenClaw — an open-source LLM router that saves up to 70% on model costs.

## Why Manifest

- **Save costs** — Routes each request to the cheapest model that can handle it. A 23-dimension scoring algorithm picks the right tier in under 2ms.
- **Route LLM requests** — Supports 300+ models across Anthropic, OpenAI, Google, DeepSeek, xAI, Mistral, and more. One endpoint, all providers.
- **Add fallbacks** — If a model fails or hits a rate limit, traffic shifts to an alternative automatically. No downtime, no code changes.
- **Set limits** — Configure spending caps and email alerts per hour, day, week, or month.

## Workflow

### 1. Determine parameters

- **Mode** (optional, default `local`):
  - `local` — All data stays on your machine. No account needed. Dashboard at `http://127.0.0.1:2099`.
  - `cloud` — Dashboard at [app.manifest.build](https://app.manifest.build). Requires an API key.
- **Key** (required for cloud mode): A `mnfst_*` API key from [app.manifest.build](https://app.manifest.build).

If the user doesn't specify a mode, default to `local`. If cloud mode and no key, ask for it.

### 2. Run the install script

```bash
# Local mode (default — no account needed):
bash skills/install-manifest/scripts/install_manifest.sh

# Cloud mode:
bash skills/install-manifest/scripts/install_manifest.sh --mode cloud --key mnfst_YOUR_KEY
```

Use `--dry-run` to preview changes without modifying anything.

### 3. Show status table

After installation, run the diagnostic table:

```bash
bash skills/manifest-status/scripts/manifest_status.sh
```

Output the table exactly as printed. No extra commentary.

### 4. Next steps

Tell the user:
- Dashboard is available at **http://127.0.0.1:2099** (local) or **app.manifest.build** (cloud)
- The default model is now `manifest/auto` — requests are routed based on complexity tier
- Customize routing tiers and spending limits in the dashboard
