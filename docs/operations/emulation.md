# Emulation

The workstation installs RetroArch with a broad set of libretro cores and
standalone emulators for systems that benefit from their native frontend.
Games, ROMs, firmware, BIOS files, encryption keys, and controller profiles
are intentionally not stored in this repository.

## Installed emulators

- RetroArch: NES, SNES, Genesis, Mega Drive, GB/GBA, Game Gear, arcade,
  PlayStation, Saturn, Dreamcast, PC Engine, N64, DS, and Wii/GameCube cores.
- Switch: Eden and Ryubing.
- Original Xbox: xemu.
- Xbox 360: xenia-canary.
- PlayStation 2: PCSX2.
- PlayStation 3: RPCS3.
- GameCube/Wii: Dolphin.
- Wii U: Cemu.
- Nintendo 3DS: Azahar.
- PlayStation Vita: Vita3K.
- PSP: PPSSPP.

## Experimental emulators

Set `gaming.emulators.experimental.enable = false` to omit:

- Lichii, a pinned experimental Nintendo Switch 2 AppImage.
- shadPS4, an early PlayStation 4 emulator.

Lichii and shadPS4 are expected to have incomplete compatibility and may
regress between releases. Lichii is pinned in
`modules/home-manager/pkgs/lichii.nix` and should be updated deliberately.

There is currently no released, usable Xbox One or Xbox Series emulator for
this Linux workstation. XWine1 is an unreleased project, so it is not added
to the configuration.

## Firmware and game files

Only dump games and system files from hardware and media you own, and follow
the laws that apply to you. Each emulator's own documentation describes the
required BIOS, firmware, keys, and system files. Keep those files in your
user data directories or emulator-specific configuration directories; never
commit them to this repository.

The RX 5600/5700 and i5-13600K are suitable for the installed 3D emulators,
but compatibility remains game-specific. Use Vulkan and the standalone
emulator frontend when it provides features or performance beyond the
RetroArch core.
