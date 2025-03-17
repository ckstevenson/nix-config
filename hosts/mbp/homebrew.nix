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
      "macfuse"
      "mullvadvpn"
      "nextcloud"
      "openvpn-connect"
      "remote-desktop-manager"
      "signal"
    ];
  };
}
