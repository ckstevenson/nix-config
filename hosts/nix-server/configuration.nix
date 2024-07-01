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

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/cameron/.config/sops/age/keys.txt";
  sops.secrets."mosquitto/password" = {
    owner = "mosquitto";
    path = "/var/lib/mosquitto/ha-passwd";
  };

  # Bootloader.
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nix-server"; # Define your hostname.

  # Enable ZFS support
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  networking.hostId = "b3a2c54b";
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

  # Enable networking
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  networking.bridges = {
    br0 = {
      interfaces = [
        "enp4s0f1"
      ];
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
        extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "pictures" "media" ];
      };
      docker = {
        isNormalUser = true;
        description = "docker";
        home = "/srv/docker/";
        group = "docker";
        extraGroups = [ "video" "media" "pictures" ];
        createHome = true;
        packages = with pkgs; [];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjDDJYkUuWrZJFcDhXpo7/qky3d6Y5XOGQS5YicRN1pQXd96uTzDSjap4smjOOlx6WJIGcQYZsVXA0bsOXIaBRKcp90e14YB1L3LvqItPYDvuA/7URgkmvJ1YNloAkXWS2JyYUPX+ZzNlDXcfoJ3wc8+7moZSCEZvSB2FnEEiKaBjlUzOEdP+NQBXT+Piwy6Uf2VxGnPCCuoCytAtVzEFqWS/f4jkl/cUuwCZbL+hYrepOHMk8h4645q3Fu6NGWjvGt5f+TYhFI9P9Wgu1LKa1zHhywGWpmWW3HF3lOnDd8vTQlFPm8nLi4rVuQ4T1Q9i+w520+nqE4JVb5pC5v0tm1h2SWG0svQ3wmEyRuW29o9RTyrTlY2M9CwDX7VzUqbn1jix8e44EUeoEm9FJ/uC5pp75kugCNfyDDwHcDdDF5VzU4exjQ6bDVdN3uVYxlpOpyLAV4/gQiy/eTwfJHltX6JiPhJaWRKatJ6s3OJkVDUqmbmyyTFxuFJOcD82S/8qmCzrBCVsRUcBhrvVbd9LFY/hdXHxope6ts9IUSZ66Wkuc2mdOtfxGCpKJlmWFXCZP8v4p5CT89UluQS0CerSEK/8ID6ybEJDRZkwYGv22iYkjcssH5+ZBYpGZwNdr6o1lbigWkHzJviCeBe0N0Ccs8COdvWJykURp/+vtyLnBIQ== cameron@workstation"
        ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    restic
    usbutils
    git
    intel-gpu-tools
    pciutils
    tailscale
    smartmontools
    mosquitto
  ];

  # List services that you want to enable:
  virtualisation = {
    libvirtd.enable = true;
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
  hardware.opengl = {
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

  services.tailscale.enable = true;

  systemd.services = {
    backup = {
      serviceConfig.Type = "oneshot";
      path = with pkgs; [ zfs libvirt restic ];
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

#  fileSystems."/export/videos" = {
#    device = "/mnt/videos";
#    options = [ "bind" ];
#  };
#
#  fileSystems."/export/picutres" = {
#    device = "/mnt/pictures";
#    options = [ "bind" ];
#  };
#
#  fileSystems."/export/music" = {
#    device = "/mnt/music";
#    options = [ "bind" ];
#  };
#
#  fileSystems."/export/games" = {
#    device = "/mnt/games";
#    options = [ "bind" ];
#  };
#
#  services.nfs.server.enable = true;
#  services.nfs.server.exports = ''
#    /export           10.10.10.118(rw,fsid=0,no_subtree_check)
#    /export/videos    10.10.10.118(rw,nohide,insecure,no_subtree_check)
#    /export/pictures  10.10.10.118(rw,nohide,insecure,no_subtree_check)
#    /export/games     10.10.10.118(rw,nohide,insecure,no_subtree_check)
#    /export/music     10.10.10.118(rw,nohide,insecure,no_subtree_check)
#  '';

  # https://github.com/NixOS/nixpkgs/issues/180175
  networking.networkmanager.unmanaged = [ "tailscale0" ];
#  systemd.services.NetworkManager-wait-online = {
#    serviceConfig = {
#      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
#    };
#  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
