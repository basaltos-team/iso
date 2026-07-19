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
