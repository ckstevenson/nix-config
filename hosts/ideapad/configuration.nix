{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
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
  opencode.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.11";
}
