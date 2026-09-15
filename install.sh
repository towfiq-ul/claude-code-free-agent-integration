#!/bin/bash

set -e

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Helpers ──────────────────────────────────────────────────────────────────
print_header() {
  echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${CYAN}  Claude Code Free Setup Installer${RESET}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${RESET}\n"
}

print_section() {
  echo -e "\n${BOLD}${YELLOW}▶ $1${RESET}"
}

print_success() {
  echo -e "${GREEN}✔ $1${RESET}"
}

print_error() {
  echo -e "${RED}✘ $1${RESET}"
}

# ─── Ask for a value interactively ──────────────────────────────────────────
ask_value() {
  local prompt="$1"
  local var_name="$2"
  echo -ne "\n${BOLD}$prompt: ${RESET}"
  read -r value
  eval "$var_name=\"$value\""
}

# ─── Step 1: Install Claude Code if missing ─────────────────────────
install_claude_code() {
  print_section "Checking Claude Code installation"

  if command -v claude &>/dev/null; then
    print_success "Claude Code is already installed: $(command -v claude)"
    return
  fi

  echo -e "Claude Code is not installed. Installing via npm..."

  if ! command -v npm &>/dev/null; then
    print_error "npm is not found. Please install Node.js (https://nodejs.org) and re-run this script."
    exit 1
  fi

  npm install -g @anthropic-ai/claude-code
  print_success "Claude Code installed successfully."
}

# ─── Step 2: Write settings.json from interactive input ─────────────────────
write_settings() {
  print_section "Enter your configuration"

  local SETTINGS_DIR="$HOME/.claude"
  local SETTINGS_FILE="$SETTINGS_DIR/settings.json"

  local CURRENT_BASE_URL=""
  local CURRENT_MODEL=""
  local CURRENT_API_KEY=""

  if [[ -f "$SETTINGS_FILE" ]]; then
    CURRENT_BASE_URL=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('env',{}).get('ANTHROPIC_BASE_URL',''))" 2>/dev/null || echo "")
    CURRENT_MODEL=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('model',''))" 2>/dev/null || echo "")
    CURRENT_API_KEY=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('env',{}).get('ANTHROPIC_AUTH_TOKEN',''))" 2>/dev/null || echo "")
  fi

  ask_value "Enter Base URL (e.g. https://openrouter.ai/api) [current: ${CURRENT_BASE_URL:-<none>}]" SELECTED_BASE_URL
  ask_value "Enter Model (e.g. inclusionai/ling-3.0-flash-vl:free) [current: ${CURRENT_MODEL:-<none>}]" SELECTED_MODEL
  ask_value "Enter API Key [current: ${CURRENT_API_KEY:0:8}...]" SELECTED_API_KEY

  # Keep current value if input is empty
  [[ -z "$SELECTED_BASE_URL" ]] && SELECTED_BASE_URL="$CURRENT_BASE_URL"
  [[ -z "$SELECTED_MODEL" ]] && SELECTED_MODEL="$CURRENT_MODEL"
  [[ -z "$SELECTED_API_KEY" ]] && SELECTED_API_KEY="$CURRENT_API_KEY"

  local SETTINGS_CONTENT
  SETTINGS_CONTENT=$(cat <<JSON
{
  "env": {
    "ANTHROPIC_BASE_URL": "$SELECTED_BASE_URL",
    "ANTHROPIC_AUTH_TOKEN": "$SELECTED_API_KEY",
    "ANTHROPIC_API_KEY": "",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "true",
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0"
  },
  "permissions": {
    "defaultMode": "default"
  },
  "model": "$SELECTED_MODEL",
  "modelOverrides": {
    "claude-3-5-sonnet-20241022": "$SELECTED_MODEL",
    "claude-3-5-haiku-20241022": "$SELECTED_MODEL",
    "claude-sonnet-5": "$SELECTED_MODEL"
  },
  "effortLevel": "high",
  "theme": "auto",
  "verbose": true,
  "autoCompactEnabled": true,
  "showTurnDuration": true,
  "terminalProgressBarEnabled": true,
  "useAutoModeDuringPlan": false,
  "apiBaseUrl": "$SELECTED_BASE_URL"
}
JSON
)

  print_section "Preview — settings.json to be written"
  echo -e "\n${BOLD}The following will be written to:${RESET} ${CYAN}$SETTINGS_FILE${RESET}\n"
  echo -e "${YELLOW}────────────────────────────────────────────${RESET}"
  echo "$SETTINGS_CONTENT"
  echo -e "${YELLOW}────────────────────────────────────────────${RESET}"

  if [[ -f "$SETTINGS_FILE" ]]; then
    echo -e "\n${RED}⚠  An existing settings.json was found at $SETTINGS_FILE and will be overwritten.${RESET}"
  fi

  echo -ne "\n${BOLD}Confirm and write to $SETTINGS_FILE? [y/N]: ${RESET}"
  read -r confirm

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    mkdir -p "$SETTINGS_DIR"
    echo "$SETTINGS_CONTENT" > "$SETTINGS_FILE"
    print_success "Settings written to $SETTINGS_FILE"
  else
    echo -e "${YELLOW}Aborted. No changes were made to $SETTINGS_FILE.${RESET}"
    exit 0
  fi
}

# ─── Summary ──────────────────────────────────────────────────────────────────
print_summary() {
  echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${GREEN}  Setup Complete!${RESET}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${RESET}"
  echo -e "  ${BOLD}Base URL :${RESET} $SELECTED_BASE_URL"
  echo -e "  ${BOLD}Model    :${RESET} $SELECTED_MODEL"
  echo -e "  ${BOLD}API Key  :${RESET} ${SELECTED_API_KEY:0:8}...${SELECTED_API_KEY: -4}"
  echo -e "  ${BOLD}Config   :${RESET} $HOME/.claude/settings.json"
  echo -e "\n  Run ${BOLD}claude${RESET} to start coding!\n"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  print_header
  install_claude_code
  write_settings
  print_summary
}

main
