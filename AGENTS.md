# Agent Development Guide

## Build & Test Commands
```bash
# Build configuration (test without applying)
nixos-rebuild build --flake .#<hostname>           # NixOS: workstation, ideapad, nix-server
darwin-rebuild build --flake .#mbp                 # macOS

# Apply configuration
sudo nixos-rebuild switch --flake .#<hostname>     # NixOS
darwin-rebuild switch --flake .#mbp                # macOS

# Validate flake and check syntax
nix flake check --show-trace                       # Full validation with error details
nixpkgs-fmt <file.nix>                            # Format single Nix file
pre-commit run --all-files                        # Run all quality checks
```

## Code Style
- **Formatting**: Use `nixpkgs-fmt` (2-space indentation, consistent attributes)
- **Imports**: Place at top; use `{ inputs, ... }:` for flake inputs; external modules before local
- **Module Pattern**: Define `options` with `lib.mkOption`/`lib.mkEnableOption`, then `config`
- **Types**: Always specify types for options (`lib.types.str`, `lib.types.bool`, etc.)
- **Naming**: Use camelCase for options (`desktop.enable`), kebab-case for files (`home-manager`)
- **Documentation**: Add `description` to all options; comment complex configurations inline
- **Error Handling**: Use `lib.mkDefault` for overridable defaults; validate with `lib.types`

## Project Structure
- **Host configs**: `hosts/<hostname>/` - Contains `configuration.nix`, `home.nix`, `hardware-configuration.nix`
- **Reusable modules**: `modules/nixos/` (system), `modules/home-manager/` (user)
- **Secrets**: Managed via SOPS (never commit plaintext); edit with `sops secrets/secrets.yaml`
- **Task management**: See `.taskmaster/CLAUDE.md` for Task Master AI workflow integration
