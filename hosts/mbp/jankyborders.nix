{ config, pkgs, ... }:
let
  # Colors from colorScheme (without # prefix for JankyBorders)
  colors = with config.colorScheme.palette; {
    active = builtins.replaceStrings [ "#" ] [ "" ] base0E; # purple/magenta
    inactive = builtins.replaceStrings [ "#" ] [ "" ] base03; # muted gray
  };
in
{
  home.packages = [ pkgs.jankyborders ];

  launchd.agents.jankyborders = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "style=round"
        "width=5.0"
        "hidpi=on"
        "active_color=0xff${colors.active}"
        "inactive_color=0x00${colors.inactive}"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
