{ inputs, ... }:
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

  xdg.enable = true;

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
      base0C = "#3ddbd9";
      base09 = "#78a9ff";
      base0A = "#ee5396";
      base0D = "#33b1ff";
      base08 = "#ff7eb6";
      base0B = "#42be65";
      base0E = "#be95ff";
      base0F = "#82cfff";
    };
  };
}
