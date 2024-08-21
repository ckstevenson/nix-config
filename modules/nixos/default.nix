{ lib, pkgs, ...}:{
  options = {
    # used in imported modules if dektop is enabled
    desktop.enable = lib.mkEnableOption "enables desktop applications";
  };

  imports = [
    ./desktop.nix
    ./laptop.nix
    ./ssh.nix
    ./global-protect.nix
  ];
  
  config = {
    desktop.enable = lib.mkDefault false;
    laptop.enable = lib.mkDefault false;

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  
    nixpkgs.config.allowUnfree = true;
  
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
    };
  
    programs.zsh.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Berlin";
  
    # Enable ssh agent
    programs.ssh.startAgent = true;
  
    security.sudo.extraConfig = ''
      Defaults !tty_tickets, timestamp_timeout=60
    '';

    users.users.cameron = {
      isNormalUser = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKfa7fTncZ7hItimo3B7QO9cM++leSDxRnMuoLMI00C cksteve@protonmail.com"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjDDJYkUuWrZJFcDhXpo7/qky3d6Y5XOGQS5YicRN1pQXd96uTzDSjap4smjOOlx6WJIGcQYZsVXA0bsOXIaBRKcp90e14YB1L3LvqItPYDvuA/7URgkmvJ1YNloAkXWS2JyYUPX+ZzNlDXcfoJ3wc8+7moZSCEZvSB2FnEEiKaBjlUzOEdP+NQBXT+Piwy6Uf2VxGnPCCuoCytAtVzEFqWS/f4jkl/cUuwCZbL+hYrepOHMk8h4645q3Fu6NGWjvGt5f+TYhFI9P9Wgu1LKa1zHhywGWpmWW3HF3lOnDd8vTQlFPm8nLi4rVuQ4T1Q9i+w520+nqE4JVb5pC5v0tm1h2SWG0svQ3wmEyRuW29o9RTyrTlY2M9CwDX7VzUqbn1jix8e44EUeoEm9FJ/uC5pp75kugCNfyDDwHcDdDF5VzU4exjQ6bDVdN3uVYxlpOpyLAV4/gQiy/eTwfJHltX6JiPhJaWRKatJ6s3OJkVDUqmbmyyTFxuFJOcD82S/8qmCzrBCVsRUcBhrvVbd9LFY/hdXHxope6ts9IUSZ66Wkuc2mdOtfxGCpKJlmWFXCZP8v4p5CT89UluQS0CerSEK/8ID6ybEJDRZkwYGv22iYkjcssH5+ZBYpGZwNdr6o1lbigWkHzJviCeBe0N0Ccs8COdvWJykURp/+vtyLnBIQ== cameron@workstation"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3wKTXVR+CJMX6I0rrJawmAznQnY91g7V0GolR+8wxQ cameron@ideapad"
      ];
    };

    services.tailscale.enable = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}

