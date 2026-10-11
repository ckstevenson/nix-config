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

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  sshd.enable = true;
  desktop.enable = true;
  gaming.enable = true;
  opencode.enable = true;
  # Enable local Ollama LLM server
  ollama.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
  services.ratbagd.enable = true;
}
