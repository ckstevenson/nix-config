{ config, pkgs, lib, inputs, ... }:
let
  lichii = pkgs.callPackage ./pkgs/lichii.nix { };
  nexus = pkgs.callPackage "${inputs.nexus.outPath}/nix/package.nix" {
    buildFHSEnv = args: pkgs.buildFHSEnv (args // {
      multiArch = true;
      multiPkgs = fhsPkgs: (args.multiPkgs fhsPkgs) ++ [ fhsPkgs.gnutls ];
    });
    nexusRuntime = inputs.nexus.packages.${pkgs.stdenv.hostPlatform.system}.nexus-runtime;
    src = inputs.nexus.outPath;
  };
in
{
  options.gaming = {
    enable = lib.mkEnableOption "gaming applications and tools";

    emulators = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install standalone console emulators alongside RetroArch.";
      };

      experimental.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install experimental console emulators.";
      };
    };
  };

  config = lib.mkIf config.gaming.enable {
    home.packages = with pkgs; [
      goverlay
      (limo.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/core/progressnode.h \
            --replace-fail '#include <vector>' '#include <vector>
          #include <cstdint>'
          substituteInPlace src/core/progressnode.cpp \
            --replace-fail '#include <numeric>' '#include <numeric>
          #include <cstdint>'
          substituteInPlace src/core/versionchangelog.cpp \
            --replace-fail '#include <algorithm>' '#include <algorithm>
          #include <iomanip>'
        '';
      }))
      lutris
      mangohud
      nexus
      protonup-qt
      steam-rom-manager
      (retroarch.withCores (
        libretro: with libretro; [
          beetle-psx-hw
          beetle-saturn
          beetle-pce-fast
          bsnes
          desmume
          dolphin
          fceumm
          fbneo
          flycast
          gambatte
          genesis-plus-gx
          mame
          melonds
          mgba
          mupen64plus
          parallel-n64
          picodrive
          ppsspp
          snes9x
          stella
          swanstation
        ]
      ))
      vkbasalt
    ] ++ lib.optionals config.gaming.emulators.enable [
      azahar
      cemu
      dolphin-emu
      eden
      pcsx2
      ppsspp
      rpcs3
      ryubing
      vita3k
      xemu
      xenia-canary
    ] ++ lib.optionals config.gaming.emulators.experimental.enable [
      lichii
      shadps4
    ];
  };
}
