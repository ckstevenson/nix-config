{ config, lib, ... }:
{
  options.gaming.enable = lib.mkEnableOption "gaming support";

  config = lib.mkIf config.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    programs.gamemode.enable = true;

    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
    };
  };
}
