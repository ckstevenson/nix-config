{ config, pkgs, lib, inputs, ... }:
let
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
  options.gaming.enable = lib.mkEnableOption "gaming applications and tools";

  config = lib.mkIf config.gaming.enable {
    home.packages = with pkgs; [
      goverlay
      gamescope
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
