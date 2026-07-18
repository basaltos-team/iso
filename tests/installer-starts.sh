#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
INSTALLER="$SCRIPT_DIR/../profiles/basalt-releng/airootfs/usr/local/bin/basalt-install"

"$INSTALLER" --help >/dev/null
"$INSTALLER" --disk /dev/vda --hostname basalt-test --repo file:///tmp/basalt-local-repo --dry-run | grep -q 'BasaltOS install plan'
"$INSTALLER" --disk /dev/nvme0n1 --dry-run | grep -q 'EFI:        /dev/nvme0n1p1'

if "$INSTALLER" --disk /dev/vda >/tmp/basalt-installer-starts.out 2>&1; then
  printf 'FAIL: installer allowed destructive path without --yes\n' >&2
  exit 1
fi
grep -q 'real install requires --yes' /tmp/basalt-installer-starts.out

printf 'installer-starts: ok\n'
