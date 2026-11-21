{ config, lib, osConfig, pkgs, ... }:
let
  mullvadStatus = pkgs.writeShellScript "waybar-mullvad-status" ''
    status="$(mullvad status 2>/dev/null || true)"
    case "$status" in
      Connected*)
        text="󰖂"
        class="connected"
        ;;
      Connecting*)
        text="󰖂"
        class="connecting"
        ;;
      *)
        text="󰖂"
        class="disconnected"
        ;;
    esac
    ${pkgs.jq}/bin/jq -cn \
      --arg text "$text" \
      --arg tooltip "$status" \
      --arg class "$class" \
      '{text: $text, tooltip: $tooltip, class: $class}'
  '';
  mullvadToggle = pkgs.writeShellScript "waybar-mullvad-toggle" ''
    if mullvad status 2>/dev/null | grep -q '^Connected'; then
      mullvad disconnect
    else
      mullvad connect
    fi
  '';
  mullvadReconnect = pkgs.writeShellScript "waybar-mullvad-reconnect" ''
    mullvad reconnect
  '';
  tailscaleStatus = pkgs.writeShellScript "waybar-tailscale-status" ''
    state="$(tailscale status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.BackendState // "Unknown"')"
    case "$state" in
      Running)
        text="󰒋"
        class="connected"
        ;;
      *)
        text="󰒋"
        class="disconnected"
        ;;
    esac
    ${pkgs.jq}/bin/jq -cn \
      --arg text "$text" \
      --arg tooltip "Tailscale: $state" \
      --arg class "$class" \
      '{text: $text, tooltip: $tooltip, class: $class}'
  '';
  tailscaleToggle = pkgs.writeShellScript "waybar-tailscale-toggle" ''
    state="$(tailscale status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.BackendState // "Unknown"')"
    if [ "$state" = Running ]; then
      tailscale down
    else
      tailscale up ${lib.concatStringsSep " " osConfig.services.tailscale.extraUpFlags}
    fi
  '';
in
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
        #custom-mullvad.connected, #custom-tailscale.connected {
          color: #${config.colorScheme.palette.base0B};
        }
        #custom-mullvad.disconnected, #custom-tailscale.disconnected {
          color: #${config.colorScheme.palette.base08};
        }
        #custom-mullvad.connecting {
          color: #${config.colorScheme.palette.base0A};
        }
        #idle_inhibitor.activated {
          color: #${config.colorScheme.palette.base0A};
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
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "custom/mullvad"
            "custom/tailscale"
            "idle_inhibitor"
            "battery"
            "backlight"
            "pulseaudio"
            "cpu"
            "memory"
            "network"
            "disk"
            "custom/power"
          ];

          "tray" = {
            "icon-size" = 18;
            "spacing" = 6;
          };
          "custom/mullvad" = lib.mkIf osConfig.services.mullvad-vpn.enable {
            "exec" = mullvadStatus;
            "return-type" = "json";
            "interval" = 5;
            "on-click" = mullvadToggle;
            "on-click-right" = mullvadReconnect;
            "on-click-middle" = "${pkgs.mullvad-vpn}/bin/mullvad-vpn";
            "format" = "{}";
            "tooltip" = true;
          };
          "custom/tailscale" = lib.mkIf osConfig.services.tailscale.enable {
            "exec" = tailscaleStatus;
            "return-type" = "json";
            "interval" = 5;
            "on-click" = tailscaleToggle;
            "format" = "{}";
            "tooltip" = true;
          };
          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "󰅶";
              "deactivated" = "󰾪";
            };
            "tooltip-format-activated" = "Idle inhibitor on";
            "tooltip-format-deactivated" = "Idle inhibitor off";
          };

          "hyprland/workspaces" = {
            all-outputs = true;
            on-click = "activate";
          };
          "clock" = {
            "format" = "{:%H:%M}  ";
            "format-alt" = "{:%A, %B %d, %Y (%R)}  ";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            "calendar" = {
              "mode" = "year";
              "mode-mon-col" = 3;
              "weeks-pos" = "right";
              "on-scroll" = 1;
              "on-click-right" = "mode";
              "format" = {
                "months" = "<span color='#${base0D}'><b>{}</b></span>";
                "days" = "<span color='#${base04}'><b>{}</b></span>";
                "weeks" = "<span color='#${base0F}'><b>W{}</b></span>";
                "weekdays" = "<span color='#${base0E}'><b>{}</b></span>";
                "today" = "<span color='#${base0A}'><b><u>{}</u></b></span>";
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
            "on-click" = "${pkgs.pwvucontrol}/bin/pwvucontrol";
            "on-click-right" = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
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
            "format-icons" = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" ];
            "format-charging" = "󰂄 {capacity}%";
          };
          "backlight" = {
            "device" = "intel_backlight";
            "format" = "{icon} {percent}%";
            "format-icons" = [ "󰃞" "󰃟" "󰃝" "󰃠" ];
          };
          "custom/power" = {
            "format" = "⏻";
            "tooltip" = false;
            "on-click" = "${pkgs.wlogout}/bin/wlogout";
          };
        };
      };
    };

    home.packages = [ pkgs.pwvucontrol pkgs.wlogout ];

    home.file.".config/wlogout/layout".text = ''
      {
        "label": "lock",
        "action": "hyprlock",
        "text": "Lock",
        "keybind": "l"
      }
      {
        "label": "logout",
        "action": "hyprctl dispatch exit",
        "text": "Logout",
        "keybind": "e"
      }
      {
        "label": "suspend",
        "action": "systemctl suspend",
        "text": "Suspend",
        "keybind": "s"
      }
      {
        "label": "reboot",
        "action": "systemctl reboot",
        "text": "Reboot",
        "keybind": "r"
      }
      {
        "label": "shutdown",
        "action": "systemctl poweroff",
        "text": "Shutdown",
        "keybind": "p"
      }
    '';

    home.file.".config/wlogout/style.css".text = with config.colorScheme.palette; ''
      * {
        font-family: sans-serif;
        font-size: 24px;
      }
      window {
        background-color: #${base00}cc;
      }
      button {
        color: #${base04};
        background-color: #${base01};
        border: 2px solid #${base03};
        border-radius: 12px;
        margin: 8px;
      }
      button:hover {
        color: #${base00};
        background-color: #${base0D};
      }
    '';
  };
}
