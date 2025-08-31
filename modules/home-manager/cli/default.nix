{ osConfig, pkgs, ... }: {
  imports = [
    ./lf.nix
    ./rbw.nix
    ./zsh.nix
    ./zoxide.nix
    ./nixvim.nix
    ./direnv.nix
  ];

  home = {
    shellAliases = {
      e = "nvim";
      gs = "git status";
      gpl = "git pull";
      gps = "git push";
      gd = "git diff";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "$EDITOR";
    };

    username = osConfig.username;

    homeDirectory = osConfig.homeDirectory;

    packages = with pkgs; [
      bat
      dnsutils
      fd
      git
      glow
      htop
      nix-index
      pciutils
      restic
      ripgrep
      smartmontools
      tmux-sessionizer
      sshfs
      tailscale
      tree
      #usbutils
      #xdg-utils
    ];
  };
    programs.tmux = {
      enable = true;
      #plugins = with pkgs.tmuxPlugins; [
      #  tmux-sessionizer
      #];
      baseIndex = 1;
      mouse = true;
      keyMode = "vi";
      terminal = "xterm-256color";
      historyLimit = 10000;
      plugins = with pkgs.tmuxPlugins; [
        continuum
      ];
    };


  #xdg = {
  #  enable = true;
  #  mimeApps = {
  #    enable = true;
  #    defaultApplications = {
  #      "text/plain" = [ "nvim.desktop" ];
  #    };
  #  };
  #};

  #programs.git = {
  #  enable = true;
  #  userName  = "Cameron Stevenson";
  #  userEmail = "cksteve@protonmail.com";
  #};
}
