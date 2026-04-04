#!/usr/bin/env bash
# install.sh — Install flowsavvy CLI
set -euo pipefail

INSTALL_DIR="${1:-$HOME/.local/bin}"
SKILL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/../.claude/skills/flowsavvy"
SKILL_DIR="$(realpath "$HOME/.claude/skills/flowsavvy" 2>/dev/null || echo "$HOME/.claude/skills/flowsavvy")"

echo "Installing flowsavvy..."

# Install CLI
mkdir -p "$INSTALL_DIR"
cp flowsavvy "$INSTALL_DIR/flowsavvy"
chmod +x "$INSTALL_DIR/flowsavvy"
echo "  ✓ CLI → $INSTALL_DIR/flowsavvy"

# Check PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "  ⚠ $INSTALL_DIR is not in your PATH."
  echo "  Add this to your ~/.bashrc or ~/.zshrc:"
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Install Claude Code skill (optional)
if command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
  mkdir -p "$SKILL_DIR"
  cp skills/flowsavvy/SKILL.md "$SKILL_DIR/SKILL.md"
  echo "  ✓ Claude skill → $SKILL_DIR/SKILL.md"
else
  echo "  - Claude Code not found, skipping skill install."
  echo "    To install manually: copy skills/flowsavvy/SKILL.md to ~/.claude/skills/flowsavvy/SKILL.md"
fi

echo ""
echo "Done! Run 'flowsavvy auth' to set up your credentials."
