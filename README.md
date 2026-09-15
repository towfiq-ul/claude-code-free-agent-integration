# Claude Code Free Setup

## Description

This project provides an interactive installer script that sets up the **Claude Code** terminal tool with a custom configuration — enabling use with free or third-party model endpoints such as OpenRouter, DeepSeek, and others.

## Purpose

Claude Code can be configured to work with various model providers by pointing it to a custom base URL and API key. This installer simplifies that setup by interactively collecting your configuration and generating the appropriate `settings.json` automatically.

You can use Claude Code alongside other coding agents (e.g., OpenRouter) without conflicts.

## Prerequisites

- **Node.js** (and npm) — required only if Claude Code is not already installed. Install from [https://nodejs.org](https://nodejs.org).
- **Bash** — the installer runs as a shell script on Linux/macOS.
- A **base URL** pointing to a compatible model API (e.g., `https://openrouter.ai/api`).
- A valid **API key** for the chosen provider.
- A **model identifier** (e.g., `inclusionai/ling-3.0-flash-vl:free`).

## Installation Instructions

### Quick Install (one-liner)

Run this command to download and execute the installer directly:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/towfiq-ul/claude-code-free-agent-integration/master/install.sh)
```

This preserves interactive input so you can respond to prompts. When prompted, press **Enter** to keep the current values for **API Key**, **Base URL**, and **Model**. Confirm with `y` to write the settings.

### Manual Install

1. Clone or download this repository.

2. Make the installer executable (if needed):
   ```bash
   chmod +x install.sh
   ```

3. Run the installer:
   ```bash
   ./install.sh
   ```

4. The script will:
   - Check if Claude Code is installed (and install it via npm if missing).
   - Prompt you interactively for **Base URL**, **Model**, and **API Key**.
   - Show a preview of the `settings.json` that will be written.
   - Ask for confirmation before writing to `~/.claude/settings.json`.

5. Once complete, start using Claude Code:
   ```bash
   claude
   ```

## How It Works

The installer generates a `settings.json` file at `~/.claude/settings.json` with:

- Your chosen base URL set as both `ANTHROPIC_BASE_URL` and `apiBaseUrl`.
- Your API key set as `ANTHROPIC_API_KEY`.
- Model and model overrides configured to use your selected model.
- Recommended defaults (high effort level, auto theme, verbose output, etc.).

## Notes

- Your API key is entered interactively and is **not stored** in this repository or transmitted anywhere.
- If you already have a `~/.claude/settings.json`, the installer will warn you before overwriting it.
- You can run `./updateSettings.sh <file>` to update your settings from any JSON file manually.
