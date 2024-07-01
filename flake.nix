{
  description = "Cameron's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      workstation = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/workstation/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      ideapad = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
	        ./hosts/ideapad/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nix-server = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
	        ./hosts/nix-server/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
