{ pkgs, ... }:
let
  openspec = pkgs.writeShellApplication {
    name = "openspec";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      exec ${pkgs.nodejs}/bin/npx -y @fission-ai/openspec@0.16.0 "$@"
    '';
  };
in
{
  home.packages = [
    openspec
  ];
}
