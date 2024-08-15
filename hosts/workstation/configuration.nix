{ inputs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  networking.networkmanager.enable = true;

  boot.initrd.kernelModules = [ "amdgpu" ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "cameron" = import ./home.nix;
    };
  };

  users.users = {
    cameron = {
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  networking.hostName = "workstation";

  sshd.enable = true;
  desktop.enable = true;

  system.stateVersion = "23.11";
}

