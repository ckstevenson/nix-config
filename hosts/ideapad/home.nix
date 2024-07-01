{ pkgs, ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
  };

  imports = [
    ./vars.nix
    ../../modules/home-manager
  ];

  home.packages = with pkgs; [
    bambu-studio
    brightnessctl
    dconf
    fd
    ferdium
    git
    mpv
    nix-index
    pcmanfm
    playerctl
    pulseaudio
    pulsemixer
    ripgrep
    signal-desktop
    slack
    slack-term
    sshfs
    sxiv
    teams-for-linux
    tree
    xdg-utils
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    #SUDO_ASKPASS = "${pkgs.bemenu} --prompt $1 --password --no-exec </dev/null";
    IMAGE = "sxiv";
    VIDEO = "mpv";
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
