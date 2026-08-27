{ ... }: {
  homebrew = {
    enable = true;

    # Update Homebrew and packages on system rebuild
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    taps = [ ];
    brews = [
      "choose-gui"
    ];
    casks = [
      "openchamber" # GUI for opencode; no nixpkgs pkg, cask self-updates"1password"
      "1password-cli"
      "balenaetcher"
      "crystalfetch"
      "docker-desktop"
      #"gimp"
      "github-copilot-app"
      "handy"
      "jellyfin-media-player"
      "keybase"
      "macfuse"
      "mullvad-vpn" # not available for aarch64-darwin in nixpkgs
      "nextcloud"
      "openchamber" # GUI for opencode; no nixpkgs pkg, cask self-updates
      "openvpn-connect"
      "retroarch" # nixpkgs version is broken
      "signal" # not available for aarch64-darwin in nixpkgs
      "steam" # macOS-native client; nixpkgs steam is Linux-only
      "yubico-authenticator"
      #"bambu-studio"
    ];
  };
}
