{ config, lib, osConfig, ... }: {
  config = lib.mkIf osConfig.desktop.enable {
    programs.bemenu = {
      enable = true;
      settings = with config.colorScheme.palette; {
        prompt = "open";
        ignorecase = true;
        fn = "14";
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
