{ config, lib, osConfig, ... }: {
  config = lib.mkIf osConfig.desktop.enable {
    services.mako = with config.colorScheme.palette; {
      enable = true;
      backgroundColor = "#${base01}";
      borderColor = "#${base0E}";
      borderRadius = 5;
      borderSize = 2;
      textColor = "#${base04}";
      layer = "overlay";
    };
  };
}
