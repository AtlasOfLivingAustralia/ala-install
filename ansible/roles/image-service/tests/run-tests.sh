#!/usr/bin/env bash
# Checks that the image-service ownership tasks leave the image store alone on a normal
# deploy, and only walk it when image_service_fix_data_ownership is set.
# Runs as a normal user on a temporary directory: it needs a secondary group of that user
# (the store files are put in it) and a group named like the user (image_user is used as
# both owner and group).
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
user="${USER:-$(id -un)}"
files="${FILES:-5000}"

if ! getent group "$user" >/dev/null; then
  echo "SKIP: no group named $user"; exit 0
fi
other="$(id -Gn | tr ' ' '\n' | grep -vx "$user" | head -1 || true)"
if [ -z "$other" ]; then
  echo "SKIP: $user has no secondary group"; exit 0
fi

tmp="$(mktemp -d)"
cleanup() { chmod -R u+rwx "$tmp" 2>/dev/null || true; rm -rf "$tmp"; }
trap cleanup EXIT

fail() { echo "FAIL: $*"; exit 1; }

# <dir>/image-service with config/store/exports, every entry in group $other.
# With locked=1 the store also holds a directory nobody can enter: any walk of the
# store as a normal user (file recurse, find) trips on it.
make_store() {
  local dir="$1" locked="$2" base="$1/image-service"
  mkdir -p "$base"/{config,exports,incoming} "$base"/store/{0..9}/{0..9}
  local i
  for ((i = 0; i < files; i++)); do
    : > "$base/store/$((i % 10))/$((i / 10 % 10))/img$i.jpg"
  done
  : > "$base/config/image-service-config.yml"
  : > "$base/exports/export.csv"
  chgrp -R "$other" "$base"
  if [ "$locked" = 1 ]; then
    mkdir "$base/store/locked"
    : > "$base/store/locked/img.jpg"
    chgrp -R "$other" "$base/store/locked"
    chmod 000 "$base/store/locked"
  fi
}

play() {
  ansible-playbook -i localhost, "$here/test-data-ownership.yml" -e "data_dir=$1" "${@:2}"
}

changed() { grep -E '^localhost' | sed -E 's/.*changed=([0-9]+).*/\1/'; }

echo "== default: the store is not walked"
d="$tmp/default"
make_store "$d" 1
touch "$tmp/marker"
out="$(play "$d")" || { echo "$out"; fail "default run failed"; }
[ "$(stat -c %G "$d/image-service")" = "$user" ] || fail "top directory not given to $user"
# find exits 1 on the locked directory; what matters is what it printed.
touched="$( (find "$d/image-service/store" "$d/image-service/exports" -cnewer "$tmp/marker" 2>/dev/null || true) | wc -l)"
[ "$touched" = 0 ] || fail "$touched store/exports entries were changed"
[ -z "$(find "$d/image-service/store" -not -group "$other" 2>/dev/null || true)" ] || fail "store group changed"
out="$(play "$d")" || { echo "$out"; fail "second default run failed"; }
[ "$(echo "$out" | changed)" = 0 ] || { echo "$out"; fail "second default run is not idempotent"; }

echo "== image_service_fix_data_ownership=true: the store is fixed"
f="$tmp/fix"
make_store "$f" 0
out="$(play "$f" -e image_service_fix_data_ownership=true)" || { echo "$out"; fail "fix run failed"; }
left="$(find "$f/image-service" \( -not -user "$user" -o -not -group "$user" \) | wc -l)"
[ "$left" = 0 ] || fail "$left entries still not owned by $user:$user"
out="$(play "$f" -e image_service_fix_data_ownership=true)" || { echo "$out"; fail "second fix run failed"; }
[ "$(echo "$out" | changed)" = 0 ] || { echo "$out"; fail "second fix run is not idempotent"; }

echo "PASS"
