{ lib, pkgs, inputs, config, ... }: {
  options = {
    opencode.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable opencode with 1password integration";
    };

    username = lib.mkOption {
      type = lib.types.str;
      default = "cameron";
      description = "The username of the user";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/cameron";
      description = "The home directory of the user";
    };
  };

  imports = [
    ./skhd.nix
    ./yabai.nix
    ./homebrew.nix
  ];
  config = {
    username = "cameronstevenson";
    homeDirectory = "/Users/cameronstevenson";
    system.primaryUser = config.username;

    # Pin this host to stable nixpkgs (other hosts stay on unstable).
    nixpkgs.pkgs = import inputs.nixpkgs-stable {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };

    home-manager = {
      useGlobalPkgs = false;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = {
        inherit inputs;
      };

      users.cameronstevenson = {
        nixpkgs.config.allowUnfree = true;
        imports = [
          inputs.mac-app-util.homeManagerModules.default
          inputs.nix-colors.homeManagerModules.default
          inputs.nixvim.homeModules.nixvim
          inputs.sops-nix.homeManagerModules.sops
          inputs.zen-browser.homeModules.twilight
          inputs.opencode-config.homeManagerModules.default
          ./home.nix
        ];
      };

    };

    nix-homebrew = {
      # Install Homebrew under the default prefix
      enable = true;

      # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
      enableRosetta = true;

      # User owning the Homebrew prefix
      user = "cameronstevenson";
    };

    services.tailscale.enable = true;

    # Necessary for using flakes on this system.
    nix.settings = {
      experimental-features = "nix-command flakes";
      # Allow this user to use restricted settings like netrc-file
      # Required for authenticated NuGet package downloads in pure Nix builds
      trusted-users = [ "root" "cameronstevenson" ];

      # Binary caches for inputs used in this config — avoids local builds
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org" # home-manager, nixvim, sops-nix, nix-index-database
        "https://hyprland.cachix.org" # hyprland
        "https://nix-darwin.cachix.org" # nix-darwin
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-darwin.cachix.org-1:hmcsBDa3DgQTPFiuW/y3N/jeC3YKLhFJSFBV3gMq/1E="
      ];
    };

    # Create /etc/zshrc that loads the nix-darwin environment.
    programs.zsh.enable = true; # default shell on catalina
    # programs.fish.enable = true;

    # Set Git commit hash for darwin-version.
    #system.configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;

    # The platform the configuration will be used on.
    #nixpkgs.hostPlatform = "x86_64-darwin";
    nixpkgs.hostPlatform = "aarch64-darwin";

    users.users.cameronstevenson = {
      name = "cameronstevenson";
      home = "/Users/cameronstevenson";
    };

    fonts = {
      packages = with pkgs; [
        nerd-fonts.dejavu-sans-mono

      ];

      #    fontconfig = {
      #      defaultFonts = {
      #        monospace = ["DejaVuSansM Nerd Font Mono"];
      #        sansSerif = ["DejaVuSansM Nerd Font"];
      #        serif = ["DejaVuSansM Nerd Font"];
      #      };
      #
      #      subpixel = {
      #        rgba = "rgb";
      #      };
      #    };
    };
    security.sudo.extraConfig = ''
      cameronstevenson ALL=(ALL) NOPASSWD: ALL
    '';

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      swapLeftCommandAndLeftAlt = true;
    };

    system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;
    system.defaults.WindowManager.StageManagerHideWidgets = false;
    system.defaults.WindowManager.StandardHideWidgets = false;
    system.defaults.finder.NewWindowTarget = "Home";
    system.defaults.finder.ShowExternalHardDrivesOnDesktop = false;
    system.defaults.finder.ShowRemovableMediaOnDesktop = false;
    system.defaults.screencapture.target = "clipboard";

    system.defaults = {
      # ** Appearance
      # dark mode
      NSGlobalDomain.AppleInterfaceStyle = "Dark";

      # ** Menu Bar
      # Show the macOS menu bar
      NSGlobalDomain._HIHideMenuBar = false;

      # ** Dock, Mission Control
      dock = {
        autohide = true;
        # make smaller (default 64)
        tilesize = 48;

        # whether to automatically rearrange spaces based on most recent use
        # don't want if using yabai
        mru-spaces = false;

        # make icons of hidden applications translucent
        # showhidden
        # autohide-delay
        # animation speed
        # autohide-time-modifier
        # mission control animation speed
        # expose-animation-duration

        # defaults
        # show-recents = true;
        # animate opening applications from dock
        # launchanim = true;
        # orientation = "bottom";
      };

      # ** Keyboard
      # step sliders in UI are:
      # InitialKeyRepeat: 120, 94, 68, 35, 25, 15
      # KeyRepeat: 120, 90, 60, 30, 12, 6, 2
      # default is 25 and 6
      # multiply each by 15 to get milliseconds
      # result: 300ms ti start and 66.6... repeats per second
      # second
      #NSGlobalDomain.InitialKeyRepeat = 20;
      #NSGlobalDomain.KeyRepeat = 1;

      # ** Mouse
      # enable tap to click
      trackpad.Clicking = true;
      # TODO what is the difference between these two?
      NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;

      # disable mouse acceleration
      # FIXME
      # ".GlobalPreferences"."com.apple.mouse.scaling" = (-1.0);

      # disable natural scroll direction
      NSGlobalDomain."com.apple.swipescrolldirection" = false;

      # tracking speed; 0.0-3.0 (default 1)
      # NSGlobalDomain."com.apple.trackpad.scaling"

      # ** Finder
      # don't show desktop icons
      finder.CreateDesktop = false;

      NSGlobalDomain.AppleShowAllExtensions = true;
      finder.AppleShowAllExtensions = true;
      # default to list view
      finder.FXPreferredViewStyle = "Nlsv";

      # full path in window title
      finder._FXShowPosixPathInTitle = true;

      # finder sidebar icon size
      # NSGlobalDomain.NSTableViewDefaultSizeMode
    };

    networking.hostName = "mbp";

    # Tailscale MagicDNS workaround for macOS
    # macOS doesn't properly resolve split DNS for custom subdomains via Tailscale
    # These entries point to the nix-server Tailscale IP for local service resolution
    #networking.extraHosts = ''
    #  100.74.109.93 vw.germerica.us
    #  100.74.109.93 ha.germerica.us
    #  100.74.109.93 nc.germerica.us
    #  100.74.109.93 prometheus.germerica.us
    #  100.74.109.93 jf.germerica.us
    #  100.74.109.93 gw.germerica.us
    #  100.74.109.93 search.germerica.us
    #  100.74.109.93 dashboard.germerica.us
    #'';
  };
}
