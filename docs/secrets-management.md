# Secrets Management

This document describes the secrets management strategy for the nix-config repository using SOPS (Secrets OPerationS) with age encryption.

## Overview

The secrets management system has been enhanced with the following improvements:

- **Per-host secrets organization**: Separate files for each host's specific secrets
- **Service-specific secrets**: Dedicated files for shared services
- **Multiple encryption keys**: Different age keys for different security domains
- **Better organization**: Clear separation of concerns and improved maintainability

## Directory Structure

```
secrets/
├── .sops.yaml              # SOPS configuration with encryption rules
├── hosts/                  # Host-specific secrets
│   ├── mbp.yaml           # MacBook Pro secrets (dev environment)
│   ├── nix-server.yaml    # Server secrets (production services)
│   ├── workstation.yaml   # Desktop secrets (personal use)
│   └── ideapad.yaml       # Laptop secrets (mobile use)
├── services/              # Service-specific secrets
│   └── home-assistant.yaml # Home Assistant and MQTT secrets
└── secrets.yaml           # Legacy file (to be removed after migration)
```

## Encryption Strategy

### Age Keys

Each host should have its own age key for security isolation:

- `nix-server`: Production server key (existing)
- `mbp`: Development environment key (to be generated)
- `workstation`: Desktop key (to be generated)
- `ideapad`: Laptop key (to be generated)
- Recovery key: Offline backup key (to be generated)

### Key Locations

Age keys are stored at: `~/.config/sops/age/keys.txt`

## Migration from Old Structure

The old `secrets/secrets.yaml` file contained all secrets in a single file with one age key. To migrate to the new structure:

### On nix-server (with access to age keys):

1. Run the migration script:
   ```bash
   cd /etc/nixos  # or wherever your nix-config is
   ./scripts/migrate-secrets.sh
   ```

2. Test the new configuration:
   ```bash
   sudo nixos-rebuild test
   ```

3. If successful, apply the changes:
   ```bash
   sudo nixos-rebuild switch
   ```

4. After confirming everything works, remove the old file:
   ```bash
   rm secrets/secrets.yaml
   ```

## Adding New Secrets

### For Host-Specific Secrets

1. Edit the appropriate host file:
   ```bash
   sops secrets/hosts/nix-server.yaml
   ```

2. Add your secret in the appropriate section:
   ```yaml
   api_keys:
     some_service: "your-secret-here"
   ```

### For Service-Specific Secrets

1. Edit the service file:
   ```bash
   sops secrets/services/home-assistant.yaml
   ```

2. Add secrets under the appropriate service:
   ```yaml
   home_assistant:
     api_key: "your-ha-api-key"
   ```

## Using Secrets in Nix Configurations

### In NixOS Configuration

```nix
{
  sops = {
    defaultSopsFile = ../../secrets/hosts/nix-server.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/cameron/.config/sops/age/keys.txt";

    secrets = {
      "api_keys/some_service" = {
        owner = "some-user";
        path = "/var/lib/service/api-key";
      };
    };
  };
}
```

### In Home Manager Configuration

```nix
{
  sops = {
    defaultSopsFile = ../../secrets/hosts/mbp.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      "personal/ssh_key" = {
        path = "${config.home.homeDirectory}/.ssh/personal_key";
      };
    };
  };
}
```

## Key Management

### Generating New Age Keys

```bash
# Generate a new age key
age-keygen -o ~/.config/sops/age/keys.txt

# Get the public key for .sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt
```

### Updating Encryption Keys

When adding a new key to a secrets file:

1. Add the public key to `.sops.yaml` in the appropriate rule
2. Re-encrypt the file with the new key:
   ```bash
   sops updatekeys secrets/hosts/nix-server.yaml
   ```

## Security Best Practices

1. **Separate Keys**: Each host should have its own age key
2. **Backup Keys**: Always maintain a secure offline backup of age keys
3. **Key Rotation**: Rotate age keys periodically
4. **Access Control**: Limit who has access to age keys
5. **Audit Trail**: Track who accesses and modifies secrets

## File Organization Guidelines

### Host Secrets (secrets/hosts/)

- **Network credentials**: WiFi passwords, VPN configurations
- **API keys**: Host-specific service integrations
- **Personal secrets**: User-specific credentials and keys
- **Backup credentials**: Restic passwords, cloud storage keys

### Service Secrets (secrets/services/)

- **Service passwords**: Database passwords, service accounts
- **Integration keys**: API keys shared across hosts
- **Webhook secrets**: Service-to-service authentication
- **Certificates**: TLS certificates and keys

## Troubleshooting

### Cannot Decrypt Secrets

1. Check if age key exists: `ls -la ~/.config/sops/age/keys.txt`
2. Verify key permissions: `chmod 600 ~/.config/sops/age/keys.txt`
3. Test decryption manually: `sops -d secrets/hosts/nix-server.yaml`

### SOPS Configuration Issues

1. Verify `.sops.yaml` syntax: `sops -d secrets/hosts/nix-server.yaml`
2. Check if your age key is in the encryption rules
3. Ensure file paths in `.sops.yaml` match your secrets structure

### Migration Issues

1. Make sure you're running the migration script on the host with age keys
2. Verify the old secrets file can be decrypted before migration
3. Check that SOPS is available on the system

## Future Enhancements

- [ ] Implement automatic key rotation
- [ ] Add secrets validation in CI/CD
- [ ] Create secrets backup strategy
- [ ] Implement secrets audit logging
- [ ] Add support for hardware security keys
