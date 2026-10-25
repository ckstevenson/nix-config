# Skyrim Together Reborn

This guide records the Skyrim Together Reborn setup on the `workstation` host.
It separates reproducible Nix configuration from host-local game and Lutris
state.

## Declarative Configuration

The repository manages the following pieces:

- `modules/home-manager/gaming.nix` installs Limo, Lutris, ProtonUp-Qt,
  Gamescope, MangoHud, and related gaming tools.
- `modules/home-manager/gaming.nix` contains a narrow Limo build workaround for
  missing C++ standard-library includes in the current nixpkgs package.
- `modules/nixos/gaming.nix` defines `gaming.skyrimTogether.enable` and opens
  UDP port `10578` only when that option is enabled.
- `hosts/workstation/configuration.nix` enables the reusable gaming module.

The workstation currently leaves `gaming.skyrimTogether.enable` disabled.
Joining another player's server does not need an inbound firewall rule. Enable
the option only when hosting:

```nix
gaming.skyrimTogether.enable = true;
```

Then validate and apply the host configuration:

```bash
nix flake check --show-trace
sudo nixos-rebuild switch --flake .#workstation
```

Remote hosting may also require UDP `10578` forwarded by the router.

## Host-Local State

The following setup is not managed by Nix and is not reproduced by a rebuild:

- Skyrim and Steam library files under
  `/home/cameron/Games/SteamLibrary`.
- STR files under
  `Skyrim Special Edition/Data/SkyrimTogetherReborn`.
- Address Library under `Skyrim Special Edition/Data/SKSE/Plugins`.
- Proton plugin state under the shared prefix:
  `steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/`.
- Lutris database entry ID `6` in
  `/home/cameron/.local/share/lutris/pga.db`.
- Lutris game config under
  `/home/cameron/.local/share/lutris/games/`.
- Local launcher wrapper at `/home/cameron/bin/lutris-skyrim-together`.
- GE-Proton `10-34` under
  `/home/cameron/.local/share/lutris/runners/wine/ge-proton`.
- Steam and Lutris backup files created during setup.

The wrapper intentionally uses GE-Proton `10-34` directly. It reuses the Steam
compatibility prefix for app ID `489830`, runs from the STR directory, and
provides the graphical session and Steam environment required by the launcher.
Do not switch Proton versions casually in this shared prefix.

## Launch

Launch the Lutris entry:

```bash
lutris lutris:rungameid/6
```

Expected runtime state:

- A `Skyrim Together` window appears.
- `SkyrimTogether.exe` and its CEF `TPProcess.exe` children remain active.
- `Data/SkyrimTogetherReborn/logs/tp_client.log` grows.
- A separate `SkyrimSE.exe` process is not expected; STR loads Skyrim in the
  launcher process.

For first multiplayer use, create a new game and complete Helgen until outside
the cave. Use `F2` or Right Ctrl for the multiplayer UI. Do not connect during
the Helgen introduction.

## Compatibility

Current tested combination:

- Skyrim runtime: `1.7.104`
- Skyrim Together Reborn: `1.8.3`
- Address Library: `versionlib-1-7-104-0.bin` for `1.7.104`
- GE-Proton: `10-34`
- Steam app ID: `489830`

The paid Anniversary Upgrade is disabled and should remain disabled for STR
multiplayer. SKSE is not required. All players need compatible Skyrim, STR,
Address Library, and mod versions.

## Update Watch List

After any update, check the following in order:

1. **Skyrim:** Steam updates can change the executable version. Confirm the
   runtime still matches the STR release and Address Library file.
2. **STR:** Check official TiltedPhoques releases. Replace the manually
   installed STR files only with a release compatible with the Skyrim runtime.
3. **Address Library:** Install the file matching the exact Skyrim runtime.
4. **GE-Proton:** Confirm `GE-Proton10-34` still exists. If changing versions,
   update the local wrapper and test the shared prefix before multiplayer use.
5. **Lutris:** Confirm ID `6` remains listed and still launches the local
   wrapper. Lutris updates can change runner, database, or config behavior.
6. **Nix inputs:** After flake updates, run `nix flake check --show-trace` and
   build the workstation before applying. Recheck the Limo workaround if the
   package source changes.
7. **Mods:** Verify `SkyrimTogether.esp` and
   `SkyrimTogetherQuestPatches.esp` remain enabled after mod-manager changes.
8. **Networking:** If hosting, verify UDP `10578` is enabled in the active
   firewall and forwarded by the router when needed.

Useful checks:

```bash
lutris -l
grep -n 'CURRENT_PREFIX_VERSION' \
  "$HOME/.local/share/lutris/runners/wine/ge-proton/proton"
stat "$HOME/Games/SteamLibrary/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn/logs/tp_client.log"
```

Keep downloaded Nexus archives and runtime backups outside the Git repository.
They may contain mutable game state and are not reproducible Nix inputs.
