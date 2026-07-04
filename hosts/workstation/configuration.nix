{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

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

  networking.hostName = "workstation";

  sshd.enable = true;
  desktop.enable = true;
  opencode.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
  services.ratbagd.enable = true;
}
