{ config, lib, osConfig, ... }: {
  options = {
    bemenuFontSize = lib.mkOption {
      type = lib.types.str;
      default = "16";
    };
  };

  config = lib.mkIf osConfig.desktop.enable {
    programs.bemenu = {
      enable = true;
      settings = with config.colorScheme.palette; {
        prompt = "open";
        ignorecase = true;
        fn = config.bemenuFontSize;
        fb = "#${base00}";
        ff = "#${base0F}";
        nb = "#${base00}";
        tb = "#${base00}";
        tf = "#${base0E}";
        hb = "#${base00}";
        hf = "#${base0E}";
        ab = "#${base00}";
        cf = "#${base0E}";
      };
    };
  };
}
