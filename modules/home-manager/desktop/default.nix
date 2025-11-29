{ pkgs, lib, osConfig, ... }: {

  imports = [
    ./alacritty.nix
    ./bemenu.nix
    ./firefox.nix
    ./gtk.nix
    ./zen-browser.nix
    ./zathura.nix
    ./wayland
  ];

  config = lib.mkIf osConfig.desktop.enable {
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
      sxiv
    ];

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      BROWSER = "zen";
      TERMINAL = "alacritty";
      IMAGE = "sxiv";
      VIDEO = "mpv";
    };
  };

}
