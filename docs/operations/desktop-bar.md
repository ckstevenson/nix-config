# Waybar controls

The workstation uses Waybar at the bottom of the Hyprland desktop. Most
controls are clickable; hover over an icon for its current state.

| Control | Left click | Right click | Middle click |
| --- | --- | --- | --- |
| Mullvad | Connect or disconnect | Reconnect | Open the Mullvad GUI |
| Tailscale | Bring the tunnel up or down | — | — |
| Idle inhibitor | Keep the screen awake or restore idle handling | — | — |
| Audio | Open `pulsemixer` in Alacritty | Mute or unmute the default sink | — |
| Power | Open the power menu | — | — |

The system tray shows applications that expose tray icons, such as Steam or
the Mullvad GUI. The power menu provides lock, logout, suspend, reboot, and
shutdown actions.

The Tailscale button changes network connectivity. Turning it off drops
connections using Tailscale, including SSH sessions that use a Tailscale
address. Use the workstation's LAN address when testing this control.
