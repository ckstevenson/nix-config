{ pkgs, lib, config, ... }: {

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
            ExecStart = "${pkgs.rbw-bemenu}/bin/rbw-menu";
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
