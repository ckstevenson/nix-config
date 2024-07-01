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

  networking.hostName = "ideapad";

  laptop.enable = true;

  system.stateVersion = "23.11";
}

