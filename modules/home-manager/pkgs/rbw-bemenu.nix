{ pkgs, ... }:
let 
  rbw-bemenu = pkgs.writeShellApplication {
    name = "rbw-bemenu";
    runtimeInputs = with pkgs; [
      bemenu
      rbw
    ];
    text = ''
      item="$(rbw list | bemenu -i)"
      field="$(echo -e 'password\ntotp\nusername' | bemenu -p 'Field')"
      rbw get "$item" -f "$field" | wl-copy -n
    '';
  };
in
{
  home.packages = [
    rbw-bemenu
  ];
}
