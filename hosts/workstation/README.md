# Workstation - Desktop Linux System

## Overview
**Platform:** `x86_64-linux`  
**Hostname:** `workstation`  
**User:** `cameron`  
**Primary Role:** Desktop development system with AMD GPU support and VPN capabilities

This host serves as a desktop Linux development system with a modern Wayland-based desktop environment, hardware graphics acceleration, and enterprise VPN connectivity.

## System Architecture

### Core Configuration
- **OS:** NixOS 23.11
- **Architecture:** x86_64-linux (Intel-based)
- **Desktop Environment:** Hyprland (Wayland compositor)
- **Shell:** Zsh
- **Hardware:** Intel CPU with AMD GPU
- **Graphics:** AMD GPU with hardware acceleration

### Key Features
- **Modern Desktop** - Hyprland Wayland compositor with hardware acceleration
- **AMD GPU Support** - Optimized for AMD graphics cards with AMDGPU kernel module
- **Enterprise VPN** - GlobalProtect VPN client for corporate connectivity
- **Secure Backup** - SOPS-encrypted automated backup system
- **Audio System** - PipeWire for modern audio handling

## Hardware Configuration

### CPU & Graphics
```nix
# Intel CPU with microcode updates
hardware.cpu.intel.updateMicrocode = true;
nixpkgs.hostPlatform = "x86_64-linux";

# AMD GPU support
boot.initrd.kernelModules = [ "amdgpu" ];

# Hardware graphics acceleration
hardware.graphics = {
  enable = true;
  extraPackages = [
    intel-media-driver    # LIBVA_DRIVER_NAME=iHD
    libvdpau-va-gl       # VA-API to VDPAU wrapper
  ];
};
```

### Storage Configuration
```nix
# Root filesystem
fileSystems."/" = {
  device = "/dev/disk/by-uuid/6a870245-55f9-4040-9bd7-4b1745932f8c";
  fsType = "ext4";
};

# Boot partition (UEFI)
fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/3EB9-00F5";
  fsType = "vfat";
};

# No swap configured
swapDevices = [ ];
```

### Boot Configuration
```nix
# Systemd-boot EFI loader
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# Kernel modules
boot.initrd.availableKernelModules = [
  "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
];
boot.kernelModules = [ "kvm-intel" ];
```

## Desktop Environment

### Hyprland Wayland Compositor
```nix
programs.hyprland.enable = true;

# XDG Desktop Portal configuration
xdg.portal = {
  wlr.enable = true;
  enable = true;
  extraPortals = [ xdg-desktop-portal-hyprland ];
};
```

### Audio System
```nix
# PipeWire audio server
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;    # 32-bit application support
  pulse.enable = true;          # PulseAudio compatibility
  wireplumber.enable = true;    # Session manager
};

# Real-time audio support
security.rtkit.enable = true;
```

### Font Configuration
```nix
fonts = {
  packages = [ nerdfonts ];
  fontconfig = {
    defaultFonts = {
      monospace = ["DejaVuSansM Nerd Font Mono"];
      sansSerif = ["DejaVuSansM Nerd Font"];
      serif = ["DejaVuSansM Nerd Font"];
    };
    subpixel.rgba = "rgb";  # LCD subpixel rendering
  };
};
```

## Network & VPN Configuration

### Base Networking
```nix
networking = {
  hostName = "workstation";
  useDHCP = true;  # DHCP on all interfaces
};

# DNS resolution
services.resolved.enable = true;
```

### GlobalProtect VPN
```nix
globalProtect.enable = true;
# Provides: services.globalprotect.enable = true;
```

**VPN Features:**
- Corporate VPN connectivity via GlobalProtect
- Integrated with NetworkManager
- Supports SSL VPN protocols
- Compatible with Palo Alto Networks gateways

### Remote Access
```nix
sshd.enable = true;  # SSH daemon enabled

# SSH authorized keys configured for user 'cameron'
# Includes keys from: mbp, ideapad, workstation (itself), and external key
```

## User Configuration

### User Account
```nix
users.users.cameron = {
  isNormalUser = true;
  shell = pkgs.zsh;
  extraGroups = [ "wheel" ];  # Sudo access
};
```

### SSH Access
The user has SSH keys configured for seamless access between hosts:
- **mbp**: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...`
- **ideapad**: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...`
- **workstation**: `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDj...`
- **External**: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...`

## Development Environment

### Home Manager Integration
The workstation uses the comprehensive home-manager module system:

```nix
imports = [
  ../../modules/home-manager  # Full module suite
];
```

**Included Module Categories:**
- **CLI Tools** (`./cli`) - Command-line development tools
- **Desktop Apps** (`./desktop`) - GUI applications and desktop integration  
- **Packages** (`./pkgs`) - Additional software packages
- **Services** (`./services`) - Background services and daemons

**External Integrations:**
- **nix-colors** - Color scheme theming support
- **nixvim** - Neovim configuration framework
- **sops-nix** - Secrets management

### Color Scheme
Uses the same **Oxocarbon Fixed** theme as other hosts:
```nix
colorScheme = {
  slug = "oxocarbon-fixed";
  name = "Oxocarbon Fixed";
  # IBM-inspired dark theme with carefully chosen colors
  # for development and general use
};
```

## Secure Backup System

### Configuration
```nix
services.backupService.enable = true;

# SOPS integration for secure credential storage
sops = {
  age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  defaultSopsFile = ../../secrets/backup/restic.yaml;
};
```

### Backup Features
- **SOPS Integration:** Restic credentials encrypted with SOPS/age
- **Systemd Service:** Automated backup via systemd timer
- **Cross-Platform:** Same backup system as other Linux hosts
- **Secure Storage:** Remote backup with encrypted credentials

## System Services

### Security & Access
```nix
# Polkit for privilege escalation
security.polkit.enable = true;

# Sudo configuration
security.sudo.extraConfig = ''
  Defaults !tty_tickets, timestamp_timeout=60
'';

# SSH agent
programs.ssh.startAgent = true;
```

### Network Services
```nix
# Tailscale for private networking
services.tailscale.enable = true;

# DNS resolution
services.resolved.enable = true;
```

### Power Management
```nix
powerManagement = {
  enable = true;
  cpuFreqGovernor = "powersave";  # Power-efficient CPU scaling
};
```

## System Configuration

### Time & Locale
```nix
time.timeZone = "Europe/Berlin";  # Central European Time
```

### Package Management
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

## File Organization

```
hosts/workstation/
├── configuration.nix           # Main system configuration
├── home.nix                   # Home Manager configuration  
└── hardware-configuration.nix # Auto-generated hardware config
```

## Module Architecture

### NixOS Modules (`../../modules/nixos`)
- `default.nix` - Base system configuration and options
- `desktop.nix` - Desktop environment and graphics setup
- `global-protect.nix` - VPN client configuration
- `ssh.nix` - SSH service configuration
- `laptop.nix` - Laptop-specific features (not enabled)

### Home Manager Modules (`../../modules/home-manager`)
- `cli/` - Command-line tools and shell configuration
- `desktop/` - Desktop applications and theming
- `pkgs/` - Additional software packages
- `services/` - User services and background processes

## Usage Patterns

### Daily Workflow
1. **Desktop Environment:** Modern Wayland-based Hyprland compositor
2. **Graphics Performance:** Hardware-accelerated AMD GPU rendering
3. **VPN Connectivity:** GlobalProtect for enterprise network access
4. **Development:** Full CLI and desktop development toolkit
5. **Backup:** Automated daily backups with encrypted storage

### Hardware Optimization
1. **GPU Acceleration:** AMD GPU with AMDGPU kernel driver
2. **Audio:** Low-latency PipeWire audio system
3. **Power Management:** Efficient CPU frequency scaling
4. **Graphics:** Intel media drivers for hardware video decoding

## Network Connectivity

### Local Network
- **DHCP:** Automatic IP configuration on all interfaces
- **SSH:** Remote access enabled with key-based authentication
- **Tailscale:** Private mesh networking

### VPN Access
- **GlobalProtect:** Enterprise VPN for corporate resources
- **SSL VPN:** Secure tunnel protocols
- **Integration:** NetworkManager integration for seamless connection

## Build Commands

```bash
# Build and activate system configuration
sudo nixos-rebuild switch --flake .#workstation

# Build without activation
nixos-rebuild build --flake .#workstation

# Update flake inputs
nix flake update

# Check configuration
nix flake check
```

## Troubleshooting

### Common Issues
1. **AMD GPU:** Ensure AMDGPU kernel module is loaded
2. **Wayland:** Some applications may need X11 compatibility
3. **VPN:** GlobalProtect may require specific network configuration
4. **Audio:** PipeWire conflicts with other audio systems

### Hardware-Specific
- **Graphics:** Check `lspci | grep VGA` for GPU detection
- **Modules:** Verify `lsmod | grep amdgpu` for driver loading
- **Audio:** Use `systemctl --user status pipewire` for audio status

### Key Configuration Files
- **Hardware Config:** `/etc/nixos/hardware-configuration.nix` (auto-generated)
- **Main Config:** `hosts/workstation/configuration.nix:24` (hostname)
- **User Config:** `hosts/workstation/configuration.nix:18-22` (user setup)
- **Backup Config:** `hosts/workstation/home.nix:9` (backup service)

---

*This workstation provides a modern Linux desktop environment optimized for development work with hardware acceleration, enterprise connectivity, and secure backup capabilities.*