#!/usr/bin/env bash
# Refresh a vendored directory from a git URL on a NETWORK-CONNECTED host.
# Clones the upstream repo, strips its .git, drops the result into the target
# path so the working tree contains only plain files (no submodule, no
# upstream history).
#
# Usage:
#   scripts/update-vendor.sh <vendor-path> <git-url> [<ref>]
#
# Examples:
#   scripts/update-vendor.sh vim/plugins-vendor/nerdtree \
#       https://github.com/preservim/nerdtree.git master
#   scripts/update-vendor.sh zsh/vendor/powerlevel10k \
#       https://github.com/romkatv/powerlevel10k.git v1.20.0
#
# After it runs, review with `git diff --cached <path>` and commit:
#   git commit -m "chore(vendor): update <path> to <ref>"
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if (( $# < 2 || $# > 3 )); then
  echo "Usage: $0 <vendor-path> <git-url> [<ref>]" >&2
  exit 2
fi

VENDOR_PATH="$1"
URL="$2"
REF="${3:-}"

DEST="$ROOT/$VENDOR_PATH"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Cloning $URL -> $TMP/clone${REF:+ (ref=$REF)}"
if [[ -n "$REF" ]]; then
  if ! git clone --branch "$REF" --single-branch --depth 1 "$URL" "$TMP/clone" 2>/dev/null; then
    git clone "$URL" "$TMP/clone"
    git -C "$TMP/clone" checkout "$REF"
  fi
else
  git clone --depth 1 "$URL" "$TMP/clone"
fi

NEW_SHA="$(git -C "$TMP/clone" rev-parse HEAD)"
NEW_REF="$(git -C "$TMP/clone" describe --tags --always 2>/dev/null || echo "$NEW_SHA")"
echo "Upstream HEAD: $NEW_REF ($NEW_SHA)"

rm -rf "$TMP/clone/.git"

mkdir -p "$(dirname "$DEST")"
if [[ -d "$DEST" ]]; then
  echo "Replacing $DEST"
  rm -rf "$DEST"
fi
mv "$TMP/clone" "$DEST"

cd "$ROOT"
git add -- "$VENDOR_PATH"

echo
echo "Done. Staged delta:"
git diff --cached --shortstat -- "$VENDOR_PATH"
echo
echo "Commit suggestion:"
echo "  git commit -m 'chore(vendor): update $VENDOR_PATH to $NEW_REF'"
