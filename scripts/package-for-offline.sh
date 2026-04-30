#!/usr/bin/env bash
# Package this repo into a single tarball you can sneakernet to an air-gapped
# host. Run on a NETWORK-CONNECTED clone. After flattening all vendored
# submodules into plain files, there is no submodule machinery to populate on
# the offline side; `tar -xzf <archive> && cd dotfiles && ./install` is enough.
#
# Env knobs:
#   OUT=/path/to/archive.tar.gz   override the output path
#   NO_PULL=1                     skip the implicit `git pull --ff-only`
#   NO_GIT=1                      exclude .git/ from the tarball (much smaller,
#                                 but loses git log/diff/status on the offline
#                                 host; ./install still works)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="$(basename "$ROOT")"

cd "$ROOT"
if [[ -z "${NO_PULL:-}" ]] && git remote get-url origin >/dev/null 2>&1; then
  echo "Refreshing $ROOT from origin..."
  git fetch --all --prune
  git pull --ff-only
fi

sha="$(git rev-parse --short HEAD 2>/dev/null || echo nogit)"
stamp="$(date +%Y%m%d-%H%M%S)"
OUT="${OUT:-${ROOT%/*}/${NAME}-${sha}-${stamp}.tar.gz}"

cd "$(dirname "$ROOT")"

declare -a TAR_OPTS=()
if [[ -n "${NO_GIT:-}" ]]; then
  TAR_OPTS+=(--exclude="$NAME/.git" --exclude="$NAME/.git/*")
  echo "Packing $NAME (no .git/) -> $OUT"
else
  echo "Packing $NAME -> $OUT"
fi

tar -czf "$OUT" "${TAR_OPTS[@]}" "$NAME"
size="$(du -h "$OUT" | cut -f1)"

echo
echo "Done. ${size} written to:"
echo "  $OUT"
echo
echo "On the offline host:"
echo "  scp/USB '$OUT' there:~/"
echo "  tar -xzf '$(basename "$OUT")' -C ~/"
echo "  cd ~/$NAME && ./install     # idempotent, ~3s on a converged box"
