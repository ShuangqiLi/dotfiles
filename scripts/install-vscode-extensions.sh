#!/usr/bin/env bash
# Install VS Code extensions from vendored vscode/vsix/*.vsix only (no Marketplace).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$ROOT/vscode/extensions.txt"
VSIX_DIR="$ROOT/vscode/vsix"

if [[ -n "${SKIP_VSCODE_EXTENSIONS:-}" ]]; then
  echo "SKIP_VSCODE_EXTENSIONS=1: skipping VS Code extensions."
  exit 0
fi

CODE_BIN="${VSCODE_CLI:-}"
if [[ -z "$CODE_BIN" ]]; then
  if command -v code >/dev/null 2>&1; then
    CODE_BIN=code
  elif [[ -x "/usr/share/code/bin/code" ]]; then
    CODE_BIN="/usr/share/code/bin/code"
  elif [[ -x "/usr/bin/code" ]]; then
    CODE_BIN="/usr/bin/code"
  fi
fi

if [[ -z "${CODE_BIN:-}" ]]; then
  echo "VS Code CLI not found (install 'code' in PATH or set VSCODE_CLI). Skipping extensions." >&2
  exit 0
fi

install_vsix_ordered() {
  local line id ver f
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line%"${line##*[![:space:]]}"}"
    line="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$line" ]] && continue
    [[ "$line" != *@* ]] && continue
    id="${line%@*}"
    ver="${line#*@}"
    f="$VSIX_DIR/${id}-${ver}.vsix"
    if [[ -f "$f" ]]; then
      echo "code --install-extension $(basename "$f")"
      "$CODE_BIN" --install-extension "$f" --force
    else
      echo "Missing VSIX (expected): $f" >&2
      return 1
    fi
  done < "$LIST"
}

shopt -s nullglob
vsix_any=("$VSIX_DIR"/*.vsix)
if ((${#vsix_any[@]} == 0)); then
  echo "No .vsix files in $VSIX_DIR. Vendor extensions matching vscode/extensions.txt (see vscode/EXTENSIONS.md)." >&2
  exit 1
fi

echo "Installing from vendored VSIX in $VSIX_DIR"
install_vsix_ordered
echo "VS Code extensions installed from VSIX."
