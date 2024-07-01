{ pkgs, ... }:
let 
  backup = pkgs.writeShellApplication {
    name = "backup";
    runtimeInputs = with pkgs; [
      restic
      rbw
    ];
    text = ''
      OS_APPLICATION_CREDENTIAL_ID="$(rbw get --field username openstack-restic)"
      OS_APPLICATION_CREDENTIAL_SECRET="$(rbw get --field password openstack-restic)"
      OS_AUTH_URL="$(rbw get --field os_auth_url openstack-restic)"
      RESTIC_PASSWORD="$(rbw get --field password restic-backups)"
      RESTIC_REPOSITORY="$(rbw get --field repository restic-backups):/workstation"
      export OS_APPLICATION_CREDENTIAL_ID
      export OS_APPLICATION_CREDENTIAL_SECRET
      export OS_AUTH_URL
      export RESTIC_PASSWORD
      export RESTIC_REPOSITORY

      restic backup /home/cameron
      restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 1 --prune
    '';
  };
in
{
  home.packages = [
    backup
  ];
}
