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

  imports = [
    ../../modules/home-manager
  ];

  home.packages = with pkgs; [
    _1password-gui
    _1password
    vmware-horizon-client
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
