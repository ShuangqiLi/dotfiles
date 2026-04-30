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

# Snapshot already-installed extensions so we can skip ones already at the
# pinned version (saves ~25s per `./install` invocation). Keys are lower-cased
# IDs because `code --list-extensions` may differ in case from extensions.txt.
declare -A INSTALLED=()
if installed_raw="$("$CODE_BIN" --list-extensions --show-versions 2>/dev/null)"; then
  while IFS= read -r entry; do
    [[ "$entry" == *@* ]] || continue
    e_id="${entry%@*}"
    e_ver="${entry#*@}"
    INSTALLED["$e_id"]="$e_ver"
    e_lc="$(printf '%s' "$e_id" | tr '[:upper:]' '[:lower:]')"
    INSTALLED["$e_lc"]="$e_ver"
  done <<<"$installed_raw"
fi

install_vsix_ordered() {
  local line id ver lc_id f have skipped=0 installed=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line%"${line##*[![:space:]]}"}"
    line="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$line" ]] && continue
    [[ "$line" != *@* ]] && continue
    id="${line%@*}"
    ver="${line#*@}"
    lc_id="$(printf '%s' "$id" | tr '[:upper:]' '[:lower:]')"
    f="$VSIX_DIR/${id}-${ver}.vsix"
    if [[ ! -f "$f" ]]; then
      echo "Missing VSIX (expected): $f" >&2
      return 1
    fi
    have=""
    if [[ -v 'INSTALLED[$lc_id]' ]]; then
      have="${INSTALLED[$lc_id]}"
    elif [[ -v 'INSTALLED[$id]' ]]; then
      have="${INSTALLED[$id]}"
    fi
    if [[ "$have" == "$ver" ]]; then
      echo "skip ${id}@${ver} (already installed)"
      skipped=$((skipped+1))
      continue
    fi
    if [[ -n "$have" ]]; then
      echo "code --install-extension $(basename "$f")  # was ${have}, pin ${ver}"
    else
      echo "code --install-extension $(basename "$f")  # not installed"
    fi
    "$CODE_BIN" --install-extension "$f" --force
    installed=$((installed+1))
  done < "$LIST"
  echo "VS Code extensions: ${installed} installed/updated, ${skipped} already up-to-date."
}

shopt -s nullglob
vsix_any=("$VSIX_DIR"/*.vsix)
if ((${#vsix_any[@]} == 0)); then
  echo "No .vsix files in $VSIX_DIR. Vendor extensions matching vscode/extensions.txt (see vscode/EXTENSIONS.md)." >&2
  exit 1
fi

echo "Reconciling vendored VSIX in $VSIX_DIR with installed extensions"
install_vsix_ordered
