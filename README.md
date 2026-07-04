# basalt-iso

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
basalt-iso/
|-- profiles/
|   `-- basalt-releng/
|       `-- airootfs/
|-- installer/
|-- recovery/
`-- scripts/
```

## Contracts

- Consumes repo channel metadata from `basalt-repo/`.
- Consumes installer logic/artifacts from `basalt/`.
- Consumes example profiles from `basalt-configs/`.
- Emits ISO artifacts consumed by `basalt-tests/` and release manifests.

