/client/verb/joindiscord()
	set name = "discord"
	set desc = "Join Discord Server"
	set hidden = 1
	if(CONFIG_GET(string/discordurl))
		var/message = "This will open the Discord server in your browser. Are you sure?"
		if(alert(src, message, "Join Discord","Yes","No")=="No")
			return
		src << link(CONFIG_GET(string/discordurl))
	else
		to_chat(src, "<span class='danger'>The Discord URL is not set in the server configuration.</span>")
	return