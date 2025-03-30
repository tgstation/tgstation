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
		"GameServerHealthCheckSeconds": 30, // How often this service will ping game servers
		"Servers": [
			{
				"Address": "blockmoths.tg.lan", // DNS/IP address of game server
				"Port": 3336, // Game server port
				"InterestedRepoSlugs": [
					"tgstation/tgstation" // List of GitHub owner/repos that notifications should be delivered for
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
				"Url": "http://0.0.0.0:11337" // This is the address the service will be hosted on.
			}
		}
	}
}
```

#### Webhook Settings

Webhook must be delivered to `/api/github/webhooks` in the `application/json` format.

Only `Pull Request` events need to be listened for.

### HTTPS

This service only operates over HTTP. HTTPS must be setup by routing through a reverse proxy of choice.
