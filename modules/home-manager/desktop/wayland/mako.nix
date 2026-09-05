{ config, lib, osConfig, ... }: {
  config = lib.mkIf osConfig.desktop.enable {
    services.mako = with config.colorScheme.palette; {
      enable = true;
      settings = {
        background-color = "#${base01}";
        border-color = "#${base0E}";
        border-radius = 5;
        border-size = 2;
        default-timeout = 3000;
        text-color = "#${base04}";
        layer = "overlay";
      };
    };
  };
}
