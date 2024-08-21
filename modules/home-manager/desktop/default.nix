{ config, pkgs, lib, osConfig, ... }: {

  imports = [
    ./alacritty.nix
    ./bemenu.nix
    ./firefox.nix
    ./gtk.nix
    ./zathura.nix
    ./wayland
    ./global-protect.nix
  ];

  config = lib.mkIf osConfig.desktop.enable {
    nixpkgs.config.allowUnfree = true;

    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
          "image/*" = [ "sxiv.desktop" ];
          "video/png" = [ "mpv.desktop" ];
          "video/jpg" = [ "mpv.desktop" ];
          "video/*" = [ "mpv.desktop" ];
        };
      };
    };

    home.packages = with pkgs; [
      bambu-studio
      chromium
      dconf
      gimp
      libreoffice
      mpv
      nextcloud-client
      playerctl
      pulseaudio
      pulsemixer
      signal-desktop
      slack
      sxiv
    ];

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      BROWSER = "firefox";
      TERMINAL = "alacritty";
      IMAGE = "sxiv";
      VIDEO = "mpv";
    };
  };

}
