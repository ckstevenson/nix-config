# To update: find the new osx-arm64 release at
# https://github.com/microsoft/artifacts-credprovider/releases
# then run:
#   nix-prefetch-url --unpack <new-zip-url>
#   nix hash convert --hash-algo sha256 --to sri <resulting-hash>
# Update the url and sha256 below with the results.
{ pkgs, ... }:
let
  credProvider = pkgs.fetchzip {
    url = "https://github.com/microsoft/artifacts-credprovider/releases/download/v2.0.1/Microsoft.osx-arm64.NuGet.CredentialProvider.zip";
    sha256 = "sha256-dVyrtDuqYdo4qWIKbu+rDxsXYkaIHc5el14kRSrJSBg="; #pragma: allowlist secret
    stripRoot = false;
  };
in
{
  home.file.".nuget/plugins/netcore/CredentialProvider.Microsoft" = {
    source = "${credProvider}/plugins/netcore/CredentialProvider.Microsoft";
    recursive = true;
  };
}
