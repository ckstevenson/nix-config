{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "cameron" = import ./home.nix;
    };
  };

  users.users = {
    cameron = {
      extraGroups = [ "wheel" ];
    };
  };

  networking.hostName = "ideapad";

  laptop.enable = true;
  desktop.enable = true;

  system.stateVersion = "23.11";
}

