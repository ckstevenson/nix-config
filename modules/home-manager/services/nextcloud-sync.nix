{ pkgs, lib, config, ... }: {

  options = {
    nextcloudSyncService.enable = lib.mkEnableOption "enables nextcloud sync service and timer";
  };
  
  config = lib.mkIf config.nextcloudSyncService.enable {
    home.file = {
      ".config/Nextcloud/sync-exclude.lst".text = ''
        # This file contains fixed global exclude patterns

        Pictures

        *~
        ~$*
        .~lock.*
        ~*.tmp
        ]*.~*
        ]Icon\r*
        ].DS_Store
        ].ds_store
        *.textClipping
        ._*
        ]Thumbs.db
        ]photothumb.db
        System Volume Information

        .*.sw?
        .*.*sw?

        ].TemporaryItems
        ].Trashes
        ].DocumentRevisions-V100
        ].Trash-*
        .fseventd
        .apdisk
        .Spotlight-V100

        .directory

        *.part
        *.filepart
        *.crdownload

        *.kate-swp
        *.gnucash.tmp-*

        .synkron.*
        .sync.ffs_db
        .symform
        .symform-store
        .fuse_hidden*
        *.unison
        .nfs*

        # (default) metadata files created by Syncthing
        .stfolder
        .stignore
        .stversions

        My Saved Places.

        \#*#

        *.sb-*
      '';
    };
    systemd.user = { 
      services = {
        nextcloud-sync = {
          Unit = {
            Description = "Service to sync nextcloud documents";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.nextcloud-client}/bin/nextcloudcmd --exclude /home/cameron/.config/Nextcloud/sync-exclude.lst /home/cameron/Documents https://cameron:$(${pkgs.rbw}/bin/rbw get nc.germerica.us)@nc.germerica.us'";
          };
        };
      };
      timers = {
        nextcloud-sync = {
          Unit = {
            Description = "Timer to backup up system";
          };
          Timer = {
            OnStartupSec="5m";
            OnUnitActiveSec="10m";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      };
    };
  };
}
