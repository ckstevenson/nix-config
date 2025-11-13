{ config, pkgs, ... }: {
  imports = [
    ../../modules/home-manager/cli
    ../../modules/home-manager/darwin-secure-backup.nix
    ./firefox.nix
    ./rbw-choose.nix
    ./git.nix
    ./alacritty.nix
  ];

  # SOPS configuration for secrets management
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
  };

  # Enable secure macOS backup service with SOPS integration
  services.darwinBackupService = {
    enable = true;
    interval = 86400; # 24 hours
  };

  programs.opencode = {
    enable = true;
  };

  home = {
    packages = with pkgs; [
      anki-bin
      task-master-ai
      alacritty
      awscli2
      #azure-cli
      jetbrains.webstorm
      teams
      clipboard-jh
      dbeaver-bin
      dotnet-sdk_8
      qmk
      dotnet-outdated
      jq
      #bitwarden-desktop
      #bitwarden-menu
      mermaid-cli
      mpv
      gh
      github-copilot-cli
      mariadb.client
      nodePackages.prettier
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
      sshfs
      maccy
      terraform-docs
      sqlcmd
      speedtest-cli
      wget
      watch
      wordnet
      yt-dlp
      utm
      vscode
      vscodium
      #vscode-utils
      # Development and pre-commit tools
      pre-commit
      nixpkgs-fmt
      shellcheck
      detect-secrets
      volatility3
    ];

    sessionVariables = {
      BROWSER = "zen";
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

  colorScheme = {
    slug = "oxocarbon-fixed";
    name = "Oxocarbon Fixed";
    author = "Cameron Stevenson";
    palette = {
      base00 = "#161616";
      base01 = "#262626";
      base02 = "#393939";
      base03 = "#525252";
      base04 = "#dde1e6";
      base05 = "#f2f4f8";
      base06 = "#ffffff";
      base07 = "#08bdba";
      base08 = "#ff7eb6";
      base09 = "#78a9ff";
      base0A = "#FFCB6B";
      base0B = "#42be65";
      base0C = "#3ddbd9";
      base0D = "#33b1ff";
      base0E = "#be95ff";
      base0F = "#82cfff";
    };
  };
}
