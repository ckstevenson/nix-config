# Game launchers

The workstation uses Hyprland with `bemenu-run` as its desktop application
launcher.

## Desktop interaction

1. Press **Super+D**.
2. Type the application name.
3. Press **Enter**.

You can also launch any program from a terminal with its command name.
`Super+Return` opens Alacritty, and **Super+F** opens `lf`.

## Game and library launchers

| Launcher | Use |
| --- | --- |
| **Steam** | Main library for Steam games, Proton, controller setup, and Steam gamepad remapping. |
| **Lutris** | Import and launch non-Steam Windows games and configure Wine runners. |
| **RetroArch** | Launch retro games through the installed libretro cores. Use its content browser to select a ROM and then choose a core when prompted. |
| **Xodus Nexus** (`xodus-nexus`) | Launch and manage the Xodus/Nexus game library. |
| **Limo** (`limo`) | Manage Mod Organizer 2-style game mod lists where supported. |
| **ProtonUp-Qt** (`protonup-qt`) | Install and manage custom Proton and Wine-GE versions used by Steam or Lutris. |
| **Steam ROM Manager** (`steam-rom-manager`) | Generate Steam shortcuts for emulator games and import them into Steam. |

## Standalone console launchers

These are installed for systems where a native frontend is usually easier
than a RetroArch core:

| Command | Console |
| --- | --- |
| `eden` | Nintendo Switch |
| `ryujinx` | Nintendo Switch (Ryubing package) |
| `lichii` | Experimental Nintendo Switch 2 |
| `xemu` | Original Xbox |
| `xenia_canary` | Xbox 360 |
| `pcsx2-qt` | PlayStation 2 |
| `rpcs3` | PlayStation 3 |
| `shadps4` | Experimental PlayStation 4 |
| `dolphin-emu` | GameCube and Wii |
| `cemu` | Wii U |
| `azahar` | Nintendo 3DS |
| `vita3k` | PlayStation Vita |
| `ppsspp` | PlayStation Portable |

For these, launch the command from a terminal or search for the application
name with **Super+D**. Add games, firmware, BIOS files, or keys inside the
frontend's own settings. Those files are user-owned data and are not part of
the Nix configuration.

## Overlays and performance tools

- **MangoHud**: enable an FPS and frame-time overlay with `mangohud <game>`.
- **Goverlay**: graphical MangoHud configuration.
- **Gamescope**: optional game compositor; use it from Steam launch options or
  from a terminal when a game benefits from a fixed resolution.
- **Proton-GE**: available in Steam's compatibility tools as `GE-Proton`; select
  it per game under Properties > Compatibility.
- **Steam Gamescope Session**: select `gamescope-session` from the login/session
  menu when you want a console-style Steam interface.
- **LACT**: launch `lact` to monitor and configure supported AMD GPU clocks,
  power limits, fan behavior, and profiles. Apply changes conservatively.
- **GameMode**: Steam and Lutris games can request it with `gamemoderun %command%`.
  The system configuration applies the workstation's gaming priorities.
- **zram and ntsync**: zram provides compressed emergency swap, while the
  loaded `ntsync` kernel module improves synchronization for supported Proton/Wine
  versions. No manual interaction is required.
- **Nix maintenance**: the system runs weekly garbage collection and enables
  store optimisation automatically.
- **vkBasalt**: optional Vulkan post-processing, enabled per application with
  its environment variables.
