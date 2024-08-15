{ config, lib, ... }:
{
  options = {
    globalProtect.enable = lib.mkEnableOption "enables desktop applications";
  };

  config = lib.mkIf config.globalProtect.enable {
    services.globalprotect.enable = true;
  };
}

