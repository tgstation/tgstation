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
      xmlstarlet sel --template --value-of /X:Project/X:PropertyGroup/X:Version ./Tgstation.PRAnnouncer.csproj > $out/tgstation-pr-announcer-version.txt
    '';
  };
  version = (builtins.readFile "${versionParse}/tgstation-pr-announcer-version.txt");
in
stdenv.mkDerivation {
  pname = "tgstation-pr-announcer";
  version = (builtins.readFile "${versionParse}/tgstation-pr-announcer-version.txt");

  meta = with pkgs.lib; {
    description = "Tool for forwarding GitHub webhooks for PRs to DM game servers";
    homepage = "https://github.com/tgstation/tgstation";
    license = licenses.agpl3Plus;
    platforms = platforms.x86_64;
  };

  buildInputs = with pkgs; [
		dotnetCorePackages.runtime_8_0
  ];
  nativeBuildInputs = with pkgs; [
    dotnetCorePackages.sdk_8_0
    makeWrapper
    versionParse
  ];

  src = ./.;

  buildPhase = ''
		${pkgs.dotnetCorePackages.sdk_8_0}/bin/dotnet build -c Release
  '';

  installPhase = ''
    dotnet publish --no-build -o $out/bin
    makeWrapper ${pkgs.dotnetCorePackages.runtime_8_0}/bin/dotnet $out/bin/tgstation-server
  '';
}
