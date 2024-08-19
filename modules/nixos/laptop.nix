{ lib, config, ... }:
{
  options = {
    laptop.enable = lib.mkEnableOption "enables wireless networking";
  };

  config = lib.mkIf config.laptop.enable {
    networking.wireless = {
      iwd.enable = true;
    };

    #services.thermald.enable = true;

#    services.auto-cpufreq = {
#      enable = true;
#
#      settings = {
#        battery = {
#           governor = "powersave";
#           turbo = "never";
#        };
#        charger = {
#           governor = "performance";
#           turbo = "auto";
#        };
#      };
#    };
  };
}

