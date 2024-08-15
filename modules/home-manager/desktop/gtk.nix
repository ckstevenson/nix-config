{ pkgs, config, lib, osConfig, ... }: {
  options = {
    gtkFontSize = lib.mkOption {
      type = lib.types.int;
      default = 14;
    };
  };

  config = lib.mkIf osConfig.desktop.enable {
    home.packages = with pkgs; [
      adwaita-qt
    ];

    qt.enable = true;
    qt.platformTheme.name = "gtk3";
    qt.style.package = pkgs.adwaita-qt;
    qt.style.name = "adwaita";

    gtk = {
      enable = true;
      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Violet-Darkest";
      };
      cursorTheme = {
        package = pkgs.gnome.adwaita-icon-theme;
        name = "Adwaita";
      };
      iconTheme = {
        package = pkgs.flat-remix-icon-theme;
        name = "Flat-Remix-Violet-Dark";
      };

      font = {
        name = "Sans";
        size = config.gtkFontSize;
      };
    };
  };
}
