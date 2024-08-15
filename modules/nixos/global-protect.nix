{ config, lib, ... }:
{
  options = {
    globalProtect.enable = lib.mkEnableOption "enables globalprotect";
  };

  config = lib.mkIf config.globalProtect.enable {
    services.globalprotect.enable = true;
  };
}

