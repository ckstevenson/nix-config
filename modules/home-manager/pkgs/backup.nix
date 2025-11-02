{ pkgs, ... }:
let 
  backup = pkgs.writeShellApplication {
    name = "backup";
    runtimeInputs = with pkgs; [
      restic
      rbw
      hostname
      jq
    ];
    text = ''
      # Get hostname for repository path
      HOSTNAME=$(hostname)
      
      # Get credentials from rbw
      OS_APPLICATION_CREDENTIAL_ID="$(rbw get --field username openstack-restic)"
      OS_APPLICATION_CREDENTIAL_SECRET="$(rbw get --field password openstack-restic)"
      OS_AUTH_URL="$(rbw get --field os_auth_url openstack-restic)"
      RESTIC_PASSWORD="$(rbw get --field password restic-backups)"
      RESTIC_REPOSITORY="$(rbw get --field repository restic-backups):/$HOSTNAME"
      
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
      
      # Backup home directory
      echo "Starting backup..."
      if ! restic backup "$HOME" --exclude-caches; then
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
  home.packages = [
    backup
  ];
}
