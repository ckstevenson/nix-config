{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.backupService;
in
{
  options.services.backupService = {
    enable = mkEnableOption "automated backup service";

    secretsPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/sops-nix/secrets/backup-restic";
      description = "Path to the SOPS-decrypted backup secrets file";
    };

    interval = mkOption {
      type = types.str;
      default = "daily";
      description = "Systemd timer interval for backups";
    };

    excludePaths = mkOption {
      type = types.listOf types.str;
      default = [
        "*/node_modules"
        "*/.cache"
        "*/.npm"
        "*/.nix-*"
        "*/Downloads"
        "*/.Trash"
      ];
      description = "Additional paths to exclude from backups";
    };
  };

  config = mkIf cfg.enable (
    let
      backupScript = pkgs.writeShellApplication {
        name = "backup";
        runtimeInputs = with pkgs; [
          restic
          jq
          yq-go
          hostname
        ];
        text = ''
            set -euo pipefail

            # Get hostname for repository path
            HOSTNAME=$(hostname -s)
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

            echo "Starting backup for host: $HOSTNAME"
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

            # Backup home directory
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
    in
    {
      # Import backup secrets via SOPS-nix
      sops.secrets."backup-restic" = {
        sopsFile = ../../../secrets/backup/restic.yaml;
        format = "yaml";
      };

      # Enhanced backup script with SOPS integration
      home.packages = [ backupScript ];

      # Systemd service
      systemd.user.services.backup = {
        Unit = {
          Description = "Automated backup service with SOPS-managed credentials";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c '${backupScript}/bin/backup 2>&1 | ${pkgs.systemd}/bin/systemd-cat -t backup'";
          Environment = [
            "PATH=${lib.makeBinPath (with pkgs; [
            restic
            jq
            yq-go
          ])}"
          ];
          # Ensure secrets are available
          ExecStartPre = "${pkgs.coreutils}/bin/test -f ${cfg.secretsPath}";
        };
      };

      # Systemd timer
      systemd.user.timers.backup = {
        Unit = {
          Description = "Run backup service ${cfg.interval}";
          Requires = [ "backup.service" ];
        };
        Timer = {
          OnCalendar = cfg.interval;
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    }
  );
}
