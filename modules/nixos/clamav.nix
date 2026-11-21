{ config, lib, pkgs, ... }:
{
  options.security.clamav.enable = lib.mkEnableOption "ClamAV antivirus scanning";

  config = lib.mkIf config.security.clamav.enable {
    environment.systemPackages = [ pkgs.clamav ];

    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
  };
}
