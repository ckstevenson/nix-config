{ config, lib, ... }:
{
  options.gaming = {
    enable = lib.mkEnableOption "gaming support";

    skyrimTogether.enable = lib.mkEnableOption "Skyrim Together host networking";
  };

  config = lib.mkIf config.gaming.enable {
    networking.firewall.allowedUDPPorts = lib.mkIf config.gaming.skyrimTogether.enable [
      10578
    ];

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
      capSysAdmin = true;
      openFirewall = true;

      settings = {
        capture = "wlr";
      };
    };
  };
}
