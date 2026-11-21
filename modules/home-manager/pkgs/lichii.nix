{ appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  pname = "lichii";
  version = "build-366";

  src = fetchurl {
    url = "https://github.com/zortos293/Lichii/releases/download/${version}/lichii-linux-x86_64.AppImage";
    hash = "sha256-SQdpsHA8py4o44AXEcAxICIqHDxay0tKd6I4AtcVJxw=";
  };
}
