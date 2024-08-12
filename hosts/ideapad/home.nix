{ config, pkgs, ... }:
{

  firefoxFontSize = 20;
  alacrittyFontSize = 12;
  gtkFontSize = 14;
  backupService.enable = false;
  waybarStyle = ''
    * {
      font-size: 13px;
      color: #${config.colorScheme.palette.base04};
    }
    window#waybar {
      background: #${config.colorScheme.palette.base00};
      border: none;
    }
    label.module {
      padding: 0 5px;
    }
    #workspaces button.active {
      border-bottom: 3px solid #${config.colorScheme.palette.base0E};
    }
    #workspaces button.urgent {
      background-color: #${config.colorScheme.palette.base0A};
    }
    #workspaces button:hover {
      background: #${config.colorScheme.palette.base00};
    }
    #battery.critical:not(.charging) {
      color: #${config.colorScheme.palette.base0A};
    }
    #battery.warning:not(.charging) {
      color: #${config.colorScheme.palette.base0C};
    }
  '';

  nixpkgs = {
    config.allowUnfree = true;
  };

  imports = [
    ../../modules/home-manager
  ];

  home.packages = with pkgs; [
    bambu-studio
    brightnessctl
    dconf
    ferdium
    mpv
    pcmanfm
    playerctl
    pulseaudio
    pulsemixer
    signal-desktop
    slack
    slack-term
    sxiv
    teams-for-linux
    xdg-utils
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    #SUDO_ASKPASS = "${pkgs.bemenu} --prompt $1 --password --no-exec </dev/null";
    IMAGE = "sxiv";
    VIDEO = "mpv";
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
