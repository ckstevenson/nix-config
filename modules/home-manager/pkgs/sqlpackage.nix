{ pkgs, lib, ... }:
let
  sqlpackage = pkgs.buildDotnetGlobalTool {
    pname = "sqlpackage";
    version = "170.2.70";
    nugetName = "Microsoft.SqlPackage";

    dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
    dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;

    nugetHash = "sha256-HTx797aoHiRbJN6PvT6Vi1qFrKmhhyiZNGJErzHZf40="; #pragma: allowlist secret

    meta = {
      description = "Microsoft SQL Server Data-Tier Application Framework CLI";
      longDescription = ''
        SqlPackage is a command-line utility for SQL Server database development.
        It supports extracting/exporting databases to DAC packages, deploying DAC
        packages, and migrating between on-premises and Azure SQL.
      '';
      homepage = "https://learn.microsoft.com/sql/tools/sqlpackage";
      downloadPage = "https://www.nuget.org/packages/Microsoft.SqlPackage";
      license = lib.licenses.unfree;
      mainProgram = "sqlpackage";
    };
  };
in
{
  home.packages = [
    sqlpackage
  ];
}
