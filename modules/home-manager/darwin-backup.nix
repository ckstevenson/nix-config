{ pkgs, lib, config, ... }:
let
  backup = pkgs.callPackage ./pkgs/darwin-backup.nix { };

  backupPlist = {
    Label = "backup.service";
    ProgramArguments = [ "${backup}/bin/backup" ];
    StartInterval = 86400; # Run daily (24 hours in seconds)
    StandardOutPath = "${config.home.homeDirectory}/Library/Logs/backup.log";
    StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/backup.log";
  };
in
{
  options = {
    darwinBackupService.enable = lib.mkEnableOption "enables macOS backup service using launchd";
  };

  config = lib.mkIf config.darwinBackupService.enable {
    # Install backup package
    home.packages = [ backup ];

    # Create launchd plist for scheduled backups
    home.file."Library/LaunchAgents/backup.service.plist" = {
      text = builtins.toXML backupPlist;
    };

    # Create backup log directory
    home.activation.backupLogDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/Library/Logs"
    '';

    # Provide instructions for loading the service
    home.activation.backupServiceInstructions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      echo "To enable the backup service, run:"
      echo "  launchctl load ~/Library/LaunchAgents/backup.service.plist"
      echo "To start backup immediately, run:"
      echo "  launchctl start backup.service"
      echo "To check service status, run:"
      echo "  launchctl list | grep backup"
      echo "Backup logs are written to: ~/Library/Logs/backup.log"
    '';
  };
}
