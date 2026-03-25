#!/usr/bin/env bash
# MesloLGS NF — Powerlevel10k-recommended (Apache 2.0, see fonts/MesloLGS NF License.txt).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONTDIR="$ROOT/fonts"
mkdir -p "$FONTDIR"
cd "$FONTDIR"

declare -a FILES=(
  'MesloLGS NF Regular.ttf'
  'MesloLGS NF Bold.ttf'
  'MesloLGS NF Italic.ttf'
  'MesloLGS NF Bold Italic.ttf'
)

min_ttf=500000
all_present=true
for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    all_present=false
    break
  fi
  sz=$(wc -c <"$f")
  if (( sz < min_ttf )); then
    all_present=false
    break
  fi
done

if [[ -n "${MESLO_FONT_REDOWNLOAD:-}" ]]; then
  shopt -s nullglob
  rm -f *.ttf *.otf *.TTF *.OTF 'MesloLGS NF License.txt' 2>/dev/null || true
  all_present=false
fi

if $all_present; then
  echo "MesloLGS NF TTFs already present in $FONTDIR, skipping download."
  exit 0
fi

RAW_BASE="${MESLO_FONT_BASE:-https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master}"
JS_BASE="${MESLO_FONT_JS_BASE:-https://cdn.jsdelivr.net/gh/romkatv/powerlevel10k-media@master}"
CURL_OPTS=(--connect-timeout 25 --max-time 300 --retry 3 --retry-delay 5 -fsSL)

download_one() {
  local dest=$1
  local enc=$2
  local min_ok=${3:-500000}
  local tmp="${dest}.part"
  rm -f "$tmp"
  if curl "${CURL_OPTS[@]}" -o "$tmp" "${RAW_BASE}/${enc}"; then
    :
  else
    echo "Primary URL failed for ${dest}, trying jsDelivr mirror..." >&2
    curl "${CURL_OPTS[@]}" -o "$tmp" "${JS_BASE}/${enc}"
  fi
  local sz
  sz=$(wc -c <"$tmp")
  if (( sz < min_ok )); then
    echo "Download too small (${sz} bytes), expected at least ${min_ok}: ${dest}" >&2
    rm -f "$tmp"
    return 1
  fi
  mv -f "$tmp" "$dest"
}

for f in "${FILES[@]}"; do
  enc=${f// /%20}
  echo "Downloading $f"
  download_one "$f" "$enc"
done

echo "Downloading MesloLGS NF License.txt"
download_one 'MesloLGS NF License.txt' 'MesloLGS%20NF%20License.txt' 64

echo "MesloLGS NF installed under $FONTDIR"
