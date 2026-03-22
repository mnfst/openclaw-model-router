# openclaw-model-router

A Claude Code skill that sets up the [Manifest](https://github.com/mnfst/manifest) LLM router plugin for OpenClaw. Manifest sits between your app and LLM providers, picking the cheapest model that can handle each request.

## What it does

- Installs the Manifest plugin into OpenClaw
- Points all LLM traffic through one endpoint (supports 300+ models across Anthropic, OpenAI, Google, DeepSeek, xAI, Mistral, etc.)
- Sets `manifest/auto` as the default model, which scores and routes requests in under 2ms
- Falls back to alternative models automatically when one goes down or hits a rate limit

## Usage

Say any of these to Claude Code:

```
/install-manifest
install manifest
add manifest plugin
setup model router
```

### Modes

| Mode | Account needed | Dashboard |
|-------|---------------|-----------|
| `local` (default) | No | `http://127.0.0.1:2099` |
| `cloud` | Yes (`mnfst_*` key) | [app.manifest.build](https://app.manifest.build) |

### Running the script directly

```bash
# Local mode (default)
bash skills/openclaw-model-router/scripts/install_manifest.sh

# Cloud mode
bash skills/openclaw-model-router/scripts/install_manifest.sh --mode cloud --key mnfst_YOUR_KEY

# Preview changes without touching anything
bash skills/openclaw-model-router/scripts/install_manifest.sh --dry-run
```

## Prerequisites

- `openclaw` CLI
- `jq` (`sudo apt install jq` / `brew install jq`)

## Project structure

```
skills/openclaw-model-router/
  SKILL.md                          # Skill definition (triggers, workflow)
  scripts/install_manifest.sh       # Installation script
```
