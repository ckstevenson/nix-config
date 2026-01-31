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
          #privacy-possum
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
          # Enable hardware video decoding
          "media.hardware-video-decoding.enabled" = true;
          # Use GPU-accelerated rendering
          "gfx.webrender.all" = true;
          # Enable DRM for streaming services (Netflix, etc.)
          "media.eme.enabled" = true;
          # Skip warning when accessing about:config
          "browser.aboutConfig.showWarning" = false;
          # Don't prompt to reset Firefox after crashes
          "browser.disableResetPrompt" = true;
          # Show download panel automatically
          "browser.download.panel.shown" = true;
          # Disable sponsored content on new tab page
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          # Don't check if Firefox is default browser
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          # Custom homepage
          "browser.startup.homepage" = "https://dashboard.germerica.us";
          # Always show bookmarks toolbar
          "browser.toolbars.bookmarks.visibility" = "always";
          # Force HTTPS connections only
          "dom.security.https_only_mode" = true;
          # Disable Firefox Account/Sync (using Floccus for bookmarks, Bitwarden for passwords)
          "identity.fxaccounts.enabled" = false;
          # Block known trackers
          "privacy.trackingprotection.enabled" = true;
          # Don't offer to save passwords (using Bitwarden)
          "signon.rememberSignons" = false;
          # Custom font size
          "font.size.variable.x-western" = config.firefoxFontSize;
          # Toolbar layout customization
          "browser.uiCustomization.state" = builtins.toJSON {
            placements = {
              widget-overflow-fixed-list = [ ];
              nav-bar = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "home-button"
                "urlbar-container"
                "downloads-button"
                "library-button"
                "_testpilot-containers-browser-action"
              ];
              toolbar-menubar = [ "menubar-items" ];
              TabsToolbar = [
                "tabbrowser-tabs"
                "new-tab-button"
                "alltabs-button"
              ];
              PersonalToolbar = [
                "import-button"
                "personal-bookmarks"
              ];
            };
            seen = [
              "save-to-pocket-button"
              "developer-button"
              "_testpilot-containers-browser-action"
            ];
            dirtyAreaCache = [
              "nav-bar"
              "PersonalToolbar"
              "toolbar-menubar"
              "TabsToolbar"
              "widget-overflow-fixed-list"
            ];
            currentVersion = 18;
            newElementCount = 4;
          };
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
