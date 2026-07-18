# iso

archiso, installer, and recovery environment repository.

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

Run syntax and profile-shape checks before ISO build behavior exists:

```sh
bash -n profiles/basalt-releng/profiledef.sh
find scripts -type f ! -name '.gitkeep' -exec sh -n {} +
find tests -type f -name '*.sh' -exec sh -n {} +
test -f profiles/basalt-releng/packages.x86_64
test -f profiles/basalt-releng/pacman.conf
test -f profiles/basalt-releng/profiledef.sh
test -f profiles/basalt-releng/airootfs/etc/os-release
```
