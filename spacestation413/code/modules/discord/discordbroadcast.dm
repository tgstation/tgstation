/world/proc/DiscordBroadcast(message)
	// TODO: error handling
	world.Export("http://[CONFIG_GET(string/discord_webhook_script_address)]/broadcast?msg=[url_encode(message)]")

