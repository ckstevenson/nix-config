# Nix-Server Host Configuration

The **nix-server** host represents a comprehensive home server infrastructure, functioning as a centralized hub for home automation, media services, data storage, monitoring, and backup operations.

## 🏠 System Overview

### Hardware Profile
- **Platform**: x86_64 Intel-based server/workstation
- **Storage**: 
  - Boot: UEFI EFI system partition
  - Root: ext4 filesystem
  - **ZFS Pools**: `apps` and `tank` for application data and media storage
- **Network**: Multiple Ethernet interfaces with bridge configuration
- **CPU**: Intel processor with hardware acceleration for media transcoding
- **Form Factor**: Always-on home server with 24/7 operation

### Primary Functions
This host serves as the **central home infrastructure hub**, providing:

1. **🏡 Home Automation**: Complete Home Assistant setup with device integration
2. **📁 File Services**: Nextcloud for personal cloud storage and synchronization
3. **🎥 Media Services**: Jellyfin with hardware-accelerated transcoding
4. **📊 Monitoring**: Prometheus metrics collection and system monitoring
5. **🔒 Backup Services**: Comprehensive ZFS snapshots and offsite backup
6. **🐳 Containerization**: Docker-based service deployment and management
7. **🔗 Remote Access**: Tailscale VPN for secure remote connectivity

## 🏗️ Architecture & Core Services

### ZFS Storage Architecture
```nix
# Multi-pool ZFS configuration
boot.zfs.extraPools = [
  "apps"    # Application data and containers
  "tank"    # Media storage and user data
];

services.zfs = {
  autoScrub.enable = true;  # Data integrity verification
  trim.enable = true;       # SSD optimization
};
```

#### ZFS Pool Layout
- **`apps` Pool**: Docker containers, application state, system services
- **`tank` Pool**: Media files, pictures, user documents, Nextcloud storage

#### Automated Snapshots (Sanoid)
```nix
services.sanoid = {
  datasets = {
    apps = {
      recursive = true;
      useTemplate = [ "apps" ];
      # hourly = 1, daily = 7, monthly = 3, yearly = 1
    };
    tank = {
      recursive = true;
      useTemplate = [ "tank" ];
      # daily = 7, monthly = 1, yearly = 1
    };
  };
};
```

### Docker Infrastructure
```nix
virtualisation.docker = {
  enable = true;
  autoPrune.enable = true;
  rootless = {
    enable = true;
    setSocketVariable = true;
  };
  storageDriver = "zfs";  # Leverage ZFS for container storage
};
```

#### Service Architecture
- **Storage Backend**: ZFS provides copy-on-write, snapshots, and compression
- **Container Management**: Docker with ZFS storage driver for efficiency
- **User Isolation**: Rootless Docker for enhanced security
- **Resource Management**: Automatic pruning of unused containers and images

## 🏡 Home Automation (Home Assistant)

### Core Components
```nix
services.home-assistant = {
  enable = true;
  extraComponents = [
    "esphome"     # ESP device integration
    "mqtt"        # Message queue telemetry transport
    "onvif"       # IP camera support
    "tasmota"     # Tasmota device integration
    "unifi"       # UniFi network device monitoring
    "zha"         # Zigbee Home Automation
    "mobile_app"  # Mobile device integration
  ];
};
```

### Custom Integrations
```nix
customComponents = [
  # Bambu Lab 3D Printer Integration
  (pkgs.buildHomeAssistantComponent rec {
    owner = "greghesp";
    domain = "bambu_lab";
    version = "2.0.21";
  })
];
```

### MQTT Broker (Mosquitto)
```nix
services.mosquitto = {
  enable = true;
  listeners = [{
    users = {
      ha = {
        acl = [ "readwrite #" ];
        hashedPasswordFile = "/var/lib/mosquitto/ha-passwd";  # SOPS-encrypted
      };
    };
  }];
};
```

### ESPHome Integration
```nix
services.esphome = {
  enable = true;
  address = "0.0.0.0";  # Available on all interfaces
};
```

### Smart Home Automations

#### Lighting Control
- **IKEA TRADFRI Integration**: Multiple smart bulbs with brightness control
- **Remote Control**: Zigbee remote for living room scene control
- **Auto Scenes**: Single-press full brightness, double-press dim to 10%

#### Energy Management
- **Smart Plugs**: Desk and media center power monitoring
- **Auto Power-off**: Automatic shutdown during night hours when usage < 20W
- **Linked Devices**: Synchronized plug control for related devices

#### Fuel Price Monitoring
- **Tankerkoenig Integration**: Real-time gasoline prices from local stations
- **Price Alerts**: Push notifications when fuel drops below €1.60
- **Multi-station Monitoring**: 8 local gas stations tracked

#### Mobile Notifications
```nix
script = [
  {
    notify_cameron = { /* Individual notification script */ };
    notify_all = { /* Broadcast notification script */ };
  }
];
```

## 📊 Monitoring & Observability

### Prometheus Metrics Collection
```nix
services.prometheus.exporters = {
  node = {
    enable = true;
    enabledCollectors = [ "systemd" ];
    listenAddress = "172.17.0.1";  # Docker bridge interface
  };
  smartctl.enable = true;  # Drive health monitoring
  zfs.enable = true;       # ZFS pool metrics
};
```

### Container Monitoring
```nix
services.cadvisor = {
  enable = true;
  listenAddress = "172.17.0.1";
  port = 8081;
};
```

### Health Monitoring
```nix
systemd.services.healthcheck = {
  script = ''
    curl https://hc-ping.com/ac5d987d-e26d-402a-8e68-4861dab9607d
  '';
};
# Runs every minute via systemd timer
```

## 💾 Backup Strategy

### ZFS Snapshot-Based Backups
```bash
# Daily backup process via systemd service
systemd.services.backup = {
  script = ''
    # Create consistent snapshots
    zfs snapshot tank/pictures@backup
    zfs snapshot apps/docker@backup
    zfs snapshot apps/images@backup
    
    # Backup via read-only snapshot mount points
    restic backup /mnt/pictures/.zfs/snapshot/backup/
    restic backup /var/lib/docker/.zfs/snapshot/backup/
    restic backup /var/lib/mosquitto
    restic backup /var/lib/hass
    restic backup /etc/nixos
    restic backup /srv/docker
    
    # Cleanup snapshots
    zfs destroy tank/pictures@backup
    zfs destroy apps/images@backup
    zfs destroy apps/docker@backup
    
    # Retention policy
    restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 1 --prune
  '';
};
```

### SOPS Secret Management
```nix
sops = {
  defaultSopsFile = ../../secrets/services/home-assistant.yaml;
  age.keyFile = "/home/cameron/.config/sops/age/keys.txt";
  secrets."mosquitto/password" = {
    owner = "mosquitto";
    path = "/var/lib/mosquitto/ha-passwd";
  };
};
```

## 🌐 Network Configuration

### Advanced Networking
```nix
networking = {
  enableIPv6 = false;      # Simplified IPv4-only setup
  firewall.enable = false; # Custom firewall via Docker/containers
  hostId = "b3a2c54b";     # ZFS requirement
  hostName = "nix-server";
  
  # Network bridge for container networking
  bridges.br0.interfaces = [ "enp4s0f1" ];
  
  networkmanager = {
    enable = true;
    unmanaged = [ "tailscale0" ];  # Exclude VPN interface
  };
};
```

### VPN Integration
```nix
services.tailscale.enable = true;
```
- **Tailscale**: Mesh VPN for secure remote access
- **Zero-config**: Automatic peer discovery and connection
- **Cross-platform**: Access from mobile devices and other hosts

## 🎥 Media Services

### Hardware Acceleration
```nix
# Intel GPU support for Jellyfin transcoding
nixpkgs.config.packageOverrides = pkgs: {
  vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
};

hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver      # Modern Intel GPU driver
    vaapiIntel             # VA-API support
    vaapiVdpau             # Video decode API
    libvdpau-va-gl         # OpenGL integration
    intel-compute-runtime   # OpenCL for advanced filtering
  ];
};
```

### Service Integration
- **Jellyfin**: Self-hosted media server (via Docker)
- **Hardware Transcoding**: Intel QuickSync for efficient video processing
- **Storage**: Media files stored on ZFS `tank` pool
- **Remote Access**: Available via Tailscale VPN

## 🔄 Automated Operations

### Systemd Services & Timers

#### Daily Operations
```nix
systemd.timers = {
  backup = {
    timerConfig.OnCalendar = "*-*-* 00:00:00";  # Daily at midnight
  };
  nextcloud-preview = {
    timerConfig.OnCalendar = "*-*-* 00:00:00";  # Daily preview generation
  };
  healthcheck = {
    timerConfig.OnCalendar = "*-*-* *:*:00";    # Every minute
  };
};
```

#### Nextcloud Maintenance
```nix
systemd.services = {
  nextcloud-preview = {
    script = ''
      docker exec -u www-data nextcloud /var/www/html/occ preview:pre-generate
    '';
  };
  nextcloud-cron = {
    script = ''
      docker exec -u www-data nextcloud php cron.php
    '';
  };
};
```

### User Management
```nix
users = {
  groups = {
    pictures = {};  # Media file access
    media = {};     # Media service access
  };
  users = {
    cameron = {
      extraGroups = [ "networkmanager" "wheel" "docker" "pictures" "media" ];
    };
    docker = {
      # Dedicated user for Docker services
      home = "/srv/docker/";
      extraGroups = [ "video" "media" "pictures" ];
      openssh.authorizedKeys.keys = [ /* SSH key for automation */ ];
    };
  };
};
```

## 🛡️ Security Configuration

### SSH Access
```nix
sshd.enable = true;
```
- **Key-based Authentication**: SSH keys for secure remote access
- **Dedicated Service User**: Separate Docker user with limited privileges
- **Network Isolation**: Services bound to specific interfaces

### Storage Security
- **ZFS Encryption**: Available for sensitive data pools
- **SOPS Integration**: Encrypted secrets management
- **Backup Encryption**: All backups encrypted with restic
- **Network Segmentation**: Docker containers isolated from host network

### Monitoring Security
- **Health Checks**: External monitoring via healthchecks.io
- **Drive Monitoring**: SMART data collection for early failure detection
- **System Metrics**: Comprehensive monitoring of all system components

## 🔧 Service Management

### Docker Service Deployment
```bash
# Services typically deployed in /srv/docker/
/srv/docker/
├── nextcloud/           # Personal cloud storage
├── jellyfin/           # Media server
├── prometheus/         # Metrics collection
├── grafana/           # Monitoring dashboards
└── ...                # Additional containerized services
```

### Home Assistant Management
```bash
# Home Assistant service control
sudo systemctl status home-assistant
sudo systemctl restart home-assistant

# Configuration location
/var/lib/hass/

# View logs
journalctl -u home-assistant -f
```

### ZFS Operations
```bash
# Pool status
zpool status apps tank

# Snapshot management
zfs list -t snapshot
zfs snapshot tank/pictures@manual-$(date +%Y%m%d)

# Scrub operations
zpool scrub apps tank
zpool status  # Check scrub progress
```

## 🚀 Common Usage Patterns

### Home Automation Workflow
1. **Device Integration**: Add new smart devices via Home Assistant
2. **MQTT Configuration**: Configure device communication through Mosquitto
3. **Automation Creation**: Define rules and scenes for device interaction
4. **Mobile Integration**: Configure notifications and remote control
5. **Monitoring**: Track device status and energy usage

### Media Server Management
1. **Content Addition**: Add media files to ZFS `tank` pool
2. **Library Scan**: Jellyfin automatically indexes new content
3. **Transcoding**: Hardware acceleration handles format conversion
4. **Remote Access**: Stream content via Tailscale VPN
5. **Backup**: Media files included in daily ZFS snapshot backup

### System Maintenance
1. **Daily Backups**: Automated ZFS snapshots and offsite backup
2. **Health Monitoring**: Continuous system and service monitoring
3. **Updates**: NixOS system updates with rollback capability
4. **Maintenance**: Regular ZFS scrubbing and SMART drive checks

## 📁 File Structure

```
hosts/nix-server/
├── configuration.nix           # Main system configuration
├── hardware-configuration.nix  # Hardware-specific settings
├── home-assistant.nix          # Complete HA setup
├── home.nix                   # User environment
└── README.md                  # This documentation

/srv/docker/                   # Docker service data
├── nextcloud/                 # Cloud storage service
├── jellyfin/                  # Media server data
└── ...                       # Additional services

/var/lib/
├── hass/                     # Home Assistant data
├── mosquitto/                # MQTT broker data
└── docker/                   # Docker system data (on ZFS)
```

## 🔍 Troubleshooting

### ZFS Issues
```bash
# Check pool health
zpool status -v

# Import pools after reboot (if needed)
zpool import apps
zpool import tank

# Snapshot troubleshooting
zfs list -t snapshot | grep backup
zfs destroy tank/pictures@stuck-snapshot
```

### Home Assistant Debugging
```bash
# Service status
sudo systemctl status home-assistant

# Configuration check
sudo -u hass hass --script check_config -c /var/lib/hass

# Integration logs
journalctl -u home-assistant | grep mqtt
journalctl -u home-assistant | grep zha
```

### Docker Service Issues
```bash
# Container status
docker ps -a
docker logs container-name

# Service user debugging
sudo -u docker docker ps
sudo -u docker docker-compose -f /srv/docker/service/docker-compose.yml logs
```

### Network Connectivity
```bash
# Tailscale status
sudo tailscale status
sudo tailscale ping other-device

# Bridge configuration
ip link show br0
brctl show
```

### Backup Verification
```bash
# Check backup service
systemctl status backup.service
journalctl -u backup.service | tail -20

# Manual backup test
sudo -u root restic snapshots --repo $RESTIC_REPOSITORY
sudo -u root restic check --repo $RESTIC_REPOSITORY
```

## 🎯 Performance Optimization

### ZFS Tuning
- **ARC Cache**: Optimized for server workload with sufficient RAM
- **Compression**: LZ4 compression enabled for space efficiency
- **Recordsize**: Tuned for different workloads (media vs. databases)
- **Deduplication**: Selective use based on data patterns

### Media Performance
- **Hardware Acceleration**: Intel QuickSync reduces CPU load
- **Storage**: ZFS provides consistent performance for large files
- **Network**: Gigabit Ethernet ensures smooth streaming
- **Caching**: SSD-based ZFS cache devices for hot data

### Container Optimization
- **ZFS Storage Driver**: Native ZFS integration for containers
- **Resource Limits**: Appropriate CPU and memory constraints
- **Network**: Optimized Docker networking with custom bridges
- **Security**: Rootless containers for enhanced isolation

## 🔗 Integration Points

### Cross-Host Services
- **Backup Destination**: Receives backups from other hosts
- **Media Source**: Serves content to all network devices
- **Monitoring Hub**: Collects metrics from entire infrastructure
- **Automation Center**: Controls smart home devices for all residents

### External Services
- **Tailscale**: Secure remote access mesh network
- **Healthchecks.io**: External monitoring and alerting
- **Mobile Apps**: Home Assistant companion apps
- **Cloud Backup**: Offsite backup storage via restic

---

*This configuration represents a complete home server infrastructure, providing automation, media services, monitoring, and backup capabilities for a modern smart home environment.*