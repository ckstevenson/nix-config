{ config, osConfig, lib, pkgs, ... }: {
  config = lib.mkIf osConfig.desktop.enable {
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
            drop_shadow = "yes";
            shadow_range = 4;
            shadow_render_power = 3;
            "col.shadow" = "rgba(1a1a1aee)";
        };

        #animations = {
        #    enabled = "yes";
        #
        #    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
        #    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        #
        #    animation =  [
        #      "windows, 1, 7, myBezier"
        #      "windowsOut, 1, 7, default, popin 80%"
        #      "border, 1, 10, default"
        #      "borderangle, 1, 8, default"
        #      "fade, 1, 7, default"
        #      "workspaces, 1, 6, default"
        #    ];
        #};

        #master = {
        #    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        #    new_is_master = false;
        #};

        gestures = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            #workspace_swipe = "off";
        };

        misc = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          focus_on_activate = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
        #"device:epic-mouse-v1" = {
        #    sensitivity = -0.5;
        #};
        exec-once = [
          "wpaperd"
          "waybar"
          "lxqt-policykit-agent"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        ];

        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        #windowrulev2 = "nomaximizerequest, class:.*"; # You'll probably like this.
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
          "$mainMod SHIFT, T, togglesplit"
          "$mainMod, W, exec, firefox"
          "$mainMod, c, exec, chromium-browser"
          "$mainMod, a, exec, $terminal -e pulsemixer"
          "$mainMod, p, exec, rbw-bemenu"

          # Move focus
          "$mainMod, l, movefocus, r"
          "$mainMod, h, movefocus, l"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"
         # "$mainMod, p, cyclenext, prev"
         # "$mainMod, n, cyclenext"

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

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

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

          # Groups
          "$mainMod SHIFT, T, togglegroup"
          "$mainMod, p, changegroupactive, back"
          "$mainMod, n, changegroupactive, forward"
        ];
      };
    };

    programs.zsh.profileExtra = ''
      [[ $(tty) == /dev/tty1 ]] && exec Hyprland
    '';
  };
}
