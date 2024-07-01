{ pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "mobile_app"
      "mqtt"
      "onvif"
      "tankerkoenig"
      "tasmota"
      "unifi"
      "zha"
    ];

    # https://github.com/greghesp/ha-bambulab
    # nix-prefetch-git --url https://github.com/greghesp/ha-bambulab --rev ${VERSION_NUMBER}
    customComponents = [
      (pkgs.buildHomeAssistantComponent rec {
        owner = "greghesp";
        domain = "bambu_lab";
        version = "2.0.21";
        src = pkgs.fetchFromGitHub {
          owner = "greghesp";
          repo = "ha-bambulab";
          rev = "v${version}";
          sha256 = "sha256-lg5NWMcHHYX/iTkMD+v5cY4mN/SVSnmMeXG6TXtfIag=";
        };
      })
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-graph-card
    ];

    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      homeassistant = {
        name = "Home";
	latitude = 54.757370;
	longitude = 9.378730;
        unit_system = "metric";
        time_zone = "Europe/Berlin";
      };

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "172.31.0.0/24"
        ];
      };

      prometheus = {};
      script = [
        {
          notify_cameron = {
            mode = "single";
            icon = "mdi:bell-alert";
            sequence = [
              {
                service = "notify.mobile_app_pixel_7a";
                data = {
                  message = "{{ message }}";
                  title = "{{ title }}";
                  data = {
                    clickAction = "{{ url | default(None) }}";
                  };
                };
              }
            ];
            fields = {
              message = {
                selector = {
                  text = null;
                };
                name = "Message";
                description = "The message you wanna send";
                required = true;
              };
              title = {
                selector = {
                  text = null;
                };
                name = "Title";
                description = "The title for the notification";
                default = "Home-Assistant";
              };
              url = {
                selector = {
                  text = null;
                };
                name = "URL";
                description = "An URL that opens when the notification is clicked";
              };
            };
          };
        }
      ];
      automation = [
        {
          id = "gasoline_alert";
          alias = "Gasoline Alert";
          trigger = [
            {
              platform = "numeric_state";
      	      entity_id = [
                "sensor.orlen_lilienthalstrasse_4_super"
                "sensor.shell_ochsenweg_18_super"
                "sensor.classic_liebigstr_10_super"
                "sensor.orlen_marienallee_60_super"
                "sensor.wiking_am_sophienhof_2_super"
                "sensor.aral_husumer_strasse_30_super"
                "sensor.team_am_friedenshugel_39_super"
                "sensor.shell_friesische_str_191_super"
              ];
              below = 1.80;
            }
          ];
          condition = [];
          action = [
            {
              service = "script.notify_cameron";
              data = {
                title = "Cheap Gasoline";
                message = "Gasoline is {{ trigger.to_state.state }} at {{trigger.to_state.attributes.friendly_name}}";
              };
            }
          ];
        }
        {
          id = "link_desk_plug_desk_plug_2_off";
          alias = "Link Desk Plugs";
          trigger = [
            {
              platform = "device";
	      type = "turned_off";
      	      entity_id = "switch.desk_plug";
	      device_id = "29c655fead33b30750cea72c1b7c547f";
      	      domain = "switch";
            }
          ];
          condition = [];
          action = [
            {
              type = "turn_off";
              device_id = "8ce523786cb1c8189ec6351aa9922235";
      	      entity_id = "switch.desk_plug_2";
      	      domain = "switch";
            }
          ];
        }
        {
          id = "link_desk_plug_desk_plug_2_on";
          alias = "Link Desk Plugs";
          trigger = [
            {
              platform = "device";
	      type = "turned_on";
      	      entity_id = "switch.desk_plug";
	      device_id = "29c655fead33b30750cea72c1b7c547f";
      	      domain = "switch";
            }
          ];
          condition = [];
          action = [
            {
              type = "turn_on";
              device_id = "8ce523786cb1c8189ec6351aa9922235";
      	      entity_id = "switch.desk_plug_2";
      	      domain = "switch";
            }
          ];
        }
        {
          id = "desk_plug_off";
          alias = "Turn off desk plug";
          trigger = [
            {
              platform = "time";
      	      at = [
                "22:00:00"
                "23:00:00"
                "00:00:00"
                "01:00:00"
                "02:00:00"
                "03:00:00"
                "04:00:00"
                "05:00:00"
      	      ];
            }
          ];
          condition = [
            {
              type = "is_power";
              condition = "device";
              device_id = "29c655fead33b30750cea72c1b7c547f";
              entity_id = "sensor.desk_plug_energy_power";
              domain = "sensor";
              below = 10;
            }
            {
              type = "is_power";
              condition = "device";
              device_id = "8ce523786cb1c8189ec6351aa9922235";
              entity_id = "sensor.desk_plug_2_energy_power";
              domain = "sensor";
              below = 10;
            }
          ];
          action = [
            {
              type = "turn_off";
              device_id = "29c655fead33b30750cea72c1b7c547f";
      	      entity_id = "switch.desk_plug";
      	      domain = "switch";
            }
          ];
        }
        {
          id = "lr_media_plug_off";
          alias = "Turn off living room media plug";
          trigger = [
            {
              platform = "time";
      	      at = [
                "22:00:00"
                "23:00:00"
                "00:00:00"
                "01:00:00"
                "02:00:00"
                "03:00:00"
                "04:00:00"
                "05:00:00"
      	      ];
            }
          ];
          condition = [
            {
              type = "is_power";
              condition = "device";
              device_id = "6305c5ca04bb79dc123b49713771d9bc";
              entity_id = "sensor.living_room_media_plug_energy_power";
              domain = "sensor";
              below = 30;
            }
          ];
          action = [
            {
              type = "turn_off";
              device_id = "6305c5ca04bb79dc123b49713771d9bc";
      	      entity_id = "switch.living_room_media_plug";
      	      domain = "switch";
            }
          ];
        }
      ];
    };
  };

  services.esphome = {
    enable = true;
    address = "0.0.0.0";
  };

  services.mosquitto = {
    enable = true;
    listeners = [{
      users = {
        ha = {
          acl = [
            "readwrite #"
          ];
          hashedPasswordFile = "/var/lib/mosquitto/ha-passwd";
        };
      };
    }];
  };
}
