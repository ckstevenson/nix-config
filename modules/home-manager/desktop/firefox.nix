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

    # macOS URL-handler fix (permanent, version-independent).
    #
    # Problem (recurring on every Firefox version bump):
    #   1. nixpkgs Firefox.app always uses CFBundleIdentifier "org.nixos.firefox".
    #      Every rebuild that bumps Firefox adds ANOTHER Firefox.app to the Nix
    #      store, all sharing that identifier. Over time LaunchServices (LS)
    #      knows many bundles with the same id (12+ observed), across live and
    #      garbage-collected store paths.
    #   2. mac-app-util generates an AppleScript "trampoline" at
    #        ~/Applications/Home Manager Trampolines/Firefox.app
    #      that runs `open '<hardcoded store path>'` with NO "$@" forwarding.
    #      So the URL is dropped, and the hardcoded path goes stale/GC'd after
    #      the next Firefox update.
    #   With duplicate identifiers + a stale, arg-dropping trampoline, LS resolves
    #   https/http to a dead or wrong bundle and `open https://...` (alacritty
    #   hint clicks) silently fails to open the URL.
    #
    # Why "just use defaults" does not work:
    #   The default IS the arg-dropping trampoline plus duplicate bundle ids.
    #   A one-time GC + LS rebuild only helps until the next Firefox bump.
    #
    # Permanent solution:
    #   Ship our OWN launcher app with a UNIQUE bundle identifier
    #   (org.nixos.firefox-launcher) whose executable is a shell script that
    #   execs the CURRENT finalPackage Firefox binary and FORWARDS "$@". Because
    #   the identifier is unique it never collides with the store bundles, and
    #   because it always points at config.programs.firefox.finalPackage it is
    #   immune to version bumps and store-path GC. We then pin it as the default
    #   http/https handler by that stable identifier.
    # Shared launcher artifacts for macOS URL-handler fix
    # Declare launcher bundle files directly via home.file so Home Manager
    # owns them and doesn't copy read-only Nix store artifacts into
    # ~/Applications.

    home.file."Applications/Firefox Launcher.app/Contents/Info.plist" = lib.mkIf pkgs.stdenv.isDarwin {
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleExecutable</key><string>launcher</string>
          <key>CFBundleIdentifier</key><string>org.nixos.firefox-launcher</string>
          <key>CFBundleName</key><string>Firefox Launcher</string>
          <key>CFBundlePackageType</key><string>APPL</string>
          <key>CFBundleShortVersionString</key><string>1.0</string>
          <key>LSMinimumSystemVersion</key><string>10.0</string>
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

    home.file."Applications/Firefox Launcher.app/Contents/MacOS/launcher" = lib.mkIf pkgs.stdenv.isDarwin {
      text = ''exec "${config.programs.firefox.finalPackage}/Applications/Firefox.app/Contents/MacOS/firefox" -P "${lib.head (lib.attrNames config.programs.firefox.profiles)}" "$@"'';
      executable = true;
    };

    # Activation: one-time cleanup of any stale read-only launcher, then
    # register the managed launcher and set default handlers. Keep this
    # activation minimal and idempotent.
    home.activation.fixFirefoxUrlHandler = lib.mkIf pkgs.stdenv.isDarwin (lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      LSREG=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
      LAUNCHER_DST="$HOME/Applications/Firefox Launcher.app"

      # If an existing launcher exists with read-only store permissions the
      # previous imperative copy left, try to remove it once so the
      # declarative home.file can place the managed copy. Guarded so it
      # only performs the cleanup when something is actually present.
      if [ -e "$LAUNCHER_DST" ]; then
        # Make writable where possible, then remove. Ignore failures.
        chmod -R u+w "$LAUNCHER_DST" 2>/dev/null || true
        rm -rf "$LAUNCHER_DST" 2>/dev/null || true
      fi

      # Register the launcher so LaunchServices can resolve its unique id.
      "$LSREG" -f "$LAUNCHER_DST" || true

      # Pin the launcher as the default http/https handler by its stable id.
      current="$(${pkgs.duti}/bin/duti -d https 2>/dev/null)"
      if [ "$current" != "org.nixos.firefox-launcher" ]; then
        ${pkgs.duti}/bin/duti -s org.nixos.firefox-launcher http  || true
        ${pkgs.duti}/bin/duti -s org.nixos.firefox-launcher https || true
      fi
    '');

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
