{ config, inputs, lib, osConfig, pkgs, ... }:
{
  options = {
    firefoxFontSize = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
  };

  config = lib.mkIf ((osConfig.desktop.enable or false) || pkgs.stdenv.isDarwin) {
    programs.firefox = {
      enable = true;
      profiles.cameron = {
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          bitwarden
          darkreader
          floccus
          multi-account-containers
          privacy-possum
          tridactyl
          #sponsorblock
          #vim-vixen
          #youtube-shorts-block
        ];

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
          "font.size.variable.x-western" = config.firefoxFontSize;
          "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        };
      };
    };

    # XDG MIME associations for Firefox (Linux only)
    xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
      associations.added = {
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "x-scheme-handler/mailto" = "firefox.desktop";
        "x-scheme-handler/chrome" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/json" = "firefox.desktop";
        "text/plain" = "firefox.desktop";
        "text/html" = "firefox.desktop";
      };
      defaultApplications = {
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "x-scheme-handler/mailto" = "firefox.desktop";
        "x-scheme-handler/chrome" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/json" = "firefox.desktop";
        "text/plain" = "firefox.desktop";
        "text/html" = "firefox.desktop";
      };
    };
  };
}
