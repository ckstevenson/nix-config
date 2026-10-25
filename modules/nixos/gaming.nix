{ config, lib, ... }:
{
  options.gaming = {
    enable = lib.mkEnableOption "gaming support";

    skyrimTogether.enable = lib.mkEnableOption "Skyrim Together host networking";
    sunshine.enable = lib.mkEnableOption "Sunshine game streaming host";
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


    services.sunshine = lib.mkMerge [
      {
        autoStart = lib.mkDefault config.gaming.sunshine.enable;
      }
      (lib.mkIf config.gaming.sunshine.enable {
        enable = true;
        capSysAdmin = true;
        openFirewall = true;
        settings.capture = "wlr";
      })
    ];
  };
}
