{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./home-assistant.nix
      ../../modules/nixos
       inputs.sops-nix.nixosModules.sops
    ];

  sshd.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "cameron" = import ./home.nix;
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/cameron/.config/sops/age/keys.txt";
    secrets."mosquitto/password" = {
      owner = "mosquitto";
      path = "/var/lib/mosquitto/ha-passwd";
    };
  };

  # Bootloader.
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  services.tailscale.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/180175
  networking = {
    enableIPv6 = false;
    firewall.enable = false;
    hostId = "b3a2c54b";
    hostName = "nix-server";

    networkmanager = {
      enable = true;
      unmanaged = [ "tailscale0" ];
    };

    bridges = {
      br0 = {
        interfaces = [
          "enp4s0f1"
        ];
      };
    };
  };

  # Enable ZFS support
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [
    "apps"
    "tank"
  ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  services.sanoid = {
    enable = true;
    datasets = {
      apps = {
        recursive = true;
        useTemplate = [ "apps" ];
      };
      tank = {
        recursive = true;
        useTemplate = [ "tank" ];
      };
    };
    templates = {
      apps = {
        hourly = 1;
        frequently = 0;
        daily = 7;
        monthly = 3;
        yearly = 1;
        autosnap = true;
        autoprune = true;
      };
      tank = {
        hourly = 0;
        frequently = 0;
        daily = 7;
        monthly = 1;
        yearly = 1;
        autosnap = true;
        autoprune = true;
      };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    groups = {
      pictures = {};
      media = {};
    };
    users = {
      cameron = {
        extraGroups = [ "networkmanager" "wheel" "docker" "pictures" "media" ];
      };
      docker = {
        isNormalUser = true;
        description = "docker";
        home = "/srv/docker/";
        group = "docker";
        extraGroups = [ "video" "media" "pictures" ];
        createHome = true;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjDDJYkUuWrZJFcDhXpo7/qky3d6Y5XOGQS5YicRN1pQXd96uTzDSjap4smjOOlx6WJIGcQYZsVXA0bsOXIaBRKcp90e14YB1L3LvqItPYDvuA/7URgkmvJ1YNloAkXWS2JyYUPX+ZzNlDXcfoJ3wc8+7moZSCEZvSB2FnEEiKaBjlUzOEdP+NQBXT+Piwy6Uf2VxGnPCCuoCytAtVzEFqWS/f4jkl/cUuwCZbL+hYrepOHMk8h4645q3Fu6NGWjvGt5f+TYhFI9P9Wgu1LKa1zHhywGWpmWW3HF3lOnDd8vTQlFPm8nLi4rVuQ4T1Q9i+w520+nqE4JVb5pC5v0tm1h2SWG0svQ3wmEyRuW29o9RTyrTlY2M9CwDX7VzUqbn1jix8e44EUeoEm9FJ/uC5pp75kugCNfyDDwHcDdDF5VzU4exjQ6bDVdN3uVYxlpOpyLAV4/gQiy/eTwfJHltX6JiPhJaWRKatJ6s3OJkVDUqmbmyyTFxuFJOcD82S/8qmCzrBCVsRUcBhrvVbd9LFY/hdXHxope6ts9IUSZ66Wkuc2mdOtfxGCpKJlmWFXCZP8v4p5CT89UluQS0CerSEK/8ID6ybEJDRZkwYGv22iYkjcssH5+ZBYpGZwNdr6o1lbigWkHzJviCeBe0N0Ccs8COdvWJykURp/+vtyLnBIQ== cameron@workstation"
        ];
      };
    };
  };

  # List services that you want to enable:
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    storageDriver = "zfs";
    };
  };

  # from installer?
  programs.dconf.enable = true;

  # for jellyfin
  # enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };

  services.smartd = {
    enable = true;
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      #disabledCollectors = [ "zfs" ];
      enabledCollectors = [ "systemd" ];
      listenAddress = "172.17.0.1";
    };
    smartctl.enable = true;
    zfs.enable = true;
  };

  services.cadvisor = {
    enable = true;
    listenAddress = "172.17.0.1";
    port = 8081;
  };

  systemd.services = {
    backup = {
      serviceConfig.Type = "oneshot";
      path = with pkgs; [ zfs restic ];
      script = ''
        . /root/.config/restic/vars

        ## Destroy old snapshot, if any
        [ "$(zfs list -t snapshot tank/pictures@backup)" ] && zfs destroy tank/pictures@backup
        [ "$(zfs list -t snapshot apps/docker@backup)" ] && zfs destroy apps/docker@backup
        [ "$(zfs list -t snapshot apps/images@backup)" ] && zfs destroy apps/images@backup

        ## Create snapshot
        zfs snapshot tank/pictures@backup
        zfs snapshot apps/docker@backup
        zfs snapshot apps/images@backup

        ## Backup read-only snapshot via its mount point
        restic backup /mnt/pictures/.zfs/snapshot/backup/
        restic backup /var/lib/docker/.zfs/snapshot/backup/
      	restic backup /var/lib/mosquitto
      	restic backup /var/lib/hass
      	restic backup /etc/nixos
        restic backup /srv/docker

        ## Destroy the snapshot
        zfs destroy tank/pictures@backup
        zfs destroy apps/images@backup
        zfs destroy apps/docker@backup

        restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 1 --prune
      '';
    };
    nextcloud-preview = {
      serviceConfig.Type = "oneshot";
      path = with pkgs; [ docker ];
      script = ''
        docker exec -u www-data nextcloud /var/www/html/occ preview:pre-generate
      '';
    };
    nextcloud-cron = {
      serviceConfig.Type = "oneshot";
      path = with pkgs; [ docker ];
      script = ''
        docker exec -u www-data nextcloud php cron.php
      '';
    };
    healthcheck = {
      serviceConfig.Type = "oneshot";
      path = with pkgs; [ curl ];
      script = ''
        curl https://hc-ping.com/ac5d987d-e26d-402a-8e68-4861dab9607d
      '';
    };
  };
  systemd.timers = {
    backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "backup.service" ];
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00";
        Unit = "backup.service";
      };
    };
    nextcloud-preview = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nextcloud-preview.service" ];
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00";
        Unit = "nextcloud-preview.service";
      };
    };
    nextcloud-cron = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nextcloud-cron.service" ];
      timerConfig = {
        OnCalendar = "*:0/5";
        Unit = "nextcloud-cron.service";
      };
    };
    healthcheck = {
      wantedBy = [ "timers.target" ];
      partOf = [ "healthcheck.service" ];
      timerConfig = {
        OnCalendar = "*-*-* *:*:00";
        Unit = "healthcheck.service";
      };
    };
  };

  system.stateVersion = "22.11"; # Did you read the comment?
}
