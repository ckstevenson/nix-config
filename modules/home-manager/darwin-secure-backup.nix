{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.darwinBackupService;
in
{
  options.services.darwinBackupService = {
    enable = mkEnableOption "automated backup service for macOS";

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
        "*/Videos"
        "*/Games"
        "*/.cache"
        "*/node_modules"
        "*/.npm"
        "*/.nix-*"
        "*/Applications"
      ];
      description = "Additional paths to exclude from backups";
    };
  };

  config = mkIf cfg.enable (
    let
      # Enhanced backup script with SOPS integration for macOS
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

          # Read credentials from SOPS-decrypted files
          echo "Reading backup credentials from SOPS secrets..."

          AWS_ACCESS_KEY_ID=$(cat "${config.sops.secrets."aws/access_key_id".path}")
          AWS_SECRET_ACCESS_KEY=$(cat "${config.sops.secrets."aws/secret_access_key".path}")
          RESTIC_PASSWORD=$(cat "${config.sops.secrets."restic/password".path}")
          RESTIC_REPOSITORY=$(cat "${config.sops.secrets."restic/repository".path}")

          # Validate that we got actual values (not "null")
          for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY RESTIC_PASSWORD RESTIC_REPOSITORY; do
            if [[ ''${!var} == "null" ]] || [[ -z ''${!var} ]]; then
              echo "ERROR: Required credential $var is missing or null in secrets file"
              exit 1
            fi
          done

          export AWS_ACCESS_KEY_ID
          export AWS_SECRET_ACCESS_KEY
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

      backupWrapper = pkgs.writeShellScript "backup-wrapper" ''
        # Check if secret files exist
        if [[ ! -f "${config.sops.secrets."aws/access_key_id".path}" ]]; then
          echo "ERROR: AWS access key not available at ${config.sops.secrets."aws/access_key_id".path}, skipping backup"
          exit 1
        fi
        if [[ ! -f "${config.sops.secrets."aws/secret_access_key".path}" ]]; then
          echo "ERROR: AWS secret key not available at ${config.sops.secrets."aws/secret_access_key".path}, skipping backup"
          exit 1
        fi
        if [[ ! -f "${config.sops.secrets."restic/password".path}" ]]; then
          echo "ERROR: Restic password not available at ${config.sops.secrets."restic/password".path}, skipping backup"
          exit 1
        fi
        if [[ ! -f "${config.sops.secrets."restic/repository".path}" ]]; then
          echo "ERROR: Restic repository not available at ${config.sops.secrets."restic/repository".path}, skipping backup"
          exit 1
        fi
        exec "${backupScript}/bin/backup"
      '';
    in
    {
      # Import backup secrets via SOPS-nix - import individual keys
      sops.secrets."aws/access_key_id" = {
        sopsFile = ../../secrets/backup/restic.yaml;
        format = "yaml";
      };
      sops.secrets."aws/secret_access_key" = {
        sopsFile = ../../secrets/backup/restic.yaml;
        format = "yaml";
      };
      sops.secrets."restic/password" = {
        sopsFile = ../../secrets/backup/restic.yaml;
        format = "yaml";
      };
      sops.secrets."restic/repository" = {
        sopsFile = ../../secrets/backup/restic.yaml;
        format = "yaml";
      };

      home.packages = [ backupScript ];

      # macOS launchd service with wrapper to check secrets availability
      launchd.agents.backup = {
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
    }
  );
}
