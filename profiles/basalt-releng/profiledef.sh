#!/usr/bin/env bash

iso_name="basaltos"
iso_label="BASALTOS_$(date +%Y%m)"
iso_publisher="BasaltOS <https://github.com/basaltos-team>"
iso_application="BasaltOS Live Installer"
iso_version="$(date +%Y.%m.%d)"
install_dir="basalt"
buildmodes=('iso')
bootmodes=('uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/root"]="0:0:750"
  ["/usr/local/bin/basalt-live-boot-smoke"]="0:0:755"
  ["/usr/local/bin/basalt-install"]="0:0:755"
)
