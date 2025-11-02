{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.darwinBackupService;
in
{
  options.services.darwinBackupService = {
    enable = mkEnableOption "automated backup service for macOS";
    
    secretsPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/sops-nix/secrets/backup-restic";
      description = "Path to the SOPS-decrypted backup secrets file";
    };
    
    interval = mkOption {
      type = types.int;
      default = 86400; # 24 hours in seconds
      description = "Backup interval in seconds";
    };
    
    excludePaths = mkOption {
      type = types.listOf types.str;
      default = [
        "*/Library/Caches"
        "*/Library/Logs"
        "*/.Trash"
        "*/Downloads"
        "*/.cache"
        "*/node_modules"
        "*/.npm"
        "*/.nix-*"
      ];
      description = "Additional paths to exclude from backups";
    };
  };

  config = mkIf cfg.enable {
    # Import backup secrets via SOPS-nix
    sops.secrets."backup-restic" = {
      sopsFile = ../../secrets/backup/restic.yaml;
      format = "yaml";
    };

    # Enhanced backup script with SOPS integration for macOS
    home.packages = let
      backupScript = pkgs.writeShellApplication {
        name = "backup";
        runtimeInputs = with pkgs; [
          restic
          jq
          yq-go
        ];
        text = ''
          set -euo pipefail
          
          # Get hostname for repository path
          HOSTNAME=$(hostname -s)  # Use short hostname on macOS
          SECRETS_FILE="${cfg.secretsPath}"
          
          # Check if secrets file exists
          if [[ ! -f "$SECRETS_FILE" ]]; then
            echo "ERROR: Backup secrets file not found at $SECRETS_FILE"
            echo "Make sure SOPS has decrypted the secrets properly"
            exit 1
          fi
          
          # Read credentials from SOPS-decrypted file
          echo "Reading backup credentials from SOPS secrets..."
          
          OS_APPLICATION_CREDENTIAL_ID=$(yq eval '.openstack.application_credential_id' "$SECRETS_FILE")
          OS_APPLICATION_CREDENTIAL_SECRET=$(yq eval '.openstack.application_credential_secret' "$SECRETS_FILE")
          OS_AUTH_URL=$(yq eval '.openstack.auth_url' "$SECRETS_FILE")
          RESTIC_PASSWORD=$(yq eval '.restic.password' "$SECRETS_FILE")
          REPOSITORY_BASE=$(yq eval '.restic.repository_base' "$SECRETS_FILE")
          RESTIC_REPOSITORY="$REPOSITORY_BASE/$HOSTNAME"
          
          # Validate that we got actual values (not "null")
          for var in OS_APPLICATION_CREDENTIAL_ID OS_APPLICATION_CREDENTIAL_SECRET OS_AUTH_URL RESTIC_PASSWORD REPOSITORY_BASE; do
            if [[ ''${!var} == "null" ]] || [[ -z ''${!var} ]]; then
              echo "ERROR: Required credential $var is missing or null in secrets file"
              exit 1
            fi
          done
          
          export OS_APPLICATION_CREDENTIAL_ID
          export OS_APPLICATION_CREDENTIAL_SECRET
          export OS_AUTH_URL
          export RESTIC_PASSWORD
          export RESTIC_REPOSITORY

          echo "Starting backup for macOS host: $HOSTNAME"
          echo "Repository: $RESTIC_REPOSITORY"
          
          # Initialize repository if it doesn't exist
          if ! restic snapshots &>/dev/null; then
            echo "Repository doesn't exist, initializing..."
            restic init
          fi
          
          # Check repository consistency before backup
          echo "Checking repository integrity..."
          if ! restic check --read-data-subset=5%; then
            echo "ERROR: Repository integrity check failed!"
            exit 1
          fi
          
          # Build exclude arguments
          EXCLUDE_ARGS=()
          ${lib.concatMapStringsSep "\n" (path: ''
            EXCLUDE_ARGS+=("--exclude=${path}")
          '') cfg.excludePaths}
          
          # Backup home directory with macOS-specific exclusions
          echo "Starting backup..."
          if ! restic backup "$HOME" --exclude-caches "''${EXCLUDE_ARGS[@]}"; then
            echo "ERROR: Backup failed!"
            exit 1
          fi
          
          # Cleanup old backups
          echo "Cleaning up old backups..."
          restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 1 --prune
          
          # Verify the latest backup
          echo "Verifying latest backup..."
          LATEST_SNAPSHOT=$(restic snapshots --json | jq -r '.[0].id')
          if ! restic check --read-data-subset=1% "$LATEST_SNAPSHOT"; then
            echo "WARNING: Latest backup verification failed!"
            exit 1
          fi
          
          # Display backup statistics
          echo "Backup statistics:"
          restic stats --mode=raw-data
          
          echo "Backup completed successfully for $HOSTNAME at $(date)"
        '';
      };
    in [ backupScript ];

    # macOS launchd service with wrapper to check secrets availability
    launchd.agents.backup = let
      backupWrapper = pkgs.writeShellScript "backup-wrapper" ''
        if [[ ! -f "${cfg.secretsPath}" ]]; then
          echo "ERROR: Backup secrets not available, skipping backup"
          exit 1
        fi
        exec "${backupScript}/bin/backup"
      '';
    in {
      enable = true;
      config = {
        Label = "org.nixos.backup";
        ProgramArguments = [ "${backupWrapper}" ];
        StartInterval = cfg.interval;
        RunAtLoad = false;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/backup.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/backup.log";
      };
    };
  };
}