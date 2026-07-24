# Adding a New Host

Step-by-step guide for adding a new host to this flake-based configuration.

1. Create host directory

```bash
mkdir hosts/new-hostname
```

2. Add base configuration (hosts/new-hostname/configuration.nix)

```nix
{ inputs, pkgs, ... }: {
  imports = [
    ../../modules/nixos
    ./hardware-configuration.nix
    ./home.nix
  ];

  networking.hostName = "new-hostname";
  desktop.enable = true;
  laptop.enable = false;
}
```

3. Create home configuration (hosts/new-hostname/home.nix)

```nix
{ inputs, ... }: {
  imports = [ ../../modules/home-manager ];

  home = {
    username = "cameronstevenson";
    homeDirectory = "/home/cameronstevenson";
    stateVersion = "24.11";
  };
}
```

4. Add to flake.nix (nixosConfigurations)

5. Generate hardware configuration

```bash
nixos-generate-config --root /mnt --dir hosts/new-hostname/
```

6. Build and test

```bash
nixos-rebuild build --flake .#new-hostname
```
