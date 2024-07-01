{ config, inputs, lib, osConfig, pkgs, ... }:
{
  config = lib.mkIf osConfig.desktop.enable {
    programs.wpaperd = {
      enable = true;
      settings = {
        DP-1 = {
          path = "/home/cameron/Downloads/wp.webp";
        };
      };
    };
  };
}
