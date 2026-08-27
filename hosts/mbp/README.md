# MacBook Pro (mbp) - Development Workstation

## Overview
**Platform:** `aarch64-darwin` (Apple Silicon M-series)
**Hostname:** `mbp`
**User:** `cameronstevenson`
**Primary Role:** Development workstation with advanced window management and comprehensive tooling

This host serves as the primary development machine with a sophisticated macOS configuration optimized for productivity, featuring advanced window management, extensive development tooling, and secure backup integration.

## System Architecture

### Core Configuration
- **OS:** macOS with nix-darwin
- **Architecture:** Apple Silicon (aarch64-darwin)
- **Shell:** Zsh (default macOS shell)
- **Package Management:** Nix + Homebrew hybrid approach
- **State Version:** 4

### Key Features
- **Tiling Window Management** - yabai + skhd for i3/Sway-like experience on macOS
- **Advanced Keyboard Mapping** - PC-style shortcuts in macOS environment
- **Homebrew Integration** - Seamless integration for macOS-specific applications
- **Secure Backup System** - SOPS-encrypted automated backup to remote storage
- **Development Toolchain** - Comprehensive set of development and DevOps tools

## Window Management System

### Yabai Configuration (`yabai.nix`)
```nix
layout = "bsp";                    # Binary space partitioning
window_placement = "second_child"; # New windows as second child
mouse_follows_focus = "on";        # Mouse follows focused window
focus_follows_mouse = "autoraise"; # Auto-raise on mouse focus
```

**Workspace Layout:**
- Workspaces 1-8: General development and applications
- Workspace 9: Microsoft Teams
- Workspace 10: Slack

**Window Rules:**
- System apps (Settings, Preferences) are unmanaged
- Notes app configured as scratchpad (11x11 grid, 1:1:9:9)
- Communication apps auto-assigned to dedicated workspaces

### Keyboard Shortcuts (`skhd.nix`)

**System Shortcuts:**
- `cmd + return` - Open Alacritty terminal
- `cmd + shift + n` - Toggle Notes scratchpad or open notes
- `cmd + d` - Application launcher (choose from all apps)
- `cmd + p` - Password manager (rbw-choose)
- `cmd + w` - Open Firefox

**Window Management:**
- `cmd + h/j/k/l` - Focus window (vim-style navigation)
- `shift + cmd + h/j/k/l` - Move window
- `cmd + 1-9/0` - Switch to workspace 1-10
- `shift + cmd + 1-9/0` - Move window to workspace
- `alt + cmd + 1-9/0` - Move window to workspace and follow

**PC-Style Shortcuts** (remapped for terminal compatibility):
- `ctrl + c/v/x/z` → `cmd + c/v/x/z` (copy/paste/cut/undo)
- `ctrl + a/f/g/k/n/r/t/w` → `cmd + a/f/g/k/n/r/t/w` (select all, find, etc.)
- `ctrl + backspace` → `alt + backspace` (delete word)

*Note: All ctrl mappings automatically exclude terminal applications (alacritty, terminal)*

## System Customization

### macOS Defaults
```nix
# Appearance
AppleInterfaceStyle = "Dark";              # Dark mode
NSGlobalDomain.AppleShowAllExtensions = true; # Show file extensions

# Dock
dock.autohide = true;                      # Auto-hide dock
dock.tilesize = 48;                        # Smaller dock icons
dock.mru-spaces = false;                   # Disable space reordering (for yabai)

# Finder
finder.CreateDesktop = false;              # Hide desktop icons
finder.FXPreferredViewStyle = "Nlsv";      # List view by default
finder._FXShowPosixPathInTitle = true;     # Show full path in title

# Input
trackpad.Clicking = true;                  # Tap to click
"com.apple.swipescrolldirection" = false;  # Disable natural scrolling

# Keyboard
system.keyboard.remapCapsLockToEscape = true;     # Caps Lock → Escape
system.keyboard.swapLeftCommandAndLeftAlt = true;  # PC-style Alt/Cmd swap
```

### Fonts
- **Primary:** DejaVuSansM Nerd Font Mono
- **Purpose:** Consistent monospace font with icon support across terminal and editors

## Development Environment

### Core Development Tools
```nix
# Programming Languages & Runtimes
nodejs                 # Node.js runtime
dotnet-sdk_8          # .NET 8 SDK
powershell            # PowerShell Core

# Databases
postgresql            # PostgreSQL client
mariadb.client        # MariaDB/MySQL client
redis                 # Redis client
dbeaver-bin           # Database GUI

# Cloud & Infrastructure
awscli2               # AWS CLI v2
opentofu              # OpenTofu (Terraform alternative)
terraform-docs        # Terraform documentation generator
packer                # Image building tool
spacectl              # Spacelift CLI

# Development Tools
gh                    # GitHub CLI
github-copilot-cli    # GitHub Copilot CLI
pre-commit            # Pre-commit hooks
detect-secrets        # Secret detection
vscode                # VS Code
vscodium              # VS Code OSS
jetbrains.webstorm    # WebStorm IDE

# System Tools
jq                    # JSON processor
watch                 # Command monitoring
wget                  # HTTP client
speedtest-cli         # Network speed testing
sshfs                 # SSH filesystem
rclone                # Cloud storage sync
```

### Shell Configuration
```bash
# Environment Variables
BROWSER="firefox"      # Advisory preference for programs that honor it
TERMINAL="alacritty"   # Default terminal
EDITOR="nvim"          # Default editor
VIDEO="mpv"            # Default video player
PATH="$PATH:/opt/homebrew/bin"  # Include Homebrew binaries

# Aliases
e="nvim"              # Quick editor
gs="git status"       # Git shortcuts
tf="tofu"             # OpenTofu shortcuts
ll="ls -l"            # Detailed listing
```

On Darwin, Nix Firefox is an application bundle, not a `bin/firefox` shell
command. Use `open -a Firefox -- URL` or the managed app picker.
`BROWSER=firefox` is advisory and does not control `/usr/bin/open`; macOS uses
LaunchServices for URLs opened by other applications. The managed Firefox
module registers the current bundle after each Home Manager generation. See
`docs/firefox-url-launcher.md` for rebuild and update checks.

## Package Management Strategy

### Nix Packages
**Primary packages** installed via Nix for:
- Development tools and utilities
- Command-line applications
- Cross-platform software
- Version-controlled installations

### Homebrew Casks
**GUI applications** installed via Homebrew for:
- macOS-native applications
- Apps requiring system integration
- Applications not available or problematic in Nix

**Current Homebrew Applications:**
```nix
brews = [
  "choose-gui"          # GUI fuzzy chooser (used by rbw-choose)
];

casks = [
  "1password"           # Password manager
  "1password-cli"       # 1Password CLI
  "crystalfetch"        # macOS download tool
  "docker-desktop"      # Docker Desktop
  "gimp"                # Image editor
  "handy"               # Handy
  "keybase"             # Keybase
  "macfuse"             # FUSE for macOS
  "mullvad-vpn"         # Mullvad VPN client
  "nextcloud"           # Nextcloud sync client
  "openvpn-connect"     # OpenVPN client
  "retroarch"           # Retro gaming (nixpkgs version broken on aarch64)
  "signal"              # Signal messenger (not in nixpkgs aarch64-darwin)
  "yubico-authenticator" # YubiKey authenticator
];
```

### Homebrew Tap Trust (brew 6.x)

brew 6.0 introduced third-party tap trust enforcement. Third-party taps used by
this config are declared in `home.file.".homebrew/trust.json"` (`home.nix`) so
fresh installs don't require a manual `brew trust` step:

```nix
home.file.".homebrew/trust.json".text = builtins.toJSON {
  trustedtaps = [ "osx-cross/arm" "osx-cross/avr" "qmk/qmk" ];
};
```

Trust file location: `~/.homebrew/trust.json` (resolved from `$HOMEBREW_USER_CONFIG_HOME`).

## Secure Backup System

### Configuration
```nix
services.darwinBackupService = {
  enable = true;
  interval = 86400;  # 24-hour intervals
};
```

### Backup Features
- **SOPS Integration:** Restic credentials encrypted with SOPS/age
- **Automated Schedule:** Daily backups via launchd
- **Smart Exclusions:** Automatically excludes caches, logs, and temporary files
- **Remote Storage:** Backs up to configured remote repository

### Excluded Paths
```nix
excludePaths = [
  "*/Library/Caches"    # System caches
  "*/Library/Logs"      # System logs
  "*/.Trash"            # Trash folders
  "*/Downloads"         # Downloads folder
  "*/.cache"            # User caches
  "*/node_modules"      # Node.js dependencies
  "*/.npm"              # npm cache
  "*/.nix-*"            # Nix temporary files
  "*/Applications"      # Applications folder
  "*/Library/CloudStorage" # Cloud storage folders
];
```

## Security Configuration

### SOPS Integration
```nix
sops = {
  age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  defaultSopsFile = ../../secrets/secrets.yaml;
};
```

### System Security
```nix
security.sudo.extraConfig = ''
  cameronstevenson ALL=(ALL) NOPASSWD: ALL  # Passwordless sudo
'';
```

### Services
- **Tailscale:** Private network connectivity (`services.tailscale.enable = true`)

## Theming & Appearance

### Color Scheme: Carbonfox Fixed
Custom color scheme based on IBM's Carbon design system:
```nix
colorScheme = {
  slug = "carbonfox-fixed";
  name = "Carbonfox Fixed";
  palette = {
    base00 = "#161616";  # Background
    base01 = "#262626";  # Lighter background
    base05 = "#f2f4f8";  # Foreground
    base08 = "#ff7eb6";  # Red
    base0B = "#42be65";  # Green
    base0D = "#33b1ff";  # Blue
    # ... (complete palette defined)
  };
};
```

## File Organization

```
hosts/mbp/
├── configuration.nix    # Main system configuration
├── home.nix            # Home Manager configuration
├── yabai.nix           # Window manager config
├── skhd.nix            # Keyboard shortcuts
├── homebrew.nix        # Homebrew packages
├── alacritty.nix       # Terminal configuration
├── firefox.nix         # Firefox configuration
├── git.nix             # Git settings
└── rbw-choose.nix      # Password manager integration
```

## Firefox URL Handler (opening links from terminal / other apps)

### Symptom

Clicking a link in Alacritty (or any `open https://...`) fails to open Firefox,
or opens Firefox without the URL. This tends to **recur after Firefox version
bumps** - the link "becomes unlinked" again.

### Root cause

Two macOS-specific problems compound:

1. **Duplicate bundle identifiers.** Every nixpkgs `Firefox.app` uses the same
   `CFBundleIdentifier` (`org.nixos.firefox`). Each rebuild that bumps Firefox
   adds another `Firefox.app` to the Nix store, all sharing that id. Over time
   LaunchServices knows many bundles with the same id across live and
   garbage-collected store paths, and resolves `https`/`http` to a dead or
   wrong one.
2. **Arg-dropping trampoline.** `mac-app-util` generates an AppleScript
   trampoline (`~/Applications/Home Manager Apps/Firefox.app`) that runs
   `open '<hardcoded store path>'` with no `"$@"` forwarding, so the URL is
   dropped and the hardcoded path goes stale after the next update. This is
   upstream issue [hraban/mac-app-util#17](https://github.com/hraban/mac-app-util/issues/17)
   (also surfaces as #38, "Open With" from Finder failing).

"Just use the defaults" does not fix it: the default **is** the arg-dropping
trampoline plus duplicate ids. A one-time LaunchServices rebuild only helps
until the next Firefox bump.

### Current solution

Home Manager removes the mac-app-util Firefox wrapper after linking the current
generation, then registers a stable declarative `Firefox.app` with
bundle ID `org.nixos.firefox-launcher`. The launcher forwards URL arguments to
the current managed Firefox binary and remains valid across store-path updates.

Alacritty URL hints separately discover URLs with a regex or OSC 8 hyperlink,
then pass the selected URL to `/usr/bin/open`. Rendered regex must contain
`\s`, not `\\s`; the latter truncates URLs at `s` characters. See
`docs/firefox-url-launcher.md` for long Wiz-style fragment caveats.

If a stale Homebrew cask remains, remove it once:

```sh
brew uninstall --cask firefox
```

Then start a new shell. `BROWSER=firefox` remains an advisory preference for
programs that honor it; it does not control `/usr/bin/open` or links from other
applications.

If `open URL` still uses an older Firefox bundle, select Firefox in System
Settings > Desktop & Dock > Default web browser. A reboot is not required;
quit and reopen Firefox and the application sending the URL.

### Alternative considered

Upstream's `github:hraban/mac-app-util/link-contents` branch has reports of
fixing #17 by symlinking `Contents/`, but it remains unmerged and its maintainer
reported Launchpad, Spotlight, and icon regressions. It is not pinned here.

## Firefox Profile (data appears "missing" after updates)

### Symptom

Firefox opens with a blank profile - no bookmarks, extensions, history or
logins - typically **after a Firefox version bump**. The data is not actually
lost; Firefox is just opening the wrong profile.

### Root cause

Firefox 67+ uses a "dedicated profile per installation": it keys the chosen
profile on a hash of the install path via `installs.ini`. Every Nix Firefox
version bump produces a **new store path**, which Firefox sees as a brand-new
installation. With no matching `installs.ini` entry (home-manager writes
`profiles.ini` but not `installs.ini`), Firefox can ignore the `Default=1`
profile and create a fresh empty `*.default` profile instead of the real one.

On this machine the real profile is:

```
~/Library/Application Support/Firefox/Profiles/cameron   # ~1.2 GB, real data
~/Library/Application Support/Firefox/Profiles/4k8v93j4.default   # stray, empty
```

Note: this is a macOS profile-selection problem, NOT a path problem. Do not try
to move data to `~/.config`: home-manager's `.mozilla` -> `~/.config/mozilla`
XDG migration is **Linux-only**. On macOS, Firefox reads
`~/Library/Application Support/Firefox` and nothing else; forcing `.config`
would hide the profile entirely. A leftover `~/.mozilla/firefox` on macOS is
inert legacy split-brain and can be removed.

### Permanent solution (implemented in `firefox.nix`)

Firefox profile mapping remains stable through `profileVersion = 2` and
`profiles.cameron.storeId`. The launcher does not force `-P`; Firefox receives
normal URL arguments and selects its configured profile state.

### Cleaning up the stray profile

The empty `*.default` profile and the legacy `~/.mozilla/firefox` directory are
safe to remove once you have confirmed the real profile loads. See
`scripts/firefox-cleanup.sh`.

## Module Imports

### Home Manager Modules
- `../../modules/home-manager/cli` - CLI tool configurations
- `../../modules/home-manager/darwin-secure-backup.nix` - Backup service
- `./firefox.nix` - Browser configuration
- `./rbw-choose.nix` - Password manager
- `./git.nix` - Git configuration
- `./alacritty.nix` - Terminal configuration

### External Inputs
- `mac-app-util.homeModules.default` - macOS app utilities
- `nix-colors.homeModules.default` - Color scheme support
- `nixvim.homeModules.nixvim` - Neovim configuration

## Usage Patterns

### Daily Workflow
1. **Terminal Access:** `cmd + return` opens Alacritty
2. **Window Management:** Vim-style navigation with cmd+hjkl
3. **Workspace Organization:** Dedicated spaces for different tasks
4. **Quick Access:** Shortcuts for common applications and password manager
5. **Notes:** Quick scratchpad access with `cmd + shift + n`

### Development Workflow
1. **Project Navigation:** Integrated terminal and editor shortcuts
2. **Git Integration:** Shell aliases for common Git operations
3. **Cloud Tools:** AWS, Terraform, and other DevOps tools readily available
4. **Database Access:** Multiple database clients and tools
5. **Code Quality:** Pre-commit hooks and linting tools configured

## Troubleshooting

### Common Issues
1. **Yabai SIP Requirements:** May require System Integrity Protection adjustments
2. **Homebrew Path:** Ensure `/opt/homebrew/bin` is in PATH
3. **SOPS Keys:** Verify age key exists at `~/.config/sops/age/keys.txt`
4. **Window Rules:** Check `yabai -m rule --list` for current window rules
5. **brew 6.x tap trust:** Third-party taps blocked with "Refusing to load formula from untrusted tap". Trust is declared declaratively in `home.nix`; on a fresh machine run `darwin-rebuild switch` once to write the trust file before `brew bundle` runs, or `brew trust <tap>` manually.

### Key Files
- **System Config:** `hosts/mbp/configuration.nix:191` (hostname)
- **User Setup:** `hosts/mbp/configuration.nix:74-77` (user configuration)
- **Backup Config:** `hosts/mbp/home.nix:18-33` (backup service)
- **Keyboard Map:** `hosts/mbp/configuration.nix:101-105` (hardware remapping)

## Build Commands

```bash
# Build and activate system configuration
darwin-rebuild switch --flake .#mbp

# Build without activation
darwin-rebuild build --flake .#mbp

# Check configuration
nix flake check
```

---

*This configuration provides a powerful, Unix-like development environment on macOS with advanced window management, comprehensive tooling, and secure backup capabilities.*
