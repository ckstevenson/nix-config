{ pkgs, ... }:
let
  notesToggle = pkgs.writeShellScript "notes-toggle" ''
    notes_window=$(${pkgs.yabai}/bin/yabai -m query --windows | ${pkgs.jq}/bin/jq -r 'map(select(.app == "alacritty" and .title == "Notes")) | .[0].id // empty')

    if [ -z "$notes_window" ]; then
      /etc/profiles/per-user/cameronstevenson/bin/alacritty -o window.dynamic_title=false --title Notes -e nvim /Users/cameronstevenson/Documents/Notes/
    elif ${pkgs.yabai}/bin/yabai -m query --windows --window "$notes_window" | ${pkgs.jq}/bin/jq -e '."is-minimized"' >/dev/null; then
      ${pkgs.yabai}/bin/yabai -m window --focus "$notes_window"
    else
      if ${pkgs.yabai}/bin/yabai -m query --windows --window "$notes_window" | ${pkgs.jq}/bin/jq -e '."has-focus"' >/dev/null; then
        ${pkgs.yabai}/bin/yabai -m window "$notes_window" --minimize
      else
        ${pkgs.yabai}/bin/yabai -m window --focus "$notes_window"
      fi
    fi
  '';
in
{
  services.skhd = {
    enable = true;
    skhdConfig = ''
            # Open Terminal
            cmd - return : /etc/profiles/per-user/cameronstevenson/bin/alacritty
            # Minimize/restore Notes; launch it only when not yet created.
            cmd + shift - n : ${notesToggle}
            cmd - d : ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ /Users/cameronstevenson/Applications/Home\ Manager\ Apps/  /System/Library/CoreServices/ | grep '\.app$' | sed 's/\.app$//g' | choose | xargs -I {} open -a "{}.app"
            cmd - p : rbw-choose

            # use ctrl key as cmd for common actions
      #      cmd - space [
      #        * : skhd -k "ctrl - space"
      #        "alacritty" ~
      #        "terminal" ~
      #      ]

            ctrl - a [
              * : skhd -k "cmd - a"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - c [
              * : skhd -k "cmd - c"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - f [
              * : skhd -k "cmd - f"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - g [
              * : skhd -k "cmd - g"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - k [
              * : skhd -k "cmd - k"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - l [
              * : skhd -k "cmd - l"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - n [
              * : skhd -k "cmd - n"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - r [
              * : skhd -k "cmd - r"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - t [
              * : skhd -k "cmd - t"
              "alacritty" ~
              "terminal" ~
            ]

            shift + ctrl - t [
              * : skhd -k "shift + cmd - t"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - v [
              * : skhd -k "cmd - v"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - w [
              * : skhd -k "cmd - w"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - x [
              * : skhd -k "cmd - x"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - z [
              * : skhd -k "cmd - z"
              "alacritty" ~
              "terminal" ~
            ]

            ctrl - backspace [
              * : skhd -k "alt - backspace"
              "alacritty" ~
              "terminal" ~
            ]

            # focus window
            cmd - h : yabai -m window --focus west || yabai -m display --focus west
            cmd - j : yabai -m window --focus south || yabai -m display --focus south
            cmd - k : yabai -m window --focus north || yabai -m display --focus north
            cmd - l : yabai -m window --focus east || yabai -m display --focus east

            # move managed window
            shift + cmd - h : yabai -m window --swap west
            shift + cmd - j : yabai -m window --swap south
            shift + cmd - k : yabai -m window --swap north
            shift + cmd - l : yabai -m window --swap east

            cmd - tab : yabai -m space --focus recent
            cmd + alt - p : yabai -m space --focus prev
            cmd + alt - n : yabai -m space --focus next
            # Focus space, creating it if it doesn't exist
            cmd - 1 : yabai -m space --focus 1 || (yabai -m space --create && yabai -m space --focus 1)
            cmd - 2 : yabai -m space --focus 2 || (while [ $(yabai -m query --spaces | jq 'length') -lt 2 ]; do yabai -m space --create; done && yabai -m space --focus 2)
            cmd - 3 : yabai -m space --focus 3 || (while [ $(yabai -m query --spaces | jq 'length') -lt 3 ]; do yabai -m space --create; done && yabai -m space --focus 3)
            cmd - 4 : yabai -m space --focus 4 || (while [ $(yabai -m query --spaces | jq 'length') -lt 4 ]; do yabai -m space --create; done && yabai -m space --focus 4)
            cmd - 5 : yabai -m space --focus 5 || (while [ $(yabai -m query --spaces | jq 'length') -lt 5 ]; do yabai -m space --create; done && yabai -m space --focus 5)
            cmd - 6 : yabai -m space --focus 6 || (while [ $(yabai -m query --spaces | jq 'length') -lt 6 ]; do yabai -m space --create; done && yabai -m space --focus 6)
            cmd - 7 : yabai -m space --focus 7 || (while [ $(yabai -m query --spaces | jq 'length') -lt 7 ]; do yabai -m space --create; done && yabai -m space --focus 7)
            cmd - 8 : yabai -m space --focus 8 || (while [ $(yabai -m query --spaces | jq 'length') -lt 8 ]; do yabai -m space --create; done && yabai -m space --focus 8)
            cmd - 9 : yabai -m space --focus 9 || (while [ $(yabai -m query --spaces | jq 'length') -lt 9 ]; do yabai -m space --create; done && yabai -m space --focus 9)
            cmd - 0 : yabai -m space --focus 10 || (while [ $(yabai -m query --spaces | jq 'length') -lt 10 ]; do yabai -m space --create; done && yabai -m space --focus 10)

            cmd + alt - h : yabai -m display --focus west
            cmd + alt - l : yabai -m display --focus east

            # move window to space (creating space if needed)
            shift + cmd - 1 : yabai -m window --space 1 || (yabai -m space --create && yabai -m window --space 1)
            shift + cmd - 2 : yabai -m window --space 2 || (while [ $(yabai -m query --spaces | jq 'length') -lt 2 ]; do yabai -m space --create; done && yabai -m window --space 2)
            shift + cmd - 3 : yabai -m window --space 3 || (while [ $(yabai -m query --spaces | jq 'length') -lt 3 ]; do yabai -m space --create; done && yabai -m window --space 3)
            shift + cmd - 4 : yabai -m window --space 4 || (while [ $(yabai -m query --spaces | jq 'length') -lt 4 ]; do yabai -m space --create; done && yabai -m window --space 4)
            shift + cmd - 5 : yabai -m window --space 5 || (while [ $(yabai -m query --spaces | jq 'length') -lt 5 ]; do yabai -m space --create; done && yabai -m window --space 5)
            shift + cmd - 6 : yabai -m window --space 6 || (while [ $(yabai -m query --spaces | jq 'length') -lt 6 ]; do yabai -m space --create; done && yabai -m window --space 6)
            shift + cmd - 7 : yabai -m window --space 7 || (while [ $(yabai -m query --spaces | jq 'length') -lt 7 ]; do yabai -m space --create; done && yabai -m window --space 7)
            shift + cmd - 8 : yabai -m window --space 8 || (while [ $(yabai -m query --spaces | jq 'length') -lt 8 ]; do yabai -m space --create; done && yabai -m window --space 8)
            shift + cmd - 9 : yabai -m window --space 9 || (while [ $(yabai -m query --spaces | jq 'length') -lt 9 ]; do yabai -m space --create; done && yabai -m window --space 9)
            shift + cmd - 0 : yabai -m window --space 10 || (while [ $(yabai -m query --spaces | jq 'length') -lt 10 ]; do yabai -m space --create; done && yabai -m window --space 10)

            # move window to space and follow (creating space if needed)
            alt + cmd - 1 : yabai -m window --space 1 --focus || (yabai -m space --create && yabai -m window --space 1 --focus)
            alt + cmd - 2 : yabai -m window --space 2 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 2 ]; do yabai -m space --create; done && yabai -m window --space 2 --focus)
            alt + cmd - 3 : yabai -m window --space 3 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 3 ]; do yabai -m space --create; done && yabai -m window --space 3 --focus)
            alt + cmd - 4 : yabai -m window --space 4 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 4 ]; do yabai -m space --create; done && yabai -m window --space 4 --focus)
            alt + cmd - 5 : yabai -m window --space 5 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 5 ]; do yabai -m space --create; done && yabai -m window --space 5 --focus)
            alt + cmd - 6 : yabai -m window --space 6 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 6 ]; do yabai -m space --create; done && yabai -m window --space 6 --focus)
            alt + cmd - 7 : yabai -m window --space 7 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 7 ]; do yabai -m space --create; done && yabai -m window --space 7 --focus)
            alt + cmd - 8 : yabai -m window --space 8 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 8 ]; do yabai -m space --create; done && yabai -m window --space 8 --focus)
            alt + cmd - 9 : yabai -m window --space 9 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 9 ]; do yabai -m space --create; done && yabai -m window --space 9 --focus)
            alt + cmd - 0 : yabai -m window --space 10 --focus || (while [ $(yabai -m query --spaces | jq 'length') -lt 10 ]; do yabai -m space --create; done && yabai -m window --space 10 --focus)

            shift + cmd - f : yabai -m window --toggle zoom-fullscreen
            shift + cmd - o : yabai -m window --toggle float

            shift + cmd - b : yabai -m space --balance
            shift + cmd - c : yabai -m space --create
            shift + cmd - x : yabai -m space --destroy
            cmd - w : open /Users/cameronstevenson/Applications/Firefox.app
            #cmd - d : open /System/Library/CoreServices/Spotlight.app
            cmd + shift - q : yabai -m window --close

    '';
  };
}
