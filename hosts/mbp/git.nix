{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Cameron Stevenson";
        email = "cameron.stevenson@kaleris.com";
      };
      push.autoSetupRemote = true;
      url = {
         "ssh://git@github.com/" = {
           insteadOf = "https://github.com/";
         };
      };
    };
  };
}
