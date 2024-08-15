{ config, lib, osConfig, pkgs, ... }: {

  config = lib.mkIf osConfig.desktop.enable {
    config = lib.mkIf osConfig.globalProtect.enable {
      home.packages = with pkgs; [
        globalprotect-openconnect
      ];
    };
  };
}
