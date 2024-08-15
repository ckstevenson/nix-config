{ config, lib, osConfig, pkgs, ... }:
{
  options = {
    waybarFontSize = lib.mkOption {
      type = lib.types.str;
      default = "18";
    };

    waybarStyle = lib.mkOption {
      type = lib.types.str;
      default = ''
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
      '';
    };
  };
        #font-size: ${toString config.fontSize}px;

  config = lib.mkIf osConfig.desktop.enable {
    programs.waybar = {
      style = config.waybarStyle;
      enable = true;
      #systemd.enable = true;
      settings = with config.colorScheme.palette; {
        mainBar = {
          layer = "top";
          position = "bottom";
          modules-left = [ "hyprland/workspaces"];
          modules-center = [ "clock" ];
          modules-right = [ "battery" "backlight" "pulseaudio" "cpu" "memory" "network" "disk" ];

          "hyprland/workspaces" = {
            all-outputs = true;
            on-click = "activate";
          };
          "clock" = {
            "format" = "{:%H:%M}  ";
            "format-alt" = "{:%A, %B %d, %Y (%R)}  ";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            "calendar" = {
              "mode"           = "year";
              "mode-mon-col"   = 3;
              "weeks-pos"      = "right";
              "on-scroll"      = 1;
              "on-click-right" = "mode";
              "format" = {
                "months" =     "<span color='#${base0D}'><b>{}</b></span>";
                "days" =       "<span color='#${base04}'><b>{}</b></span>";
                "weeks" =      "<span color='#${base0F}'><b>W{}</b></span>";
                "weekdays" =   "<span color='#${base0E}'><b>{}</b></span>";
                "today" =      "<span color='#${base0A}'><b><u>{}</u></b></span>";
              };
            };
          };
          "memory" = {
            "interval" = 30;
            "format" = " {used:0.1f}G/{total:0.1f}G";
          };
          "cpu" = {
            "interval" = 10;
            "format" = " {}%";
            "max-length" = 10;
          };
          "network" = {
            "interval" = 10;
            "format" = "󰛳 {ipaddr}";
          };
          "pulseaudio" = {
            "format" = "{icon} {volume}%";
            "format-bluetooth" = "{volume}% {icon}";
            "format-muted" = "";
            "format-icons" = {
              "headphone" = "";
              "hands-free" = "hands-free";
              "headset" = "headset";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [
                ""
                ""
                ""
              ];
            };
            "scroll-step" = 1;
            "on-click" = "${pkgs.alacritty}/bin/alacritty -e pulsemixer";
            #"on-click" = "alacritty -e pulsemixer";
          };
          "disk" = {
              "interval" = 30;
              "format" = "󰋊 {used}/{total}";
              "path" = "/";
          };
          "battery" = {
            "bat" = "BAT1";
            "interval" = 60;
            "states" = {
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{icon} {capacity}%";
            "format-icons" = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂"];
            "format-charging" = "󰂄 {capacity}%";
          };
          "backlight" = {
              "device" = "intel_backlight";
              "format" = "{icon} {percent}%";
              "format-icons" = [ "󰃞" "󰃟" "󰃝" "󰃠" ];
          };
        };
      };
    };
  };
}
