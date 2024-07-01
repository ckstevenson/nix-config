{ pkgs, ... }: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "cksteve@protonmail.com";
      pinentry = pkgs.pinentry-bemenu;
      base_url = "https://vw.germerica.us";
    };
  };
}
