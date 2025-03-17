{ pkgs, ... }: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "cksteve@protonmail.com";
      pinentry = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-bemenu;
      base_url = "https://vw.germerica.us";
    };
  };
}
