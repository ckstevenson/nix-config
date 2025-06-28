{ ... }:
{
  services = {
    yabai = {
      enable = true;
      config = {
        layout = "bsp";
        window_placement = "second_child";
        mouse_follows_focus = "on";
        focus_follows_mouse = "autoraise";
        top_padding = 5;
        bottom_padding = 5;
        left_padding = 5;
        right_padding = 5;
        window_gap = 5;
      };
      extraConfig = ''
        #for _ in {1..9}; do
        #  yabai -m space --create
        #done

        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        sudo yabai --load-sa

        yabai -m rule --add app="^System Settings$"    manage=off
        yabai -m rule --add app="^System Information$" manage=off
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add title="Preferences$"       manage=off
        yabai -m rule --add title="Settings$"          manage=off
        yabai -m rule --add title="^Notes$" scratchpad=Notes grid=11:11:1:1:9:9
      '';
    };
  };
}
