{ config, osConfig, lib, pkgs, ... }: {
  config = lib.mkIf osConfig.desktop.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          #grace = 300;
          hide_cursor = true;
          no_fade_in = false;
          no_update_news = true;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            #placeholder_text = '\'<span foreground="##cad3f5">Password...</span>'\';
            shadow_passes = 2;
          }
        ];
      };
    };
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "hyprlock";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      # Whether to enable XWayland
      # xwayland.enable = true;

      systemd.enable = true;

      settings = {
        monitor = " , preferred, auto, 1";
        env = [
          "XCURSOR_SIZE,24"
          "XCURSOR_THEME,Adwaita"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "HYPRLAND_NO_SD_NOTIFY=1"
          "HYPRLAND_NO_RT=1"
          "GDK_BACKEND,wayland,x11,*"
          "QT_QPA_PLATFORM,wayland;xcb"
          "SDL_VIDEODRIVER,wayland"
          "CLUTTER_BACKEND,wayland"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "QT_QPA_PLATFORMTHEME,qt5ct"
        ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          kb_options = "caps:escape";

          touchpad = {
            natural_scroll = "false";
          };

          sensitivity = -0.2;
          repeat_rate = 67; # Keys per second when held (~66.6 to match macOS, default is 25)
          repeat_delay = 375; # Delay in ms before repeat starts (matches macOS default of 25×15ms)
        };

        general = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;
          "col.active_border" = "rgba(${config.colorScheme.palette.base0E}ff) rgba(${config.colorScheme.palette.base09}ff) 60deg";
          "col.inactive_border" = "rgba(${config.colorScheme.palette.base00}ff)";

          layout = "master";

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
        };

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          rounding = 0;
          #drop_shadow = "yes";
          #shadow_range = 4;
          #shadow_render_power = 3;
          #"col.shadow" = "rgba(1a1a1aee)";
        };

        animations = {
          enabled = true;
          bezier = [
            "snappy, 0.05, 0.9, 0.1, 1.0"
            "quick, 0.25, 0.9, 0.25, 1.0"
          ];
          animation = [
            "windows, 1, 2, snappy, popin 90%"
            "windowsIn, 1, 2, snappy, popin 90%"
            "windowsOut, 1, 2, snappy, popin 90%"
            "windowsMove, 1, 2, snappy, slide"
            "fade, 1, 3, quick"
            "fadeIn, 1, 3, quick"
            "fadeOut, 1, 3, quick"
            "fadeSwitch, 1, 3, quick"
            "fadeShadow, 1, 3, quick"
            "fadeDim, 1, 3, quick"
            "border, 1, 3, quick"
            "borderangle, 1, 3, quick"
            "workspaces, 1, 3, snappy, slide"
            "specialWorkspace, 1, 2, snappy, slidevert"
          ];
        };

        master = {
          mfact = 0.5;
        };

        misc = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          focus_on_activate = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
        exec-once = [
          "wpaperd"
          "waybar"
          "lxqt-policykit-agent"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "rbw unlock"
          #"[workspace 10 silent] slack"
        ];

        "$mainMod" = "SUPER";
        "$terminal" = "alacritty";

        bindm = [
          # mouse movements
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        binds = {
          allow_workspace_cycles = true;
        };

        bindl = [
          ",XF86AudioPlay,    exec, playerctl play-pause"
          ",XF86AudioStop,    exec, playerctl pause"
          ",XF86AudioPause,   exec, playerctl pause"
          ",XF86AudioPrev,    exec, playerctl previous"
          ",XF86AudioNext,    exec, playerctl next"
          ",XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
          ",XF86AudioRaiseVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
          ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
          ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
        ];

        bind = [
          "$mainMod, Return, exec, $terminal"
          "$mainMod SHIFT, Q, killactive"
          "$mainMod SHIFT, Escape, exit"
          "$mainMod SHIFT, r, forcerendererreload"
          "$mainMod, F, exec, $terminal -e lf"
          "$mainMod SHIFT, o, togglefloating"
          "$mainMod, D, exec, bemenu-run"
          "$mainMod, W, exec, firefox"
          "$mainMod, c, exec, chromium-browser"
          "$mainMod, a, exec, $terminal -e pulsemixer"
          "$mainMod, p, exec, rbw-bemenu"
          "$mainMod, x, exec, hyprlock"

          # Move focus
          "$mainMod, l, movefocus, r"
          "$mainMod, h, movefocus, l"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          # Move windows
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9] (without following)
          "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
          "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
          "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

          # Move active window to a workspace and follow with mainMod + ALT + [0-9]
          "$mainMod ALT, 1, movetoworkspace, 1"
          "$mainMod ALT, 2, movetoworkspace, 2"
          "$mainMod ALT, 3, movetoworkspace, 3"
          "$mainMod ALT, 4, movetoworkspace, 4"
          "$mainMod ALT, 5, movetoworkspace, 5"
          "$mainMod ALT, 6, movetoworkspace, 6"
          "$mainMod ALT, 7, movetoworkspace, 7"
          "$mainMod ALT, 8, movetoworkspace, 8"
          "$mainMod ALT, 9, movetoworkspace, 9"
          "$mainMod ALT, 0, movetoworkspace, 10"

          # Return to previous workspace
          "$mainMod, TAB, workspace, previous"

          # Example special workspace (scratchpad)
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e-1"
          "$mainMod, mouse_up, workspace, e+1"

          # Fullscreen
          "$mainMod SHIFT, F, fullscreen"

          # Groups (tabs)
          "$mainMod SHIFT, T, togglegroup"
          "$mainMod SHIFT, bracketleft, changegroupactive, b"
          "$mainMod SHIFT, bracketright, changegroupactive, f"
        ];
      };
    };

    programs.zsh.profileExtra = ''
      [[ $(tty) == /dev/tty1 ]] && exec start-hyprland
    '';
  };
}
