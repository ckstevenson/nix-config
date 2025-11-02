{ pkgs, lib, config, ... }: 
let
  backup = pkgs.callPackage ../pkgs/backup.nix {};
in
{

  options = {
    backupService.enable = lib.mkEnableOption "enables system backup";
  };
  
  config = lib.mkIf config.backupService.enable {
    systemd.user = { 
      services = {
        backup = {
          Unit = {
            Description = "Service to backup local system";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${backup}/bin/backup";
          };
        };
      };
      timers = {
        backup = {
          Unit = {
            Description = "Timer to backup up system";
          };
          Timer = {
            OnStartupSec="10m";
            OnUnitActiveSec="1d";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      };
    };
  };
}
