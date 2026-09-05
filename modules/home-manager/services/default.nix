{ ... }: {
  imports = [
    ./backup.nix
    ./secure-backup.nix
    ./nextcloud-sync.nix
  ];
}
