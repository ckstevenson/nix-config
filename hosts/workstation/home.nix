{ config, ... }:
{

  imports = [
    ../../modules/home-manager
  ];

  # Enable secure backup service with SOPS integration
  services.backupService.enable = true;
  
  # Configure SOPS for secrets management
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/backup/restic.yaml;
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
