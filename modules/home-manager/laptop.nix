{ pkgs, lib, osConfig, ... }:
{

  config = lib.mkIf osConfig.laptop.enable {
    networking.wireless = {
      iwd.enable = true;
    };

    services.thermald.enable = true;

    home.packages = with pkgs; [
      brightnessctl
    ];

  };
}

