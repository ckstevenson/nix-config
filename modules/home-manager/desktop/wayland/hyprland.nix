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

      # Force the Lua config format on all hosts sharing this module.
      # configType only defaults to "lua" when home.stateVersion >= 26.05
      # (workstation), but ideapad is still on 23.11 and would otherwise get
      # "hyprlang", which cannot serialize the Lua settings schema below.
      configType = "lua";

      # All settings below use the Lua hl.* API via the HM settings schema.
      settings =
        let
          mkLuaInline = lib.generators.mkLuaInline;
          mod = mkLuaInline "mod";
          terminal = mkLuaInline "terminal";
        in
        {
          # Lua local variables (no $-prefix — pure Lua)
          mod = { _var = "SUPER"; };
          terminal = { _var = "alacritty"; };

          # Monitor: hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
          monitor = [
            {
              _args = [
                {
                  output = "";
                  mode = "preferred";
                  position = "auto";
                  scale = "auto";
                }
              ];
            }
          ];

          # Environment variables: hl.env("KEY", "value")
          env = [
            { _args = [ "XCURSOR_SIZE" "24" ]; }
            { _args = [ "XCURSOR_THEME" "Adwaita" ]; }
            { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
            { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
            { _args = [ "XDG_SESSION_DESKTOP" "Hyprland" ]; }
            { _args = [ "HYPRLAND_NO_SD_NOTIFY" "1" ]; }
            { _args = [ "HYPRLAND_NO_RT" "1" ]; }
            { _args = [ "GDK_BACKEND" "wayland,x11,*" ]; }
            { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
            { _args = [ "SDL_VIDEODRIVER" "wayland" ]; }
            { _args = [ "CLUTTER_BACKEND" "wayland" ]; }
            { _args = [ "QT_AUTO_SCREEN_SCALE_FACTOR" "1" ]; }
            { _args = [ "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1" ]; }
            { _args = [ "QT_QPA_PLATFORMTHEME" "qt5ct" ]; }
          ];

          # Main config block: hl.config({ ... })
          config = {
            general = {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              gaps_in = 5;
              gaps_out = 5;
              border_size = 1;
              col = {
                active_border = {
                  colors = [
                    "rgba(${config.colorScheme.palette.base0E}ff)"
                    "rgba(${config.colorScheme.palette.base09}ff)"
                  ];
                  angle = 60;
                };
                inactive_border = "rgba(${config.colorScheme.palette.base00}ff)";
              };
              layout = "master";
              # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
              allow_tearing = false;
            };

            decoration = {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              rounding = 0;
            };

            animations = {
              enabled = true;
            };

            cursor = {
              inactive_timeout = 2;
              hide_on_key_press = true;
              hide_on_touch = true;
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

            binds = {
              allow_workspace_cycles = true;
            };

            input = {
              kb_layout = "us";
              follow_mouse = 1;
              kb_options = "caps:escape";
              touchpad = {
                natural_scroll = false;
              };
              sensitivity = -0.2;
              repeat_rate = 67; # Keys per second when held (~66.6 to match macOS, default is 25)
              repeat_delay = 375; # Delay in ms before repeat starts (matches macOS default)
            };
          };

          # Curves (bezier): hl.curve("name", { type = "bezier", points = { {x1,y1}, {x2,y2} } })
          curve = [
            { _args = [ "snappy" { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1 1.0 ] ]; } ]; }
            { _args = [ "quick" { type = "bezier"; points = [ [ 0.25 0.9 ] [ 0.25 1.0 ] ]; } ]; }
          ];

          # Animations: hl.animation({ leaf = "...", enabled = true, speed = N, bezier = "...", style = "..." })
          animation = [
            { _args = [{ leaf = "windows"; enabled = true; speed = 2; bezier = "snappy"; style = "popin 90%"; }]; }
            { _args = [{ leaf = "windowsIn"; enabled = true; speed = 2; bezier = "snappy"; style = "popin 90%"; }]; }
            { _args = [{ leaf = "windowsOut"; enabled = true; speed = 2; bezier = "snappy"; style = "popin 90%"; }]; }
            { _args = [{ leaf = "windowsMove"; enabled = true; speed = 2; bezier = "snappy"; style = "slide"; }]; }
            { _args = [{ leaf = "fade"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "fadeIn"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "fadeOut"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "fadeSwitch"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "fadeShadow"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "fadeDim"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "border"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "borderangle"; enabled = true; speed = 3; bezier = "quick"; }]; }
            { _args = [{ leaf = "workspaces"; enabled = true; speed = 3; bezier = "snappy"; style = "slide"; }]; }
            { _args = [{ leaf = "specialWorkspace"; enabled = true; speed = 2; bezier = "snappy"; style = "slidevert"; }]; }
          ];

          # Autostart: use on("hyprland.start", fn) hook (exec-once equivalent in Lua)
          on = {
            _args = [
              "hyprland.start"
              (mkLuaInline ''function()
  hl.exec_cmd("wpaperd")
  hl.exec_cmd("waybar")
  hl.exec_cmd("lxqt-policykit-agent")
  hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
end'')
            ];
          };

          # Mouse binds: hl.bind(keys, dispatcher, { mouse = true })
          bind = [
            # Application launchers
            { _args = [ (mkLuaInline ''mod .. " + Return"'') (mkLuaInline "hl.dsp.exec_cmd(terminal)") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + Q"'') (mkLuaInline "hl.dsp.window.close()") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + Escape"'') (mkLuaInline "hl.dsp.exit()") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + R"'') (mkLuaInline "hl.dsp.force_renderer_reload()") ]; }
            { _args = [ (mkLuaInline ''mod .. " + F"'') (mkLuaInline ''hl.dsp.exec_cmd(terminal .. " -e lf")'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + O"'') (mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + D"'') (mkLuaInline ''hl.dsp.exec_cmd("bemenu-run")'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + W"'') (mkLuaInline ''hl.dsp.exec_cmd("firefox")'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + C"'') (mkLuaInline ''hl.dsp.exec_cmd("chromium-browser")'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + A"'') (mkLuaInline ''hl.dsp.exec_cmd(terminal .. " -e pulsemixer")'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + P"'') (mkLuaInline ''hl.dsp.exec_cmd("rbw-bemenu")'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + X"'') (mkLuaInline ''hl.dsp.exec_cmd("hyprlock")'') ]; }

            # Move focus
            { _args = [ (mkLuaInline ''mod .. " + L"'') (mkLuaInline ''hl.dsp.focus({ direction = "right" })'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + H"'') (mkLuaInline ''hl.dsp.focus({ direction = "left" })'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + K"'') (mkLuaInline ''hl.dsp.focus({ direction = "up" })'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + J"'') (mkLuaInline ''hl.dsp.focus({ direction = "down" })'') ]; }

            # Move windows
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + L"'') (mkLuaInline ''hl.dsp.window.move({ direction = "right" })'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + H"'') (mkLuaInline ''hl.dsp.window.move({ direction = "left" })'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + K"'') (mkLuaInline ''hl.dsp.window.move({ direction = "up" })'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + J"'') (mkLuaInline ''hl.dsp.window.move({ direction = "down" })'') ]; }

            # Switch workspaces with mainMod + [0-9]
            { _args = [ (mkLuaInline ''mod .. " + 1"'') (mkLuaInline "hl.dsp.focus({ workspace = 1 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 2"'') (mkLuaInline "hl.dsp.focus({ workspace = 2 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 3"'') (mkLuaInline "hl.dsp.focus({ workspace = 3 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 4"'') (mkLuaInline "hl.dsp.focus({ workspace = 4 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 5"'') (mkLuaInline "hl.dsp.focus({ workspace = 5 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 6"'') (mkLuaInline "hl.dsp.focus({ workspace = 6 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 7"'') (mkLuaInline "hl.dsp.focus({ workspace = 7 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 8"'') (mkLuaInline "hl.dsp.focus({ workspace = 8 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 9"'') (mkLuaInline "hl.dsp.focus({ workspace = 9 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + 0"'') (mkLuaInline "hl.dsp.focus({ workspace = 10 })") ]; }

            # Move active window to workspace without following (movetoworkspacesilent)
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 1"'') (mkLuaInline "hl.dsp.window.move({ workspace = 1, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 2"'') (mkLuaInline "hl.dsp.window.move({ workspace = 2, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 3"'') (mkLuaInline "hl.dsp.window.move({ workspace = 3, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 4"'') (mkLuaInline "hl.dsp.window.move({ workspace = 4, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 5"'') (mkLuaInline "hl.dsp.window.move({ workspace = 5, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 6"'') (mkLuaInline "hl.dsp.window.move({ workspace = 6, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 7"'') (mkLuaInline "hl.dsp.window.move({ workspace = 7, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 8"'') (mkLuaInline "hl.dsp.window.move({ workspace = 8, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 9"'') (mkLuaInline "hl.dsp.window.move({ workspace = 9, follow = false })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + 0"'') (mkLuaInline "hl.dsp.window.move({ workspace = 10, follow = false })") ]; }

            # Move active window to workspace and follow (movetoworkspace)
            { _args = [ (mkLuaInline ''mod .. " + ALT + 1"'') (mkLuaInline "hl.dsp.window.move({ workspace = 1 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 2"'') (mkLuaInline "hl.dsp.window.move({ workspace = 2 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 3"'') (mkLuaInline "hl.dsp.window.move({ workspace = 3 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 4"'') (mkLuaInline "hl.dsp.window.move({ workspace = 4 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 5"'') (mkLuaInline "hl.dsp.window.move({ workspace = 5 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 6"'') (mkLuaInline "hl.dsp.window.move({ workspace = 6 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 7"'') (mkLuaInline "hl.dsp.window.move({ workspace = 7 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 8"'') (mkLuaInline "hl.dsp.window.move({ workspace = 8 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 9"'') (mkLuaInline "hl.dsp.window.move({ workspace = 9 })") ]; }
            { _args = [ (mkLuaInline ''mod .. " + ALT + 0"'') (mkLuaInline "hl.dsp.window.move({ workspace = 10 })") ]; }

            # Return to previous workspace
            { _args = [ (mkLuaInline ''mod .. " + Tab"'') (mkLuaInline ''hl.dsp.focus({ workspace = "previous" })'') ]; }

            # Special workspace (scratchpad)
            { _args = [ (mkLuaInline ''mod .. " + S"'') (mkLuaInline ''hl.dsp.workspace.toggle_special("magic")'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + S"'') (mkLuaInline ''hl.dsp.window.move({ workspace = "special:magic" })'') ]; }

            # Scroll through workspaces with mainMod + scroll
            { _args = [ (mkLuaInline ''mod .. " + mouse_down"'') (mkLuaInline ''hl.dsp.focus({ workspace = "e-1" })'') ]; }
            { _args = [ (mkLuaInline ''mod .. " + mouse_up"'') (mkLuaInline ''hl.dsp.focus({ workspace = "e+1" })'') ]; }

            # Fullscreen
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + F"'') (mkLuaInline "hl.dsp.window.fullscreen()") ]; }

            # Groups (tabs)
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + T"'') (mkLuaInline "hl.dsp.group.toggle()") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + bracketleft"'') (mkLuaInline "hl.dsp.group.prev()") ]; }
            { _args = [ (mkLuaInline ''mod .. " + SHIFT + bracketright"'') (mkLuaInline "hl.dsp.group.next()") ]; }

            # Mouse binds (movewindow/resizewindow via mouse drag)
            { _args = [ (mkLuaInline ''mod .. " + mouse:272"'') (mkLuaInline "hl.dsp.window.drag()") { mouse = true; } ]; }
            { _args = [ (mkLuaInline ''mod .. " + mouse:273"'') (mkLuaInline "hl.dsp.window.resize()") { mouse = true; } ]; }

            # Media keys (locked = usable on lockscreen)
            { _args = [ "XF86AudioPlay" (mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'') { locked = true; } ]; }
            { _args = [ "XF86AudioStop" (mkLuaInline ''hl.dsp.exec_cmd("playerctl pause")'') { locked = true; } ]; }
            { _args = [ "XF86AudioPause" (mkLuaInline ''hl.dsp.exec_cmd("playerctl pause")'') { locked = true; } ]; }
            { _args = [ "XF86AudioPrev" (mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'') { locked = true; } ]; }
            { _args = [ "XF86AudioNext" (mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'') { locked = true; } ]; }
            { _args = [ "XF86AudioMicMute" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle")'') { locked = true; } ]; }
            { _args = [ "XF86AudioRaiseVolume" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%")'') { locked = true; } ]; }
            { _args = [ "XF86AudioLowerVolume" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%")'') { locked = true; } ]; }
            { _args = [ "XF86MonBrightnessDown" (mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%-")'') { locked = true; } ]; }
            { _args = [ "XF86MonBrightnessUp" (mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set +5%")'') { locked = true; } ]; }
          ];
        };
    };

    programs.zsh.profileExtra = ''
      [[ $(tty) == /dev/tty1 ]] && exec start-hyprland
    '';
  };
}
