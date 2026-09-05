{ inputs, ... }:
let
  # upstream flakes migrated output name from `homeManagerModules` -> `homeModules`.
  # Accept either name to stay compatible across different input revisions.
  nixColorsModule = if builtins.hasAttr "homeModules" inputs.nix-colors then inputs.nix-colors.homeModules.default else inputs.nix-colors.homeManagerModules.default;
  nixvimModule = if builtins.hasAttr "homeModules" inputs.nixvim then inputs.nixvim.homeModules.nixvim else inputs.nixvim.homeManagerModules.nixvim;
  sopsModule = if builtins.hasAttr "homeModules" inputs.sops-nix then inputs.sops-nix.homeModules.sops else inputs.sops-nix.homeManagerModules.sops;
in
{
  imports = [
    ./cli
    ./pkgs
    ./services
    ./desktop
    ./gaming.nix
    nixColorsModule
    nixvimModule
    sopsModule
  ];

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
