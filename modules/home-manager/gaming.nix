{ config, pkgs, lib, ... }:
{
  options.gaming.enable = lib.mkEnableOption "gaming applications and tools";

  config = lib.mkIf config.gaming.enable {
    home.packages = with pkgs; [
      goverlay
      gamescope
      lutris
      mangohud
      protonup-qt
      (retroarch.withCores (
        libretro: with libretro; [
          beetle-psx-hw
          desmume
          dolphin
          fceumm
          genesis-plus-gx
          mame
          melonds
          mgba
          mupen64plus
          ppsspp
          snes9x
          stella
        ]
      ))
      vkbasalt
    ];
  };
}
