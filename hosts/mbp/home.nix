{ config, pkgs, ... }: {
  imports = [
    ../../modules/home-manager/cli
    ../../modules/home-manager/pkgs
    ../../modules/home-manager/desktop/alacritty.nix
    ../../modules/home-manager/desktop/firefox.nix
    ../../modules/home-manager/desktop/sketchybar.nix
    ../../modules/home-manager/darwin-secure-backup.nix
    ../../modules/home-manager/pkgs/sqlpackage.nix
    ./rbw-choose.nix
    ./git.nix
    ./jankyborders.nix
    ./nuget-credprovider.nix
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

  services.sketchybar = {
    enable = true;
  };

  home = {
    packages = with pkgs; [
      anki-bin
      alacritty
      #mermaid-cli
      awscli2
      (azure-cli.withExtensions [ azure-cli.extensions.azure-devops ])
      jetbrains.webstorm
      freerdp
      clipboard-jh
      github-copilot-cli
      # github-desktop removed: pulls Linux-only libselinux/libsepol → fails on darwin
      # github-desktop
      dbeaver-bin
      dotnet-sdk_8
      qmk
      jq
      # bitwarden desktop build removed — upstream build requires complex
      # native toolchain and currently fails during linking on darwin.
      # Leave removal until we have fixed derivation or cached binary.
      mpv
      gh
      herdr
      mariadb.client
      prettier
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
      # sweethome3d temporarily disabled: resolves to attrset, not plain derivation
      # see: https://github.com/NixOS/nixpkgs/issues/ (investigate later)
      # sweethome3d
      # librecad
      maccy
      terraform-docs
      sqlcmd
      speedtest-cli
      wget
      watch
      wordnet
      yt-dlp
      utm
      # vscode removed due to build issues; use vscodium instead
      # vscode
      vscodium
      #vscode-utils
      # Development and pre-commit tools
      pre-commit
      nixpkgs-fmt
      shellcheck
      detect-secrets
      volatility3
      # Migrated from Homebrew
      nixos-rebuild
      #_1password-gui
      #_1password-cli
    ];

    sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "alacritty";
      VIDEO = "mpv";
      PATH = "$PATH:/opt/homebrew/bin";
      EDITOR = "nvim";
      # Homebrew: Disable environment hints
      HOMEBREW_NO_ENV_HINTS = "1";
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

    # Brew 6.0.x requires explicit tap trust. Declare trusted taps here so a
    # fresh install doesn't need a manual `brew trust` step.
    # Trust file location: $HOMEBREW_USER_CONFIG_HOME/trust.json (~/.homebrew/trust.json)
    file.".homebrew/trust.json".text = builtins.toJSON {
      trustedtaps = [
        "osx-cross/arm"
        "osx-cross/avr"
        "qmk/qmk"
      ];
    };

    # The state version is required and should stay at the version you
    # originally installed.
    stateVersion = "26.05";
    # Home Manager and system now both use unstable nixpkgs; enable release check.
    # (stateVersion remains at 26.05)
  };

  colorScheme = {
    slug = "carbonfox-fixed";
    name = "Carbonfox Fixed";
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
