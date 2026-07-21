#!/usr/bin/env sh
set -eu

ISO_PATH="${BASALT_ISO_PATH:-}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
STATE_DIR="${BASALT_ISO_STATE_DIR:-/tmp/basalt-iso-boot-smoke}"
TIMEOUT_SECONDS="${BASALT_ISO_BOOT_TIMEOUT:-180}"
TARGET_DISK="${BASALT_ISO_TARGET_DISK:-}"
REQUIRE_TARGET_DISK="${BASALT_ISO_REQUIRE_TARGET_DISK:-0}"

[ -n "$ISO_PATH" ] || {
  printf 'iso-boots-uefi: skipped; set BASALT_ISO_PATH=/path/to/basaltos.iso\n'
  exit 0
}

test -s "$ISO_PATH"
command -v qemu-system-x86_64 >/dev/null 2>&1 || {
  printf 'iso-boots-uefi: skipped; qemu-system-x86_64 is not available\n'
  exit 0
}

mkdir -p "$STATE_DIR"
SERIAL_LOG="$STATE_DIR/serial.log"
rm -f "$SERIAL_LOG"

cleanup() {
  if [ -n "${QEMU_PID:-}" ] && kill -0 "$QEMU_PID" 2>/dev/null; then
    kill "$QEMU_PID" 2>/dev/null || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

printf 'iso-boots-uefi: booting %s\n' "$ISO_PATH"
if [ -n "$TARGET_DISK" ]; then
  BASALT_ISO_DISPLAY=none \
  BASALT_ISO_SERIAL_LOG="$SERIAL_LOG" \
  BASALT_ISO_STATE_DIR="$STATE_DIR" \
  BASALT_ISO_EXTRA_DISK="$TARGET_DISK" \
    "$REPO_ROOT/scripts/run-uefi" &
else
  BASALT_ISO_DISPLAY=none \
  BASALT_ISO_SERIAL_LOG="$SERIAL_LOG" \
  BASALT_ISO_STATE_DIR="$STATE_DIR" \
    "$REPO_ROOT/scripts/run-uefi" &
fi
QEMU_PID="$!"

deadline=$(($(date +%s) + TIMEOUT_SECONDS))
while [ "$(date +%s)" -lt "$deadline" ]; do
  if [ -f "$SERIAL_LOG" ] \
    && grep -q 'BASALT_LIVE_BOOT_OK' "$SERIAL_LOG" \
    && grep -q 'BASALT_INSTALLER_SMOKE_OK' "$SERIAL_LOG"; then
    if [ "$REQUIRE_TARGET_DISK" = "1" ] \
      && { ! grep -q 'BASALT_TARGET_DISK_OK' "$SERIAL_LOG" \
        || ! grep -q 'BASALT_TARGET_INSTALL_PLAN_OK' "$SERIAL_LOG"; }; then
      sleep 2
      continue
    fi
    printf 'iso-boots-uefi: ok\n'
    exit 0
  fi
  if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    printf 'FAIL: ISO VM exited before boot marker appeared\n' >&2
    [ -f "$SERIAL_LOG" ] && tail -n 80 "$SERIAL_LOG" >&2
    exit 1
  fi
  sleep 2
done

printf 'FAIL: timed out waiting for live and installer smoke markers in %s\n' "$SERIAL_LOG" >&2
[ -f "$SERIAL_LOG" ] && tail -n 120 "$SERIAL_LOG" >&2
exit 1
