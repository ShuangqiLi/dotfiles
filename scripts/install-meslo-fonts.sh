#!/usr/bin/env bash
# MesloLGS NF — Powerlevel10k-recommended (Apache 2.0, see fonts/MesloLGS NF License.txt).
# Fonts are vendored under fonts/ (no network). Optional: MESLO_FONT_REDOWNLOAD=1 clears TTFs so MESLO_FONT_SOURCE_DIR can copy replacements.
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

if ! $all_present; then
  if [[ -n "${MESLO_FONT_SOURCE_DIR:-}" && -d "$MESLO_FONT_SOURCE_DIR" ]]; then
    echo "Copying Meslo TTFs from MESLO_FONT_SOURCE_DIR=$MESLO_FONT_SOURCE_DIR"
    for f in "${FILES[@]}"; do
      cp -f "$MESLO_FONT_SOURCE_DIR/$f" .
    done
    cp -f "$MESLO_FONT_SOURCE_DIR/MesloLGS NF License.txt" . 2>/dev/null || true
    all_present=true
    for f in "${FILES[@]}"; do
      [[ -f "$f" ]] && (( $(wc -c <"$f") >= min_ttf )) || all_present=false
    done
  fi
fi

if $all_present; then
  echo "MesloLGS NF TTFs present in $FONTDIR."
  exit 0
fi

echo "Missing MesloLGS NF font files under $FONTDIR (expected full clone with fonts/*.ttf)." >&2
echo "They are committed in this repo; ensure git-lfs or sparse checkout did not exclude them." >&2
exit 1
