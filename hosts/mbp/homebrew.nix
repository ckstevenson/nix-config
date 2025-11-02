{ ... }: {
  homebrew = {
    enable = true;
    brews = [
      "choose-gui"
    ];
    casks = [
      "1password"
      "1password-cli"
      #"bambu-studio
      "crystalfetch"
      "docker-desktop"
      "firefox"
      "keybase"
      "macfuse"
      "mullvad-vpn"
      "nextcloud"
      "openvpn-connect"
      "retroarch"
      "signal"
      "yubico-authenticator"
      "zen"
    ];
  };
}
