{ config, osConfig, pkgs, inputs, lib, ... }: {
  imports = [
    ./lf.nix
    ./rbw.nix
    ./tmux.nix
    ./zsh.nix
    ./zoxide.nix
    ./nixvim.nix
    ./direnv.nix
  ] ++ lib.optionals (osConfig.opencode.enable or true) [
    "${inputs.opencode-config}"
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
      sshfs
      tailscale
      tree
      #usbutils
      #xdg-utils
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
