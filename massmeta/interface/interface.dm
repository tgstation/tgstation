/client/verb/discord()
	set name = "discord"
	set hidden = TRUE

	if(alert("This will open our Discord in your browser. Are you sure?", "Discord", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link("https://discord.gg/Pp7SpQgvNt"))
