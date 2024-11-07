{ inputs, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./zsh.nix
    ./zoxide.nix
    ./direnv.nix
    ./firefox.nix
    ./rbw.nix
    ./rbw-choose.nix
  ];

  home.packages = with pkgs; [
    choose-gui
    alacritty
    dotnet-sdk_8
    awscli2
    bat
    dbeaver-bin
    dnsutils
    fd
    gh
    git
    glow
    htop
    jq
    mpv
    nix-index
    packer
    rbw
    restic
    ripgrep
    skhd
    slack
    sshfs
    tailscale
    tailscale
    terraform
    tree
    wget
    powershell
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";

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
    userEmail = "cameron.stevenson@kaleris.com";
    extraConfig = {
      push.autoSetupRemote = true;
      url = {
         "ssh://git@github.com/" = {
           insteadOf = "https://github.com/";
         };
      };
    };
  };

  home.sessionVariables = {
    BROWSER = "safari";
    TERMINAL = "alacritty";
    VIDEO = "mpv";
    PATH = "$PATH:/opt/homebrew/bin";
    EDITOR = "nvim";
  };
  home.shellAliases = {
      e = "nvim";
      gs = "git status";
      gpl = "git pull";
      gps = "git push";
      gd = "git diff";
      gco = "git checkout";
      gsw = "git switch";
      tf = "terraform";
      tfa = "terraform apply";
      tfd = "terraform destroy";
      tfi = "terraform init";
      tfp = "terraform plan";
      ll = "ls -l";
    };
}
