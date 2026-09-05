# IdeaPad Host Configuration

The **ideapad** host represents a portable Linux development laptop configured with a modern Wayland desktop environment, optimized for mobile productivity and battery efficiency.

## 🖥️ System Overview

### Hardware Profile
- **Platform**: x86_64 Intel-based laptop (Lenovo IdeaPad series)
- **Storage**: Single ext4 root partition with UEFI boot
- **CPU**: Intel processor with microcode updates
- **Wireless**: Intel wireless with iwd backend
- **Form Factor**: Traditional laptop with integrated display and keyboard

### Role & Purpose
This host serves as a **mobile development workstation**, providing:
- Full Linux desktop environment for development on-the-go
- Battery-optimized configuration with thermal management
- VPN connectivity for remote work
- Synchronized development environment with other hosts
- Secure backup integration for mobile data protection

## 🏗️ Architecture & Features

### Core System Configuration
```nix
# hosts/ideapad/configuration.nix
{
  networking.hostName = "ideapad";

  # Enable laptop-specific optimizations
  laptop.enable = true;
  desktop.enable = true;

  system.stateVersion = "23.11";
}
```

### Module Integration
The ideapad configuration leverages several key modules:

#### 1. **Laptop Module** (`modules/nixos/laptop.nix`)
```nix
{
  # Wireless networking with iwd
  networking.wireless.iwd.enable = true;

  # Thermal management for battery life
  services.thermald.enable = true;
}
```

#### 2. **Desktop Module** (`modules/nixos/desktop.nix`)
- Wayland compositor (Hyprland)
- Audio system (PipeWire)
- Display managers and essential desktop services

#### 3. **GlobalProtect Module**
- Palo Alto Networks VPN client
- Enterprise network connectivity
- Secure remote access capabilities

## 🎨 Desktop Environment

### Hyprland Wayland Compositor
The ideapad uses **Hyprland** as its primary desktop environment, providing:

#### Window Management
```nix
# Tiling window manager with workspace switching
# Optimized for laptop screen real estate
bind = $mod, left, movefocus, l
bind = $mod, right, movefocus, r
bind = $mod, up, movefocus, u
bind = $mod, down, movefocus, d
```

#### Visual Configuration
```nix
decoration = {
  rounding = 10;
  blur = {
    enabled = true;
    size = 8;
    passes = 3;
  };
  drop_shadow = false;  # Disabled for battery optimization
}
```

### Color Scheme: Carbonfox Fixed
The ideapad implements a custom "Carbonfox Fixed" color scheme:

```nix
colorScheme = {
  slug = "carbonfox-fixed";
  name = "Carbonfox Fixed";
  palette = {
    base00 = "#161616";  # Background
    base01 = "#262626";  # Secondary background
    base04 = "#dde1e6";  # Foreground
    base0E = "#be95ff";  # Primary accent (purple)
    base09 = "#78a9ff";  # Secondary accent (blue)
    # ... additional colors
  };
}
```

### Status Bar: Waybar
Custom-styled Waybar with laptop-specific modules:

```css
* {
  font-size: 20px;  /* Optimized for laptop display */
  color: #dde1e6;
}

#battery.critical:not(.charging) {
  color: #FFCB6B;  /* Warning color for low battery */
}

#battery.warning:not(.charging) {
  color: #3ddbd9;  /* Caution color for moderate battery */
}
```

#### Waybar Modules
- **Workspaces**: Visual workspace indicators
- **Battery**: Critical for laptop usage with charging status
- **Network**: Wireless connection status
- **Audio**: PulseAudio/PipeWire volume control
- **Clock**: Time and date display

## 🔧 Development Environment

### Terminal Configuration
```nix
# Custom font sizing for laptop display
alacrittyFontSize = 16;  # Readable on laptop screen
```

### Package Management
Essential development tools pre-installed:

```nix
home.packages = with pkgs; [
  _1password-gui        # Password management with GUI
  _1password           # CLI password manager
  vmware-horizon-client # VMware remote desktop client
  brightnessctl        # Display brightness control
];
```

### Browser Configuration
```nix
firefoxFontSize = 18;  # Optimized for laptop display DPI
```

## 🔄 Data Synchronization

### Nextcloud Integration
```nix
nextcloudSyncService.enable = true;
```
- Automatic file synchronization with Nextcloud server
- Cross-device file access and collaboration
- Offline file availability for mobile work

### Secure Backup System
```nix
services.backupService.enable = true;

sops = {
  age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  defaultSopsFile = ../../secrets/backup/restic.yaml;
};
```

#### Backup Features
- **Encryption**: All backups encrypted with restic
- **Secret Management**: Backup credentials secured with SOPS/age
- **Scheduling**: Automated backup runs via systemd timers
- **Mobile Optimization**: Backup scheduling considers power state

## 🌐 Network Configuration

### Wireless Management
```nix
networking.wireless.iwd.enable = true;
```
- **iwd**: Modern WiFi daemon for reliable connections
- **Enterprise WiFi**: Support for WPA2-Enterprise networks
- **Power Management**: WiFi power saving for battery life

## ⚡ Power Management

### Thermal Control
```nix
services.thermald.enable = true;
```
- **Intel Thermal Daemon**: Prevents overheating
- **Dynamic Scaling**: CPU frequency scaling based on temperature
- **Battery Protection**: Thermal throttling to preserve battery life

### Display Brightness
```bash
# Available via brightnessctl package
brightnessctl set 50%     # Set brightness to 50%
brightnessctl set +10%    # Increase brightness by 10%
brightnessctl set 10%-    # Decrease brightness by 10%
```

## 🛡️ Security Configuration

### SOPS Secret Management
```nix
sops = {
  age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  defaultSopsFile = ../../secrets/backup/restic.yaml;
};
```

#### Encrypted Secrets
- **Backup Credentials**: Repository passwords and access keys
- **Age Keys**: Decryption keys stored securely on device
- **Service Tokens**: API keys and authentication tokens

### 1Password Integration
```nix
home.packages = with pkgs; [
  _1password-gui    # Desktop application
  _1password       # CLI tools and SSH agent
];
```

## 🚀 Common Usage Patterns

### Daily Development Workflow
1. **Startup**: Automatic services and desktop environment launch
2. **VPN Connection**: GlobalProtect establishes secure connection
3. **File Sync**: Nextcloud synchronizes latest project files
4. **Development**: Full IDE and terminal environment available
5. **Backup**: Automated encrypted backups to secure storage

### Mobile Productivity
- **Battery Optimization**: Thermal management and power-aware services
- **Offline Capability**: Local file storage with sync when connected
- **Quick Boot**: Fast startup for immediate productivity
- **Workspace Persistence**: Desktop state preserved across sessions

### Remote Work Integration
- **VPN Access**: Secure corporate network connectivity
- **VMware Horizon**: Access to virtual desktops and applications
- **Password Management**: Secure credential access with 1Password
- **File Synchronization**: Real-time collaboration via Nextcloud

## 📁 File Structure

```
hosts/ideapad/
├── configuration.nix       # Main system configuration
├── hardware-configuration.nix  # Auto-generated hardware config
├── home.nix               # User environment configuration
└── README.md              # This documentation
```

### Key Configuration Files

#### `configuration.nix` - System Level
- Network hostname and basic system settings
- Module imports and user configuration
- System version pinning

#### `hardware-configuration.nix` - Hardware Specific
- Boot loader and kernel module configuration
- Filesystem and partition definitions
- CPU-specific optimizations (Intel microcode)

#### `home.nix` - User Environment
- Desktop appearance and font configurations
- Application-specific settings
- Service integrations and package installations

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Wireless Connectivity
```bash
# Check iwd status
sudo systemctl status iwd

# Scan for networks
iwctl station wlan0 scan
iwctl station wlan0 get-networks

# Connect to network
iwctl station wlan0 connect NETWORK_NAME
```

#### Battery/Thermal Issues
```bash
# Check thermal status
sudo systemctl status thermald

# Monitor CPU temperature
watch -n 1 sensors

# Check power consumption
sudo powertop
```

#### Display Brightness
```bash
# Check current brightness
brightnessctl get

# List available devices
brightnessctl --list

# Set specific brightness level
brightnessctl set 30%
```

#### Backup Service
```bash
# Check backup service status
systemctl --user status backup.service

# View backup logs
journalctl --user -u backup.service

# Manual backup test
restic backup ~/Documents --repo /path/to/repo
```

### Log Locations
- **System Logs**: `journalctl -b` (current boot)
- **Hyprland Logs**: `~/.cache/hyprland/hyprland.log`
- **Waybar Logs**: `journalctl --user -u waybar`
- **Backup Logs**: `journalctl --user -u backup.service`

## 🎯 Optimization Notes

### Performance Tuning
- **SSD**: All configurations optimized for SSD storage
- **Memory**: Efficient memory usage for typical 8-16GB laptop RAM
- **Graphics**: Intel integrated graphics optimizations
- **Network**: iwd provides better power management than wpa_supplicant

### Battery Life Considerations
- **Compositor**: Hyprland configured with reduced animations
- **Services**: Non-essential services disabled for power savings
- **Thermal**: Active thermal management prevents throttling
- **Display**: Manual brightness control for optimal battery usage

### Mobile-Specific Features
- **Quick Resume**: Fast wake from suspend
- **Network Roaming**: Seamless WiFi network transitions
- **File Sync**: Intelligent sync based on connection quality
- **Backup Scheduling**: Power-aware backup execution

## 🔗 Integration Points

### Cross-Host Synchronization
- **Development Projects**: Synchronized via Nextcloud
- **Configuration**: Shared modules with other NixOS hosts
- **Secrets**: Consistent secret management across all hosts
- **Backups**: Unified backup strategy with workstation and nix-server

### Service Dependencies
- **Network**: Required for Nextcloud sync and GlobalProtect VPN
- **Power**: Thermal management depends on ACPI support
- **Graphics**: Wayland requires proper GPU driver support
- **Audio**: PipeWire integration for complete desktop experience

---

*This configuration represents a complete mobile Linux workstation optimized for development productivity, security, and battery efficiency.*
