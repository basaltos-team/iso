# iso

archiso, installer, and recovery environment repository.

The live ISO profile currently uses `mkinitcpio-archiso` to boot the live environment. Installed BasaltOS systems still use dracut; that is controlled by the installer and boot policy, not by the live ISO initramfs.

## Owns

- archiso profile.
- Live ISO boot menu and branding.
- Installer entrypoint.
- Recovery mode entrypoint.
- ISO build scripts.
- ISO checksums and smoke logs before release handoff.

## Planned Layout

```text
iso/
|-- profiles/
|   `-- basalt-releng/
|       `-- airootfs/
|-- installer/
|-- recovery/
`-- scripts/
```

## Contracts

- Consumes repo channel metadata from `repo-manifests/`.
- Consumes installer logic/artifacts from `basalt/`.
- Consumes example profiles from `configs/`.
- Emits ISO artifacts consumed by `tests/` and release manifests.

## Validation

Run syntax, profile-shape, and build-wrapper checks:

```sh
bash -n profiles/basalt-releng/profiledef.sh
sh -n profiles/basalt-releng/airootfs/usr/local/bin/basalt-install
find scripts -type f ! -name '.gitkeep' -exec sh -n {} +
find tests -type f -name '*.sh' -exec sh -n {} +
./tests/installer-starts.sh
./tests/iso-build-artifact.sh
./tests/iso-boots-uefi.sh
test -f profiles/basalt-releng/packages.x86_64
test -f profiles/basalt-releng/pacman.conf
test -f profiles/basalt-releng/profiledef.sh
test -f profiles/basalt-releng/airootfs/etc/os-release
```

Build the ISO on an Arch builder with `archiso` installed:

```sh
./scripts/build-iso
```

Run the artifact smoke against a real build:

```sh
BASALT_ISO_BUILD_SMOKE=1 ./tests/iso-build-artifact.sh
```

Boot a generated ISO under UEFI and wait for the live serial marker:

```sh
BASALT_ISO_PATH=/path/to/basaltos.iso ./tests/iso-boots-uefi.sh
```

The UEFI boot smoke waits for both the live boot marker and the installer marker:

```text
BASALT_LIVE_BOOT_OK
BASALT_INSTALLER_SMOKE_OK
```

Attach a writable qcow2 target disk and require installer disk-planning markers:

```sh
BASALT_ISO_PATH=/path/to/basaltos.iso \
BASALT_ISO_TARGET_DISK=/tmp/basalt-install-target.qcow2 \
BASALT_ISO_REQUIRE_TARGET_DISK=1 \
  ./tests/iso-boots-uefi.sh
```

Additional target-disk markers:

```text
BASALT_TARGET_DISK_OK
BASALT_TARGET_INSTALL_PLAN_OK
```

Build an ISO with an embedded local Basalt pacman repo payload and require the live image to see it:

```sh
BASALT_ISO_EMBED_LOCAL_REPO=1 \
BASALT_ISO_REQUIRE_REPO_PAYLOAD=1 \
  ../tests/scripts/run-arch-vm-iso-boot
```

The repo payload is copied into the live image at:

```text
/opt/basalt/repo
```

Additional repo-payload marker:

```text
BASALT_REPO_PAYLOAD_OK
```
