{ pkgs, ... }:
{

  imports = [
    ../../modules/home-manager
  ];

  home.packages = with pkgs; [
    intel-gpu-tools
    sops
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
