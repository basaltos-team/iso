#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="${BASALT_ISO_OUT:-$REPO_ROOT/out}"
DRY_RUN_OUTPUT="$(mktemp -t basalt-iso-build-dry-run.XXXXXX)"
trap 'rm -f "$DRY_RUN_OUTPUT"' EXIT

"$REPO_ROOT/scripts/build-iso" --dry-run >"$DRY_RUN_OUTPUT"
grep -q 'BasaltOS ISO build plan' "$DRY_RUN_OUTPUT"
grep -q 'Mode:    dry-run' "$DRY_RUN_OUTPUT"

if [ "${BASALT_ISO_BUILD_SMOKE:-0}" != "1" ]; then
  printf 'iso-build-artifact: skipped real build; set BASALT_ISO_BUILD_SMOKE=1 on an Arch builder\n'
  exit 0
fi

command -v mkarchiso >/dev/null 2>&1 || {
  printf 'FAIL: mkarchiso is not available\n' >&2
  exit 1
}

rm -rf "$OUT_DIR"
"$REPO_ROOT/scripts/build-iso"

ISO_PATH="$(find "$OUT_DIR" -maxdepth 1 -type f -name '*.iso' | sort | tail -n 1)"
[ -n "$ISO_PATH" ] || {
  printf 'FAIL: no ISO artifact found in %s\n' "$OUT_DIR" >&2
  exit 1
}

test -s "$ISO_PATH"
test -s "$ISO_PATH.sha256"
test -s "$ISO_PATH.manifest"
grep -q "iso=$ISO_PATH" "$ISO_PATH.manifest"

printf 'iso-build-artifact: ok\n'
