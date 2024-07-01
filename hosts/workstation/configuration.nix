{ inputs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "cameron" = import ./home.nix;
    };
  };

  networking.hostName = "workstation";

  sshd.enable = true;

  system.stateVersion = "23.11";
}

