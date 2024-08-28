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
          "text/html" = [ "firefox.desktop" ];
          "application/x-extension-htm" = [ "firefox.desktop" ];
          "application/x-extension-html" = [ "firefox.desktop" ];
          "application/x-extension-shtml" = [ "firefox.desktop" ];
          "application/xhtml+xml" = [ "firefox.desktop" ];
          "application/x-extension-xhtml" = [ "firefox.desktop" ];
          "application/x-extension-xht" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/ftp" = [ "firefox.desktop" ];
          "x-scheme-handler/chrome" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];
          "x-scheme-handler/mailto" = [ "firefox.desktop" ];
          "x-scheme-handler/webcal" = [ "firefox.desktop" ];
          "default-web-browser" = [ "firefox.desktop" ];
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
