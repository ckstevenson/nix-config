{ pkgs, config, ... }:
{

  imports = [
    ../../modules/home-manager
  ];

  gaming.enable = true;

  # Keep automatic backups disabled on workstation.
  services.backupService.enable = false;

  # Configure opencode
  programs.opencode = {
    enable = true;
    settings = {
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options = {
            baseURL = "http://localhost:11434/v1";
          };
          models = {
            "qwen2.5-coder:7b" = {
              name = "Qwen2.5 Coder 7B (local)";
              tools = true;
            };
          };
        };
      };
    };
  };

  # Configure SOPS for secrets management
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/backup/restic.yaml;
  };

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
      jq
      mpv
      #mullvad-vpn
      piper
      rbw
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
