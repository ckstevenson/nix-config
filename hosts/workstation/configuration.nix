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

  system.stateVersion = "23.11";
}

