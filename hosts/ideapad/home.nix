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

  # Enable secure backup service with SOPS integration
  services.backupService.enable = true;

  # Configure SOPS for secrets management
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/backup/restic.yaml;
  };

  imports = [
    ../../modules/home-manager
  ];

  home.packages = with pkgs; [
    _1password-gui
    _1password-cli
    # vmware-horizon-client # Removed from nixpkgs
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
