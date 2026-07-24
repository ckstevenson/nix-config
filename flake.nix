{
  description = "Cameron's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

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

    nix-darwin = {
      # Pinned to PR #1819 (p42software:manual-toc-depth) which fixes the
      # darwin-manual-html build failure on unstable nixpkgs: nixos-render-docs
      # removed --toc-depth/--chunk-toc-depth; the PR switches to --sidebar-depth.
      # See https://github.com/nix-darwin/nix-darwin/pull/1819 and issue #1817.
      # Revert to github:nix-darwin/nix-darwin once the PR is merged.
      url = "github:p42software/nix-darwin/manual-toc-depth";
      # Use unstable nixpkgs everywhere on macOS to avoid package/module skew
      # that arises when system pkgs are pinned to stable while home-manager
      # follows unstable. This makes mbp consistent with other hosts.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-config = {
      url = "git+https://github.com/Kaleris-CVS/opencode-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, ... }@inputs: {
    darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ./hosts/mbp/configuration.nix
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
    };
    nixosConfigurations = {
      workstation = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/workstation/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      ideapad = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/ideapad/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nix-server = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nix-server/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
