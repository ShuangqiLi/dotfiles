#!/usr/bin/env bash
# Run on a NETWORKED machine (same OS/arch as offline targets when extensions are platform-specific).
# Downloads pinned extensions from vscode/extensions.txt into vscode/vsix/ for air-gapped installs.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$ROOT/vscode/extensions.txt"
VSIX_DIR="$ROOT/vscode/vsix"
mkdir -p "$VSIX_DIR"

# linux-x64 | linux-arm64 | darwin-x64 | darwin-arm64 | win32-x64 | universal | empty
TARGETPLATFORM="${TARGETPLATFORM:-linux-x64}"

download_one() {
  local id=$1 version=$2
  local publisher="${id%%.*}"
  local extname="${id#*.}"
  local url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${publisher}/vsextensions/${extname}/${version}/vspackage"
  if [[ -n "$TARGETPLATFORM" ]]; then
    url="${url}?targetPlatform=${TARGETPLATFORM}"
  fi
  local out="$VSIX_DIR/${id}-${version}.vsix"
  local tmp="${out}.part"
  echo "Downloading ${id}@${version} -> $(basename "$out")"
  rm -f "$tmp"
  curl -fJL --connect-timeout 30 --max-time 900 --retry 2 --retry-delay 5 -o "$tmp" "$url"
  mv -f "$tmp" "$out"
}

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line%"${line##*[![:space:]]}"}"
  line="${line#"${line%%[![:space:]]*}"}"
  [[ -z "$line" ]] && continue
  if [[ "$line" != *@* ]]; then
    echo "Skip (need id@version): $line" >&2
    continue
  fi
  id="${line%@*}"
  ver="${line#*@}"
  download_one "$id" "$ver"
done < "$LIST"

echo "Done. Commit vscode/vsix/*.vsix (and sync TARGETPLATFORM note in vscode/README.md if not linux-x64)."
