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

