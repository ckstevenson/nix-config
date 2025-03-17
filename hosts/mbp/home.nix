{ pkgs, ... }: {
  imports = [
    ../../modules/home-manager/cli
    ./firefox.nix
    ./rbw-choose.nix
    ./git.nix
    ./alacritty.nix
  ];

  home = {
    packages = with pkgs; [
      alacritty
      awscli2
      #azure-cli
      jetbrains.webstorm
      clipboard-jh
      dbeaver-bin
      dotnet-sdk_8
      jq
      mpv
      mysql-client
      nodePackages.prettier
      nodejs
      opentofu
      packer
      powershell
      postgresql
      rbw
      redis
      slack
      spacectl
      sshfs
      terraform
      tmux
      wget
    ];

    sessionVariables = {
      BROWSER = "safari";
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
