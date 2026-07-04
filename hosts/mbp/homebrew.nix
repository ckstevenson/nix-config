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
      #"bambu-studio"
      "1password"
      "1password-cli"
      "crystalfetch"
      "docker-desktop"
      "gimp"
      "handy"
      "keybase"
      "macfuse"
      "mullvad-vpn" # not available for aarch64-darwin in nixpkgs
      "nextcloud"
      "openvpn-connect"
      "retroarch" # nixpkgs version is broken
      "signal" # not available for aarch64-darwin in nixpkgs
      "yubico-authenticator"
    ];
  };
}
