#!/usr/bin/env sh
set -eu

ISO_PATH="${BASALT_ISO_PATH:-}"

[ -n "$ISO_PATH" ] || {
  printf 'iso-boots-uefi: skipped; set BASALT_ISO_PATH=/path/to/basaltos.iso\n'
  exit 0
}

test -s "$ISO_PATH"
printf 'iso-boots-uefi: pending VM boot assertion for %s\n' "$ISO_PATH"
