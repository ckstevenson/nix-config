{ config, lib, ... }: {
  options = {
    sshd.enable = lib.mkEnableOption "enables sshd";
  };

  config = lib.mkIf config.sshd.enable {
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}

