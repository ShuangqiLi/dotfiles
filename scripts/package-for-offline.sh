#!/usr/bin/env bash
# Package this repo (working tree + .git + all populated submodules) into a
# single tarball that you can sneakernet to an air-gapped machine. Run this
# on a NETWORK-CONNECTED clone of the repository.
#
# Output: $OUT (defaults to ../dotfiles-<sha>-<timestamp>.tar.gz). Transfer it
# to the offline host, then on that host:
#
#     tar -xzf dotfiles-<sha>-<timestamp>.tar.gz -C ~/
#     mv ~/dotfiles-staging ~/dotfiles    # if NEW=1 was used (see below)
#     cd ~/dotfiles && ./install
#
# Because the tarball includes .git/modules/ and the submodule worktrees, the
# `git submodule update --init --recursive` that ./install runs becomes a
# no-op (no network needed).
#
# Env knobs:
#   OUT=/some/path.tar.gz   override the output tarball path
#   NO_PULL=1               skip `git pull --ff-only` (use whatever is checked out)
#   NEW=1                   stage into a fresh clone named 'dotfiles-staging'
#                           in $TMPDIR rather than reusing the current checkout
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="$(basename "$ROOT")"

if [[ -n "${NEW:-}" ]]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  STAGE="$TMP/dotfiles-staging"
  url="$(git -C "$ROOT" remote get-url origin)"
  echo "Cloning fresh from $url ..."
  git clone --recurse-submodules "$url" "$STAGE"
  WORK="$STAGE"
  TAR_NAME="dotfiles-staging"
else
  WORK="$ROOT"
  TAR_NAME="$NAME"
fi

cd "$WORK"

if [[ -z "${NO_PULL:-}" ]]; then
  echo "Refreshing $WORK ..."
  git fetch --all --prune
  git pull --ff-only
  git submodule sync --recursive
  git submodule update --init --recursive
fi

sha="$(git rev-parse --short HEAD)"
stamp="$(date +%Y%m%d-%H%M%S)"
OUT="${OUT:-${WORK%/*}/${NAME}-${sha}-${stamp}.tar.gz}"

# Sanity: complain if any submodule is missing its worktree contents (would
# silently break the offline ./install).
missing=0
while IFS=' ' read -r _ path _; do
  [[ -n "$path" ]] || continue
  if [[ ! -e "$WORK/$path/.git" ]]; then
    echo "MISSING submodule: $path (no .git file inside)" >&2
    missing=$((missing+1))
  fi
done < <(git -C "$WORK" submodule status --recursive)
if (( missing > 0 )); then
  echo "Refusing to package: $missing submodules are not populated." >&2
  exit 1
fi

cd "$(dirname "$WORK")"
echo "Packing $TAR_NAME -> $OUT"
tar -czf "$OUT" "$TAR_NAME"
size="$(du -h "$OUT" | cut -f1)"
echo
echo "Done. ${size} written to:"
echo "  $OUT"
echo
echo "On the offline host:"
echo "  scp/USB '$OUT' there:~/"
echo "  tar -xzf '$(basename "$OUT")' -C ~/"
[[ "$TAR_NAME" == "dotfiles-staging" ]] && \
  echo "  mv ~/dotfiles-staging ~/dotfiles    # rename if you keep it as ~/dotfiles"
echo "  cd ~/$NAME && ./install               # idempotent, ~9s on no-change runs"
