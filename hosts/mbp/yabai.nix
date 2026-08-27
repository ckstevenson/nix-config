{
  services = {
    yabai = {
      enable = true;
      config = {
        layout = "bsp";
        window_placement = "second_child";
        mouse_follows_focus = "on";
        focus_follows_mouse = "autofocus";
        window_origin_display = "cursor";
        top_padding = 5;
        bottom_padding = 5;
        left_padding = 5;
        right_padding = 5;
        window_gap = 5;
        external_bar = "all:0:32";
      };
      extraConfig = ''
        # Load scripting addition on restart
        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        sudo yabai --load-sa

        # macOS owns space creation/removal when displays connect or disconnect.
        sketchybar --trigger space_change

        # SketchyBar integration - refresh spaces on changes
        yabai -m signal --add event=space_changed action="sketchybar --trigger space_change"
        yabai -m signal --add event=space_created action="sketchybar --trigger space_change"
        yabai -m signal --add event=space_destroyed action="sketchybar --trigger space_change"
        yabai -m signal --add event=window_focused action="sketchybar --trigger space_change"
        yabai -m signal --add event=window_created action="sketchybar --trigger space_change"
        yabai -m signal --add event=window_destroyed action="sketchybar --trigger space_change"
        yabai -m signal --add event=window_moved action="sketchybar --trigger space_change"

        # Application rules
        yabai -m rule --add app="^System Settings$"    manage=off
        yabai -m rule --add app="^System Information$" manage=off
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add title="Preferences$"       manage=off
        yabai -m rule --add title="Settings$"          manage=off
        yabai -m rule --add app="^alacritty$" title="^Notes$" manage=off grid=11:11:1:1:9:9
        yabai -m rule --add app="^1Password$"    manage=off
        yabai -m rule --add app="^Slack$"          space=10
        yabai -m rule --add app="^Microsoft Teams$" space=9

        # Move already-open communication apps after a yabai restart.
        yabai -m rule --apply app="^Slack$" space=10
        yabai -m rule --apply app="^Microsoft Teams$" space=9
      '';
    };
  };
}
