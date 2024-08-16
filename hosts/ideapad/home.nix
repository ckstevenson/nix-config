{ config, pkgs, ... }:
{
  alacrittyFontSize = 16;
  waybarFontSize = "20";
  firefoxFontSize = 18;
  waybarStyle = ''
    * {
      font-size: ${config.waybarFontSize}px;
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

  nextcloudSyncService.enable = true;

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
    dnsutils
    ferdium
    htop
    libreoffice
    mpv
    nextcloud-client
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
    zoom-us
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
