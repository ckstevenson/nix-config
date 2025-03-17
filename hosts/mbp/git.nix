{ ... }: {
  programs.git = {
    enable = true;
    userName  = "Cameron Stevenson";
    userEmail = "cameron.stevenson@kaleris.com";
    extraConfig = {
      push.autoSetupRemote = true;
      url = {
         "ssh://git@github.com/" = {
           insteadOf = "https://github.com/";
         };
      };
    };
  };
}
