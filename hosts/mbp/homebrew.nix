{ ... }: {
  homebrew = {
    enable = true;

    # Update Homebrew and packages on system rebuild
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    brews = [
      "choose-gui"
    ];
    casks = [
      "1password"
      "1password-cli"
      "bambu-studio"
      "crystalfetch"
      "docker-desktop"
      "keybase"
      "macfuse"
      "mullvad-vpn"
      "nextcloud"
      "openvpn-connect"
      "retroarch"
      "signal"
      "yubico-authenticator"
      #"zen"
    ];
  };
}
