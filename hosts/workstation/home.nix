{ pkgs, config, ... }:
{

  imports = [
    ../../modules/home-manager
  ];

  # Enable secure backup service with SOPS integration
  services.backupService.enable = false;

  # Configure SOPS for secrets management
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/backup/restic.yaml;
  };

  home = {
    packages = with pkgs; [
      lutris
      anki-bin
      task-master-ai
      alacritty
      awscli2
      clipboard-jh
      dbeaver-bin
      dotnet-sdk_8
      qmk
      dotnet-outdated
      jq
      bitwarden-desktop
      bitwarden-menu
      mermaid-cli
      mpv
      gh
      github-copilot-cli
      mariadb.client
      nodePackages.prettier
      wl-clipboard
      nodejs
      opentofu
      packer
      powershell
      postgresql
      rbw
      rclone
      redis
      slack
      spacectl
      speedtest-cli
      wget
      watch
      wordnet
      yt-dlp
      # Development and pre-commit tools
      pre-commit
      nixpkgs-fmt
      shellcheck
      detect-secrets
      volatility3
      wev
    ];

    sessionVariables = {
      TERMINAL = "alacritty";
      VIDEO = "mpv";
      PATH = "$PATH:/opt/homebrew/bin";
      EDITOR = "nvim";
    };

    shellAliases = {
      e = "nvim";
      gs = "git status";
      gpl = "git pull";
      gps = "git push";
      gd = "git diff";
      gco = "git checkout";
      gsw = "git switch";
      tf = "tofu";
      tfa = "tofu apply";
      tfd = "tofu destroy";
      tfi = "tofu init";
      tfp = "tofu plan";
      ll = "ls -l";
    };

    # The state version is required and should stay at the version you
    # originally installed.
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
