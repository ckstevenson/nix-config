{ pkgs, ... }:
{
  services = {
    yabai = {
      enable = true;
      config = {
        layout = "bsp";
        #package = pkgs.yabai.overrideAttrs (old: {
        #  src = pkgs.fetchFromGitHub {
        #    owner = "koekeishiya";
        #    repo = "yabai";
        #    rev = "master";  # or specific commit hash
        #    sha256 = "sha256-DTwRQRiEJUBAp97XiSy4skZuNkVpE2YMXRazlODXf2A=";
        #  };
        #  dontBuild = false;
        #  nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.xxd ];
        #  postPatch = (old.postPatch or "") + ''
        #    # Remove arm64e architecture to fix build issues
        #    substituteInPlace makefile \
        #      --replace-fail "-arch arm64e" "" \
        #      --replace-fail "-arch arm64" ""
        #  '';
        #  #buildPhase = "make install";
        #});
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
        for _ in {1..9}; do
          yabai -m space --create
        done

        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        sudo yabai --load-sa

        yabai -m rule --add app="^System Settings$"    manage=off
        yabai -m rule --add app="^System Information$" manage=off
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add title="Preferences$"       manage=off
        yabai -m rule --add title="Settings$"          manage=off
        yabai -m rule --add title="^Notes$" scratchpad=Notes grid=11:11:1:1:9:9
        yabai -m rule --add app="^1Password$"    manage=off
        yabai -m rule --add app="^Slack$"       space=10
        yabai -m rule --add app="^Teams$"       space=9
      '';
    };
  };
}
