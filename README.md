# Cameron's NixOS Configuration

A comprehensive, modular NixOS and nix-darwin configuration managing 4 distinct hosts with shared modules and centralized user management.

## 🏗️ Repository Structure

```
nix-config/
├── flake.nix              # Main flake configuration and system declarations
├── hosts/                 # Host-specific configurations
│   ├── mbp/              # MacBook Pro (aarch64-darwin)
│   ├── workstation/      # Desktop Linux system
│   ├── ideapad/          # Laptop Linux system
│   └── nix-server/       # Home server with services
├── modules/               # Reusable configuration modules
│   ├── nixos/            # System-level modules
│   └── home-manager/     # User-level modules
├── scripts/               # Utility scripts and documentation
├── secrets/               # SOPS encrypted secrets
└── .taskmaster/          # Task management integration
```

## 🖥️ Hosts Overview

| Host | Platform | Purpose | Documentation |
|------|----------|---------|---------------|
| **[mbp](hosts/mbp/README.md)** | `aarch64-darwin` | Development workstation with yabai/skhd | [📖 Complete Guide](hosts/mbp/README.md) |
| **[workstation](hosts/workstation/README.md)** | `x86_64-linux` | Desktop Linux with Hyprland | [📖 Complete Guide](hosts/workstation/README.md) |
| **[ideapad](hosts/ideapad/README.md)** | `x86_64-linux` | Portable laptop system | [📖 Complete Guide](hosts/ideapad/README.md) |
| **[nix-server](hosts/nix-server/README.md)** | `x86_64-linux` | Home server & automation hub | [📖 Complete Guide](hosts/nix-server/README.md) |

### Host-Specific Features

Each host has comprehensive documentation covering setup, configuration, troubleshooting, and optimization:

- **mbp**: macOS development environment with Homebrew integration, window management, and cross-platform workflow
- **workstation**: High-performance Linux desktop with AMD GPU, Wayland/Hyprland, and development-focused setup
- **ideapad**: Mobile Linux laptop with battery optimization, thermal management, and productivity-focused configuration
- **nix-server**: Complete home server infrastructure with ZFS storage, Home Assistant automation, Docker services, and monitoring

## 🚀 Quick Start

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- For macOS: [nix-darwin](https://github.com/LnL7/nix-darwin)
- Age/SOPS for secrets management (if needed)

### Deployment

#### NixOS Systems

```bash
# Clone the repository
git clone https://github.com/ckstevenson/nix-config.git
cd nix-config

# Deploy to a NixOS system
sudo nixos-rebuild switch --flake .#<hostname>

# Available hostnames: workstation, ideapad, nix-server
```

#### macOS (Darwin) Systems

```bash
# Deploy to macOS
darwin-rebuild switch --flake .#mbp
```

#### Testing Configuration

```bash
# Test configuration without switching
nixos-rebuild build --flake .#<hostname>

# For macOS
darwin-rebuild build --flake .#mbp
```

## 📦 Features

### System Features
- **Modular Architecture**: Reusable modules for different system types
- **Multiple Platforms**: Native support for NixOS and macOS
- **Declarative Configuration**: Everything managed through Nix
- **Secrets Management**: SOPS integration for secure credential handling
- **Modern Desktop**: Hyprland/Wayland on Linux systems

### Development Environment
- **Nixvim**: Fully configured Neovim setup
- **Shell Environment**: Zsh with completions and tools
- **Development Tools**: Git, direnv, and language-specific tooling
- **CLI Utilities**: Modern replacements (lf, zoxide, etc.)

### Services
- **Backup System**: Automated backup with scheduling
- **Nextcloud Sync**: File synchronization service
- **VPN**: Tailscale network overlay
- **Home Automation**: Home Assistant (nix-server only)

## 🧩 Module System

### NixOS Modules (`modules/nixos/`)

- **`default.nix`**: Base system configuration with user management
- **`desktop.nix`**: Desktop environment (Hyprland, graphics, audio)
- **`laptop.nix`**: Laptop-specific optimizations and power management
- **`ssh.nix`**: SSH server configuration and key management

### Home-Manager Modules (`modules/home-manager/`)

- **CLI**: Shell configuration, development tools, terminal applications
- **Desktop**: GUI applications, window management, theming
- **Services**: User-level services (backup, sync)
- **Packages**: Custom derivations and overlays

### Module Usage

Modules use a standardized option system:

```nix
# In host configuration
{
  desktop.enable = true;        # Enable desktop environment
  laptop.enable = true;         # Enable laptop optimizations
}
```

## 🎨 Theming

The configuration uses a centralized color scheme system:

- **Color Scheme**: Custom "Oxocarbon Fixed" theme via nix-colors
- **Consistent Theming**: Applied across terminal, desktop, and applications
- **Customizable**: Easy to switch themes by modifying the color scheme

## 🔐 Secrets Management

### SOPS Configuration

Secrets are managed using [SOPS](https://github.com/Mic92/sops-nix) with age encryption:

```bash
# Edit secrets (requires proper age key)
sops secrets/secrets.yaml

# Generate new age key
age-keygen -o ~/.config/sops/age/keys.txt
```

### SSH Key Management

SSH keys are centrally managed and deployed to all hosts:

- Keys defined in `modules/nixos/default.nix`
- Automatic deployment to `~/.ssh/authorized_keys`
- Supports multiple keys for different access patterns

## 🏠 Adding a New Host

1. **Create host directory**:
   ```bash
   mkdir hosts/new-hostname
   ```

2. **Create base configuration**:
   ```nix
   # hosts/new-hostname/configuration.nix
   { inputs, pkgs, ... }: {
     imports = [
       ../../modules/nixos
       ./hardware-configuration.nix  # Generated by nixos-generate-config
       ./home.nix
     ];

     networking.hostName = "new-hostname";
     desktop.enable = true;  # Enable features as needed
     laptop.enable = false;
   }
   ```

3. **Create home configuration**:
   ```nix
   # hosts/new-hostname/home.nix
   { inputs, ... }: {
     imports = [ ../../modules/home-manager ];

     home = {
       username = "cameronstevenson";
       homeDirectory = "/home/cameronstevenson";
       stateVersion = "24.11";
     };
   }
   ```

4. **Add to flake.nix**:
   ```nix
   nixosConfigurations = {
     # ... existing configurations
     new-hostname = nixpkgs.lib.nixosSystem {
       specialArgs = {inherit inputs;};
       modules = [
         ./hosts/new-hostname/configuration.nix
         inputs.home-manager.nixosModules.default
       ];
     };
   };
   ```

5. **Generate hardware configuration**:
   ```bash
   nixos-generate-config --root /mnt --dir hosts/new-hostname/
   ```

## 🔧 Common Operations

### Updating System

```bash
# Update flake inputs
nix flake update

# Rebuild with new inputs
sudo nixos-rebuild switch --flake .#<hostname>
```

### Managing Packages

```bash
# Search for packages
nix search nixpkgs <package-name>

# Test package temporarily
nix shell nixpkgs#<package-name>

# Add to configuration permanently
# Edit appropriate module and rebuild
```

### Debugging Issues

```bash
# Check system logs
journalctl -xef

# Verify configuration syntax
nix flake check

# Build without switching (safe testing)
nixos-rebuild build --flake .#<hostname>
```

## 🚨 Troubleshooting

### Common Build Failures

1. **Flake evaluation errors**: Check syntax in `.nix` files
2. **Hardware mismatch**: Ensure `hardware-configuration.nix` is up to date
3. **Module conflicts**: Check for conflicting option definitions
4. **Missing secrets**: Ensure SOPS keys are properly configured

### Hardware Configuration Issues

```bash
# Regenerate hardware configuration
sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

### Rolling Back Changes

```bash
# List previous generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Rollback to specific generation
sudo nix-env --switch-generation <generation-number> --profile /nix/var/nix/profiles/system
```

## 📋 Development Workflow

This repository includes pre-commit hooks and automated code quality checks. See [DEVELOPMENT.md](./DEVELOPMENT.md) for detailed workflow documentation.

### Quick Start
1. **Set up pre-commit hooks**: `./scripts/setup-precommit.sh`
2. **Make changes** to configuration files
3. **Test locally**: `nixos-rebuild build --flake .#<hostname>`
4. **Apply changes**: `sudo nixos-rebuild switch --flake .#<hostname>`
5. **Commit changes**: Pre-commit hooks will run automatically
6. **Deploy remotely** (if needed): Use deployment scripts

## 🤝 Contributing

This is a personal configuration repository, but you're welcome to:

- Fork and adapt for your own use
- Submit issues for bugs or suggestions
- Propose improvements via pull requests

## 📚 Documentation

### Host-Specific Guides
- **[MacBook Pro (mbp)](hosts/mbp/README.md)**: Complete macOS development workstation setup with yabai/skhd window management
- **[Workstation](hosts/workstation/README.md)**: High-performance Linux desktop with Hyprland and AMD GPU configuration
- **[IdeaPad](hosts/ideapad/README.md)**: Mobile Linux laptop with battery optimization and productivity workflows
- **[Nix Server](hosts/nix-server/README.md)**: Comprehensive home server infrastructure with Home Assistant and ZFS storage

### System Documentation
- **[Secrets Management](docs/secrets-management.md)**: Complete guide to SOPS configuration and secrets handling
- **[Development Workflow](DEVELOPMENT.md)**: Pre-commit hooks, testing, and deployment procedures

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix-Darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [SOPS-NIX Documentation](https://github.com/Mic92/sops-nix)
- [Hyprland Documentation](https://hyprland.org/)

## 📄 License

This configuration is provided as-is for educational and personal use.
