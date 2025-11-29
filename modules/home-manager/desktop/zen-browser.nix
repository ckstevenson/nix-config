{ config, inputs, lib, osConfig, pkgs, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  config = lib.mkIf ((osConfig.desktop.enable or false) || pkgs.stdenv.isDarwin) {
    programs.zen-browser = {
      enable = true;

      profiles.cameron = {
        extensions.packages = lib.optionals (!pkgs.stdenv.isDarwin) (
          with inputs.firefox-addons.packages."x86_64-linux"; [
            bitwarden
            darkreader
            floccus
            multi-account-containers
            privacy-possum
            tridactyl
          ]
        );

        search = {
          force = true;
          default = "SearchXNG";
          order = [
            "SearchXNG"
            "Nix Packages"
          ];
          engines = {
            "bing".metaData.hidden = true;
            "ddg".metaData.hidden = true;
            "google".metaData.hidden = true;
            "SearchXNG" = {
              urls = [
                {
                  template = "https://search.germerica.us/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              definedAliases = [ "@s" ];
            };
            "Github" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              definedAliases = [ "@gh" ];
            };
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = if pkgs.stdenv.isDarwin then "" else "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@n" ];
            };
          };
        };

        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.disableResetPrompt" = true;
          "browser.download.panel.shown" = true;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          "browser.startup.homepage" = "https://dashboard.germerica.us";
          "browser.toolbars.bookmarks.visibility" = "always";
          "dom.security.https_only_mode" = true;
          "identity.fxaccounts.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
          "signon.rememberSignons" = false;
        };
      };

      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
    };

    # XDG MIME associations for Zen Browser
    xdg.mimeApps = lib.mkIf (osConfig.desktop.enable or false) {
      associations.added = {
        "application/x-extension-shtml" = "zen.desktop";
        "application/x-extension-xhtml" = "zen.desktop";
        "application/x-extension-html" = "zen.desktop";
        "application/x-extension-xht" = "zen.desktop";
        "application/x-extension-htm" = "zen.desktop";
        "x-scheme-handler/unknown" = "zen.desktop";
        "x-scheme-handler/mailto" = "zen.desktop";
        "x-scheme-handler/chrome" = "zen.desktop";
        "x-scheme-handler/about" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "application/xhtml+xml" = "zen.desktop";
        "application/json" = "zen.desktop";
        "text/plain" = "zen.desktop";
        "text/html" = "zen.desktop";
      };
      defaultApplications = {
        "application/x-extension-shtml" = "zen.desktop";
        "application/x-extension-xhtml" = "zen.desktop";
        "application/x-extension-html" = "zen.desktop";
        "application/x-extension-xht" = "zen.desktop";
        "application/x-extension-htm" = "zen.desktop";
        "x-scheme-handler/unknown" = "zen.desktop";
        "x-scheme-handler/mailto" = "zen.desktop";
        "x-scheme-handler/chrome" = "zen.desktop";
        "x-scheme-handler/about" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "application/xhtml+xml" = "zen.desktop";
        "application/json" = "zen.desktop";
        "text/plain" = "zen.desktop";
        "text/html" = "zen.desktop";
      };
    };
  };
}
