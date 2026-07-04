{ pkgs, config, ... }:
{

  imports = [
    ../../modules/home-manager
  ];

  # Enable secure backup service with SOPS integration
  services.backupService.enable = false;

  # Configure opencode
  programs.opencode = {
    enable = true;
  };

  # Configure SOPS for secrets management
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/backup/restic.yaml;
  };

  # Enable MangoHud for FPS overlay
  #programs.mangohud = {
  #  enable = true;
  #  enableSessionWide = true; # Enable for all applications
  #  settings = {
  #    fps = true;
  #    frame_timing = true;
  #    gpu_stats = true;
  #    cpu_stats = true;
  #    vulkan_driver = true;
  #    gamemode = true;
  #  };
  #};

  home = {
    packages = with pkgs; [
      alacritty
      anki-bin
      awscli2
      bluetuith
      bitwarden-menu
      clipboard-jh
      discord
      gh
      goverlay
      vkbasalt
      jq
      lutris
      mariadb.client
      mpv
      prettier
      nodejs
      opentofu
      packer
      piper
      postgresql
      powershell
      qmk
      rbw
      rclone
      redis
      slack
      spacectl
      speedtest-cli
      watch
      wget
      wl-clipboard
      wordnet
      yt-dlp
      # Development and pre-commit tools
      pre-commit
      nixpkgs-fmt
      shellcheck
      detect-secrets
      wev
      via
    ];

    sessionVariables = {
      TERMINAL = "alacritty";
      VIDEO = "mpv";
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
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
