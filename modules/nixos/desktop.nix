{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.desktop.enable {
    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          #intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          libvdpau-va-gl
        ];
        enable32Bit = true;
      };

      cpu.intel.updateMicrocode = true;
    };

    # Styling
    fonts = {
      packages = with pkgs; [
        nerd-fonts.dejavu-sans-mono
      ];

      fontconfig = {
        defaultFonts = {
          monospace = [ "DejaVuSansM Nerd Font Mono" ];
          sansSerif = [ "DejaVuSansM Nerd Font" ];
          serif = [ "DejaVuSansM Nerd Font" ];
        };

        subpixel = {
          rgba = "rgb";
        };
      };
    };

    security.polkit.enable = true;

    xdg = {
      portal = {
        wlr.enable = true;
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
        ];
      };
    };

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true; # maybe not needed
    };

    services.resolved = {
      enable = true;
    };

    programs.hyprland.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
