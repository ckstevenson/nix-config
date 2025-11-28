{ pkgs, ... }:
let
  openspec = pkgs.writeShellApplication {
    name = "openspec";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      exec ${pkgs.nodejs}/bin/npx -y @fission-ai/openspec@0.9.2 "$@"
    '';
  };
in
{
  home.packages = [
    openspec
  ];
}
