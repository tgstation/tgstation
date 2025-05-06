{
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv lib;

  versionParse = stdenv.mkDerivation {
    pname = "tgstation-pr-announcer-version-parse";
    version = "1.0.0";

    meta = with pkgs.lib; {
      description = "Version parser for tgstation-pr-announcer";
      homepage = "https://github.com/tgstation/tgstation";
      license = licenses.agpl3Plus;
      platforms = platforms.x86_64;
    };

    nativeBuildInputs = with pkgs; [
      xmlstarlet
    ];

    src = ./.;

    installPhase = ''
      mkdir -p $out
      xmlstarlet sel --template --value-of /Project/PropertyGroup/Version ./Tgstation.PRAnnouncer.csproj > $out/tgstation-pr-announcer-version.txt
    '';
  };
  version = (builtins.readFile "${versionParse}/tgstation-pr-announcer-version.txt");
in
pkgs.buildDotnetModule  {
  pname = "tgstation-pr-announcer";
  version = (builtins.readFile "${versionParse}/tgstation-pr-announcer-version.txt");

  meta = with pkgs.lib; {
    description = "Tool for forwarding GitHub webhooks for PRs to DM game servers";
    homepage = "https://github.com/tgstation/tgstation";
    license = licenses.agpl3Plus;
    platforms = platforms.x86_64;
  };

  nativeBuildInputs = with pkgs; [
    versionParse
  ];

  src = ./.;

  projectFile = "Tgstation.PRAnnouncer.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
  dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;

  executables = [ "Tgstation.PRAnnouncer" ];
}
