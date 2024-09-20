{ pkgs, ... }: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "cksteve@protonmail.com";
      pinentry = pkgs.pinentry_mac;
      base_url = "https://vw.germerica.us";
    };
  };
}
