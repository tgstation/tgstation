{
  pkgs,
  ...
}:

pkgs.buildDotnetModule  {
  pname = "tgstation-pr-announcer";
  version = "1.0.0";

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
