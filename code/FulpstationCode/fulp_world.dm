

/world/proc/update_status_fulp()

	var/list/features = list()

	//if(GLOB.master_mode)
	//	features += GLOB.master_mode	// FULP REMOVE: This is done below

	if (!GLOB.enter_allowed)
		features += "closed"

	var/s = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if (server_name)
			s += "<b>[server_name]</b>\] &#8212; " // Fulpstation: added "\]" so we close the name with a ]  This looks clean!
		features += "[CONFIG_GET(flag/norespawn) ? "no " : ""]respawn"
		if(CONFIG_GET(flag/allow_vote_mode))
			features += "vote"
		if(CONFIG_GET(flag/allow_ai))
			features += "AI allowed"
		hostedby = CONFIG_GET(string/hostedby)

	var/server_caption = CONFIG_GET(string/servercaption)
	s+= "<b>[server_caption]</b>" // SSETH FANS WELCOME! // "<b>The Problems of the Future, <i>Today!</i></b>"  // "<b>[station_name()]</b>";	// FULPSTATION: We don't display the name of the Station anymore
	s += " ("
	//s += "<a href=\"[CONFIG_GET(string/forumurl)]\">"//Change this to wherever you want the hub to link to.
	//	s += "[game_version]"
	//s += "Forums"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	//s += "</a>"
	//s += " | "
	s += "<a href=\"[CONFIG_GET(string/discordurl)]\">"//Change this to wherever you want the hub to link to
	s += "Discord"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")<br>"

	// Fulp Description
	s += "<br>Beginner Station: <b>Learn to play SS13!</b>"
	s += "<br>Roleplay: \[<b>Medium</b>\]"
	if(GLOB.master_mode)
		s += "<br>Mode: \[<b>" + (GLOB.master_mode == "secret_extended" ? "secret" : GLOB.master_mode) + "</b>"//\]" // FULPSTATION: What's the point in making it secret if it's going to just say the actual mode (extended)?
		// NOTE: If this is the LAST THING to be added to the description, then it'll end with a ] anyway. So don't include it here

	var/players = GLOB.clients.len

	var/popcaptext = ""
	var/popcap = max(CONFIG_GET(number/extreme_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/soft_popcap))
	if (popcap)
		popcaptext = "/[popcap]"

	if (players > 1)
		features += "[players][popcaptext] players"
	else if (players > 0)
		features += "[players][popcaptext] player"

	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full

	if (!host && hostedby)
		features += "hosted by <b>[hostedby]</b>"

	// FUPLP REMOVE: We don't list features!
	//if (features)
	//	s += ": [jointext(features, ", ")]"

	//s += "<br>Light RP, New Antagonists"

	status = s
	return s