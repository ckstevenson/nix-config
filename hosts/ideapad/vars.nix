{ lib, config, ... }:
{
  options = with lib; with types; {
    fontSize = mkOption { type = int; };
  };

  config = {
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
  };
}
