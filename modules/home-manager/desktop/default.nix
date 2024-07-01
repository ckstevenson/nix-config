{ config, lib, ... }: {
#  options = {
#    # used in imported modules if dektop is enabled
#    desktop.enable = lib.mkEnableOption "enables desktop applications";
#  };

  imports = [
    ./alacritty.nix
    ./bemenu.nix
    ./firefox.nix
    ./gtk.nix
    ./zathura.nix
    ./wayland
  ];

  #config = {
  #  desktop.enable = true;
  #};
}
