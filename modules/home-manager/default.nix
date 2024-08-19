{ inputs, pkgs, ... }:
{
  imports = [
    ./cli
    ./pkgs
    ./services
    ./desktop
    inputs.nix-colors.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
  ];

  home = {
    packages = with pkgs; [
      fd
      git
      nix-index
      ripgrep
      sshfs
      tree
      restic
      tailscale
      smartmontools
      usbutils
      pciutils
    ];

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

    username = "cameron";
    homeDirectory = "/home/cameron";
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "nvim.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "image/*" = [ "sxiv.desktop" ];
        "video/png" = [ "mpv.desktop" ];
        "video/jpg" = [ "mpv.desktop" ];
        "video/*" = [ "mpv.desktop" ];
      };
    };
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

  programs.git = {
    enable = true;
    userName  = "Cameron Stevenson";
    userEmail = "cksteve@protonmail.com";
  };

}
