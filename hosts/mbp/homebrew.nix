{ ... }: {
  homebrew = {
    enable = true;
    brews = [
      "choose-gui"
    ];
    casks = [
      "1password"
      "1password-cli"
      "bambu-studio"
      "docker"
      "firefox"
      "keybase"
      "macfuse"
      "mullvadvpn"
      "nextcloud"
      "openvpn-connect"
      "remote-desktop-manager"
      "signal"
      "yubico-authenticator"
    ];
  };
}
