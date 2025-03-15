# PR Announcer

This is the service used to relay GitHub PR events to game servers.

## Building

You must acquire the .NET 8 SDK or greater for your system. See https://dotnet.microsoft.com/en-us/download

Run `dotnet publish Tgstation.PRAnnouncer.csproj -o <output directory>` an executable should be generated in your output directory.

## Running

This is a long running daemon best served under systemd or as a Windows service.

This service has first class support for running under nix via the [flake.nix](./flake.nix) file which can be directly imported from GitHub.

See an example of what systemd unit settings should be used in [tgstation-pr-announcer.nix](./tgstation-pr-announcer.nix) under `systemd.services.tgstation-pr-announcer`.

### Configuration

Create an `appsettings.Production.json` file in the working directory the daemon will be launched from.

Here's an example config:
```json
{
	"Settings": {
		"CommsKey": "<COMMS_KEY config setting>",
		"GitHubSecret": "<GitHub webhook secret>",
		"GameServerHealthCheckSeconds": 30,
		"Servers": [
			{
				"Address": "blockmoths.tg.lan",
				"Port": 3336,
				"InterestedRepoSlugs": [
					"tgstation/tgstation"
				]
			},
			{
				"Address": "tgsatan.tg.lan",
				"Port": 1337,
				"InterestedRepoSlugs": [
					"tgstation/tgstation"
				]
			},
			{
				"Address": "tgsatan.tg.lan",
				"Port": 1447,
				"InterestedRepoSlugs": [
					"tgstation/tgstation"
				]
			},
			{
				"Address": "tgsatan.tg.lan",
				"Port": 5337,
				"InterestedRepoSlugs": [
					"tgstation/TerraGov-Marine-Corps"
				]
			}
		]
	},
	"Kestrel": {
		"Endpoints": {
			"Http": {
				"Url": "http://0.0.0.0:11337" // This is the port the daemon will be hosted on.
			}
		}
	}
}
```

### HTTPS

This service only operates over HTTP. HTTPS must be setup by routing through a reverse proxy of choice.
