# Backup Strategy Documentation

This document describes the backup strategy implemented across all hosts in the nix-config repository.

## Overview

The backup system uses [Restic](https://restic.net/) to create encrypted, deduplicated backups to an OpenStack Swift object storage backend. Each host backs up to its own repository path to maintain separation and organization.

## Architecture

### Repository Structure
```
swift://container/hostname/
├── workstation/     # Workstation host backups
├── ideapad/         # Ideapad laptop backups
├── mbp/             # MacBook Pro backups
└── nix-server/      # Server backups (separate ZFS setup)
```

### Credential Management
All backup credentials are managed through:
- **rbw (Bitwarden CLI)** for credential retrieval
- **SOPS** for credential storage and encryption
- **OpenStack Application Credentials** for Swift authentication

Required credentials in rbw:
- `openstack-restic`: OpenStack application credentials
  - `username`: Application credential ID
  - `password`: Application credential secret
  - `os_auth_url`: OpenStack auth URL
- `restic-backups`: Restic repository settings
  - `password`: Repository encryption password
  - `repository`: Swift container URL

## Host-Specific Configurations

### Linux Hosts (workstation, ideapad)

**Service**: systemd user service with timer
**Schedule**: Daily at startup + 10 minutes, then every 24 hours
**Configuration**: `modules/home-manager/services/backup.nix`

```nix
backupService.enable = true;
```

**Backup Script**: `modules/home-manager/pkgs/backup.nix`
- Backs up entire `$HOME` directory
- Excludes cache directories automatically (`--exclude-caches`)
- Determines hostname dynamically

### macOS Host (mbp)

**Service**: launchd user agent
**Schedule**: Daily (86400 seconds interval)
**Configuration**: `modules/home-manager/darwin-backup.nix`

```nix
darwinBackupService.enable = true;
```

**Backup Script**: `modules/home-manager/pkgs/darwin-backup.nix`
- Backs up `$HOME` directory with macOS-specific exclusions:
  - `~/Library/Caches`
  - `~/Library/Logs` 
  - `~/.Trash`
  - `~/Downloads`
  - `~/.cache`
  - `~/node_modules`
  - `~/.npm`
  - `~/.nix-*`

### Server Host (nix-server)

**Service**: systemd service with ZFS integration
**Schedule**: Daily via systemd timer
**Storage**: Local ZFS snapshots + Restic to Swift

Configured separately in host-specific configuration.

## Backup Process

Each backup run performs the following steps:

1. **Repository Initialization**: Creates repository if it doesn't exist
2. **Integrity Check**: Verifies repository health (5% data sample)
3. **Backup Execution**: Creates new snapshot with exclusions
4. **Retention Policy**: Keeps 7 daily, 4 weekly, 3 monthly, 1 yearly
5. **Verification**: Validates latest snapshot (1% data sample)
6. **Statistics**: Reports backup size and deduplication info
7. **Logging**: Records results with timestamp

## Monitoring and Verification

### Automated Checks
- Pre-backup repository integrity verification
- Post-backup snapshot validation
- Error handling with exit codes
- Comprehensive logging

### Manual Verification
```bash
# Check backup status
systemctl --user status backup.service     # Linux
launchctl list | grep backup               # macOS

# View logs
journalctl --user -u backup.service        # Linux
tail ~/Library/Logs/backup.log             # macOS

# List snapshots
restic snapshots

# Verify repository
restic check

# Restore files
restic restore latest --target ~/restore/
```

## Disaster Recovery

### Full System Recovery

1. **Install base system** (NixOS/nix-darwin)
2. **Setup credentials**:
   ```bash
   # Install rbw and configure
   rbw register
   rbw unlock
   ```
3. **Restore configuration**:
   ```bash
   # Clone nix-config repository
   git clone https://github.com/username/nix-config.git
   cd nix-config
   
   # Apply configuration
   home-manager switch --flake .#hostname
   ```
4. **Restore user data**:
   ```bash
   # Set environment variables (or run through rbw)
   export RESTIC_REPOSITORY="swift://container/hostname"
   export RESTIC_PASSWORD="$(rbw get --field password restic-backups)"
   
   # List available snapshots
   restic snapshots
   
   # Restore latest snapshot
   restic restore latest --target $HOME
   ```

### Partial Recovery

```bash
# Restore specific files/directories
restic restore latest --target /tmp/restore --include "$HOME/Documents"

# Restore from specific snapshot
restic restore abc123def --target /tmp/restore
```

## Security Considerations

### Encryption
- **Repository encryption**: AES-256 with scrypt key derivation
- **Credential encryption**: SOPS with age keys
- **Transport encryption**: HTTPS for Swift API

### Access Control
- Application credentials with minimal Swift permissions
- Repository passwords stored in encrypted form
- Age keys for SOPS decryption stored securely

### Best Practices
- Regular credential rotation (quarterly recommended)
- Repository integrity checks before each backup
- Separate repositories per host for isolation
- Exclude sensitive cache and temporary files

## Troubleshooting

### Common Issues

**Repository locked**:
```bash
restic unlock
```

**Permission denied**:
```bash
# Check credentials
rbw get openstack-restic
rbw get restic-backups
```

**Backup fails**:
```bash
# Check repository integrity
restic check

# Manual backup with verbose output
restic backup $HOME --verbose
```

**Service not running**:
```bash
# Linux
systemctl --user enable backup.timer
systemctl --user start backup.timer

# macOS
launchctl load ~/Library/LaunchAgents/backup.service.plist
```

### Log Locations
- **Linux**: `journalctl --user -u backup.service`
- **macOS**: `~/Library/Logs/backup.log`
- **Manual runs**: stdout/stderr

## Maintenance Tasks

### Weekly
- Review backup logs for errors
- Verify recent snapshots exist

### Monthly  
- Run full repository integrity check:
  ```bash
  restic check --read-data
  ```
- Review storage usage and retention policy

### Quarterly
- Rotate OpenStack application credentials
- Test disaster recovery procedures
- Update backup exclusion patterns if needed

## Future Enhancements

### Planned Improvements
- [ ] Backup health monitoring dashboard
- [ ] Automated disaster recovery testing
- [ ] Cross-host backup verification
- [ ] Backup performance optimization
- [ ] Cloud storage cost monitoring

### Integration Opportunities
- Home Assistant backup status notifications
- Prometheus metrics for backup monitoring  
- Grafana dashboard for backup analytics
- Automated backup testing pipeline

## References

- [Restic Documentation](https://restic.readthedocs.io/)
- [OpenStack Swift API](https://docs.openstack.org/swift/latest/)
- [rbw Bitwarden CLI](https://github.com/doy/rbw)
- [SOPS Documentation](https://github.com/mozilla/sops)