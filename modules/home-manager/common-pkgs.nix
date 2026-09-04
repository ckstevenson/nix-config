{ pkgs, ... }:
{
  # Packages common to all full-featured desktop/workstation hosts
  # (both mbp/darwin and workstation/NixOS).
  #
  # Criteria for inclusion: package must be present in BOTH hosts' package lists
  # and must build on both aarch64-darwin and x86_64-linux.
  #
  # Leave host-unique packages (linux-only GUI apps, darwin-only tools, etc.)
  # in their respective host home.nix files.
  home.packages = with pkgs; [
    anki-bin
    awscli2
    clipboard-jh
    detect-secrets
    gh
    jq
    mariadb.client
    mpv
    nixpkgs-fmt
    nodejs
    opentofu
    packer
    postgresql
    powershell
    pre-commit
    prettier
    rbw
    rclone
    redis
    shellcheck
    slack
    spacectl
    speedtest-cli
    watch
    wget
    wordnet
    yt-dlp
  ];
}
