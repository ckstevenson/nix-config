# Quick Start & Testing

Essential commands for testing and deploying configurations.

Prerequisites

- Nix with flakes enabled
- For macOS: nix-darwin
- SOPS/age for secrets if needed

Deploy (NixOS)

```bash
git clone https://github.com/ckstevenson/nix-config.git
cd nix-config
sudo nixos-rebuild switch --flake .#<hostname>
```

Deploy (Darwin/macOS)

```bash
darwin-rebuild switch --flake .#mbp
```

Test without switching

```bash
nixos-rebuild build --flake .#<hostname>
darwin-rebuild build --flake .#mbp
```

Common checks

- Update flake inputs: `nix flake update`
- Validate flakes: `nix flake check --show-trace`
- Format Nix files: `nixpkgs-fmt <file.nix>`
