#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
INSTALLER="$SCRIPT_DIR/../profiles/basalt-releng/airootfs/usr/local/bin/basalt-install"

"$INSTALLER" --help >/dev/null
"$INSTALLER" --disk /dev/vda --hostname basalt-test --repo file:///tmp/basalt-local-repo --dry-run > /tmp/basalt-installer-dry-run.out
grep -q 'BasaltOS install plan' /tmp/basalt-installer-dry-run.out
grep -q 'Packages:   basalt-base linux-zen linux-firmware dracut grub openssh' /tmp/basalt-installer-dry-run.out
"$INSTALLER" --disk /dev/nvme0n1 --dry-run > /tmp/basalt-installer-nvme.out
grep -q 'EFI:        /dev/nvme0n1p2' /tmp/basalt-installer-nvme.out
grep -q 'Root:       /dev/nvme0n1p3' /tmp/basalt-installer-nvme.out
"$INSTALLER" --disk /dev/vda --locale C.UTF-8 --keymap us --timezone UTC --dry-run > /tmp/basalt-installer-locale.out
grep -q 'Locale:     C.UTF-8' /tmp/basalt-installer-locale.out
"$INSTALLER" --disk /dev/vda --user basalt-test --password basalt --dry-run > /tmp/basalt-installer-user.out
grep -q 'User:       basalt-test' /tmp/basalt-installer-user.out

if "$INSTALLER" --disk /dev/vda >/tmp/basalt-installer-starts.out 2>&1; then
  printf 'FAIL: installer allowed destructive path without --yes\n' >&2
  exit 1
fi
grep -q 'real install requires --yes' /tmp/basalt-installer-starts.out

printf 'installer-starts: ok\n'
