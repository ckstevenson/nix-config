# Module System and Architecture

This document describes the repository's module system and high-level architecture. It is adapted from the top-level README and reorganised for clarity.

Repository layout (summary)

```
nix-config/
├── flake.nix              # Main flake configuration and system declarations
├── hosts/                 # Host-specific configurations (each host has its own README)
├── modules/               # Reusable configuration modules
│   ├── nixos/            # System-level modules
│   └── home-manager/     # User-level modules
├── scripts/               # Utility scripts and documentation
├── secrets/               # SOPS encrypted secrets
└── .taskmaster/          # Task management integration
```

NixOS Modules (modules/nixos/)

- `default.nix`: Base system configuration, user management, common services
- `desktop.nix`: Desktop environment (Hyprland, graphics, audio)
- `laptop.nix`: Laptop-specific optimizations and power management
- `ssh.nix`: SSH server configuration and key management

Home-Manager Modules (modules/home-manager/)

- Organised into concerns: CLI, Desktop, Services, Packages
- Keep user-level configuration declarative and reusable across hosts

Design principles

- Modular: split features into small, focused modules that expose boolean options and small option sets
- Reusable: hosts import modules and enable features via options (e.g. `desktop.enable = true`)
- Declarative: all system state defined in Nix and deployed via rebuilds

How to add a module

1. Create a file under modules/nixos or modules/home-manager
2. Define options using `lib.mkOption` and provide a `config` attr
3. Add documentation and examples inside the module file

Where to read more

- Host-specific guides: hosts/<hostname>/README.md
- Development and testing: DEVELOPMENT.md
