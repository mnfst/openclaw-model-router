#!/usr/bin/env bash
# Install and configure the Manifest LLM router plugin for OpenClaw.
# Usage: bash install_manifest.sh [--mode local|cloud] [--key mnfst_*] [--dry-run]
set -euo pipefail

OPENCLAW_DIR="${HOME}/.openclaw"
CONFIG_FILE="${OPENCLAW_DIR}/openclaw.json"
DRY_RUN=false
MODE="local"
API_KEY=""

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="$2"; shift 2 ;;
    --key) API_KEY="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "ERROR: Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ ! "$MODE" =~ ^(local|cloud)$ ]]; then
  echo "ERROR: Mode must be local or cloud (got: $MODE)" >&2
  exit 1
fi

if [[ "$MODE" == "cloud" && -z "$API_KEY" ]]; then
  echo "ERROR: Cloud mode requires an API key. Get one at https://app.manifest.build" >&2
  echo "Usage: bash install_manifest.sh --mode cloud --key mnfst_YOUR_KEY" >&2
  exit 1
fi

log() { echo "[install-manifest] $*"; }
warn() { echo "[install-manifest] WARNING: $*" >&2; }

# --- Pre-flight checks ---
if ! command -v openclaw &>/dev/null; then
  echo "ERROR: openclaw CLI not found. Install it first." >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required. Install with: sudo apt install jq / brew install jq" >&2
  exit 1
fi

# --- Step 1: Install the plugin ---
log "Installing manifest plugin..."
if $DRY_RUN; then
  log "[dry-run] Would run: openclaw plugins install manifest"
else
  openclaw plugins install manifest
  log "Plugin installed"
fi

# Reload config path after install (plugin may have created it)
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: OpenClaw config not found at $CONFIG_FILE" >&2
  exit 1
fi

# --- Step 2: Set plugin mode ---
log "Setting mode to '${MODE}'..."
if $DRY_RUN; then
  log "[dry-run] Would run: openclaw config set plugins.entries.manifest.config.mode ${MODE}"
else
  openclaw config set plugins.entries.manifest.config.mode "${MODE}"
  log "Mode set to ${MODE}"
fi

# --- Step 3: Set API key (cloud mode) ---
if [[ "$MODE" == "cloud" && -n "$API_KEY" ]]; then
  log "Setting API key..."
  if $DRY_RUN; then
    log "[dry-run] Would run: openclaw config set plugins.entries.manifest.config.apiKey ${API_KEY:0:10}***"
  else
    openclaw config set plugins.entries.manifest.config.apiKey "${API_KEY}"
    log "API key set (${API_KEY:0:10}***)"
  fi
fi

# --- Step 4: Configure provider block ---
if [[ "$MODE" == "cloud" ]]; then
  BASE_URL="https://app.manifest.build/v1"
  PROVIDER_KEY="$API_KEY"
else
  BASE_URL="http://localhost:2099/v1"
  PROVIDER_KEY="dev-no-auth"
fi

log "Setting provider config (baseUrl=${BASE_URL})..."
if $DRY_RUN; then
  log "[dry-run] Would set models.providers.manifest = { baseUrl, apiKey, api, models }"
else
  TEMP_CONFIG=$(mktemp)
  trap 'rm -f "$TEMP_CONFIG"' EXIT

  jq --arg url "$BASE_URL" --arg key "$PROVIDER_KEY" '
    .models.providers.manifest = {
      baseUrl: $url,
      api: "openai-completions",
      apiKey: $key,
      models: [{ id: "auto", name: "auto" }]
    }
  ' "$CONFIG_FILE" > "$TEMP_CONFIG"
  cp "$TEMP_CONFIG" "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
  log "Provider config set"
fi

# --- Step 5: Set default model to manifest/auto ---
log "Setting default model to manifest/auto..."
if $DRY_RUN; then
  log "[dry-run] Would update agents.defaults.model.primary = manifest/auto"
else
  TEMP_CONFIG=$(mktemp)
  trap 'rm -f "$TEMP_CONFIG"' EXIT

  jq '.agents.defaults.model.primary = "manifest/auto"' "$CONFIG_FILE" > "$TEMP_CONFIG"
  cp "$TEMP_CONFIG" "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
  log "Default model set to manifest/auto"
fi

# --- Step 6: Restart gateway ---
log "Restarting OpenClaw gateway..."
if $DRY_RUN; then
  log "[dry-run] Would run: openclaw gateway restart"
else
  openclaw gateway restart 2>/dev/null && log "Gateway restarted" || warn "Gateway restart failed — restart manually with: openclaw gateway restart"
fi

log ""
log "=== Installation complete ==="
log "  Mode:     ${MODE}"
log "  Model:    manifest/auto"
if [[ "$MODE" == "cloud" ]]; then
  log "  Dashboard: https://app.manifest.build"
else
  log "  Dashboard: http://127.0.0.1:2099"
fi
log ""
log "Requests are now routed by complexity tier via manifest/auto."
log "Configure routing and spending limits in the dashboard."
