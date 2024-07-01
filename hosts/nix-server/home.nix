{ pkgs, ... }:
{

  imports = [
    ../../modules/home-manager
  ];

  home.packages = with pkgs; [
    fd
    git
    nix-index
    ripgrep
    tree
    xdg-utils
    sops
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
