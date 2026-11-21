{ config, lib, ... }:
{
  options.performance.enable = lib.mkEnableOption "workstation performance tuning";

  config = lib.mkIf config.performance.enable {
    boot.kernelModules = [ "ntsync" ];

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      settings.auto-optimise-store = true;
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };
  };
}
