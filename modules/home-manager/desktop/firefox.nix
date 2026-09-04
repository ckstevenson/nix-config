{ config, inputs, lib, osConfig, pkgs, ... }:
{
  options = {
    firefoxFontSize = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
  };

  config = lib.mkIf ((osConfig.desktop.enable or false) || pkgs.stdenv.hostPlatform.isDarwin) {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      # Keep Firefox's modern profile-to-install mapping stable across
      # nixpkgs store-path changes and fresh machines.
      profileVersion = 2;
      # Profile storage location (platform-specific):
      #   - macOS: ~/Library/Application Support/Firefox  (Apple default)
      #   - Linux: ~/.config/mozilla/firefox on stateVersion >= 26.05, else
      #            ~/.mozilla/firefox (home-manager's XDG migration is
      #            LINUX-ONLY; macOS is never moved to ~/.config).
      # Do NOT try to force ~/.config on macOS: Firefox on macOS only reads the
      # Library path, so that would hide all profile data. Let the home-manager
      # firefox module use its platform-aware default for configPath.
      #
      # A leftover ~/.mozilla/firefox on macOS is inert legacy split-brain from
      # an older config that hardcoded ".mozilla/firefox"; Firefox ignores it on
      # macOS. It can be safely removed (see scripts/firefox-cleanup.sh).
      profiles.cameron = {
        storeId = "0111914c";

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

        id = 0;

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
              icon = if pkgs.stdenv.hostPlatform.isDarwin then "" else "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
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
          "dom.security.https_only_mode" = false;
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

    # mac-app-util's generated Firefox trampoline hardcodes a store path and
    # drops URL arguments. Use a stable, declarative app bundle instead.
    home.file."Applications/Firefox.app/Contents/Info.plist" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleExecutable</key><string>launcher</string>
          <key>CFBundleIdentifier</key><string>org.nixos.firefox-launcher</string>
          <key>CFBundleName</key><string>Firefox</string>
          <key>CFBundlePackageType</key><string>APPL</string>
          <key>CFBundleShortVersionString</key><string>1.0</string>
          <key>LSMinimumSystemVersion</key><string>10.15</string>
          <key>CFBundleURLTypes</key>
          <array>
            <dict>
              <key>CFBundleURLName</key><string>Web URL</string>
              <key>CFBundleURLSchemes</key>
              <array><string>http</string><string>https</string></array>
            </dict>
          </array>
        </dict>
        </plist>
      '';
    };

    home.file."Applications/Firefox.app/Contents/MacOS/launcher" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      text = ''
        #!${pkgs.bash}/bin/bash
        exec "${config.programs.firefox.finalPackage}/Applications/Firefox.app/Contents/MacOS/firefox" "$@"
      '';
      executable = true;
    };

    home.activation.registerFirefoxBundle = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
      HOME_MANAGER_FIREFOX="$HOME/Applications/Home Manager Apps/Firefox.app"
      OLD_LAUNCHER="$HOME/Applications/Firefox Launcher.app"
      LAUNCHER="$HOME/Applications/Firefox.app"

      if [ -e "$HOME_MANAGER_FIREFOX" ]; then
        "$LSREGISTER" -u "$HOME_MANAGER_FIREFOX" || true
        rm -rf "$HOME_MANAGER_FIREFOX" || true
      fi

      if [ -e "$OLD_LAUNCHER" ]; then
        "$LSREGISTER" -u "$OLD_LAUNCHER" || true
        rm -rf "$OLD_LAUNCHER" || true
      fi

      if [ -e "$LAUNCHER" ]; then
        "$LSREGISTER" -f "$LAUNCHER" || true

        handler_is_firefox() {
          /usr/bin/defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null |
            /usr/bin/awk -v scheme="$1" '
              BEGIN { found = 1 }
              /^[[:space:]]*\{$/ {
                found_scheme = 0
                found_handler = 0
              }
              $0 ~ "LSHandlerURLScheme = " scheme ";" { found_scheme = 1 }
              /org.nixos.firefox-launcher/ { found_handler = 1 }
              /^[[:space:]]*\},$/ {
                if (found_scheme && found_handler) { found = 0 }
              }
              END { exit found }
            '
        }

        for scheme in http https; do
          if ! handler_is_firefox "$scheme"; then
            if ! ${pkgs.duti}/bin/duti -s org.nixos.firefox-launcher "$scheme" >/dev/null 2>&1; then
              printf '%s\n' "Firefox URL handler: select Firefox in System Settings > Apps > Default web browser" >&2
            fi
          fi
        done
      fi
    '');

    # XDG MIME associations for Firefox (Linux only)
    xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
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
