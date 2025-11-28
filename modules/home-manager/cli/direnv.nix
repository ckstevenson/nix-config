{ ... }:
{
  programs = {
    direnv = {
      enable = false; # Temporarily disabled due to fish build issues
      nix-direnv.enable = false;
    };
  };
}
