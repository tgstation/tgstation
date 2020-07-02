/*********************************
For the main html chat area
*********************************/

/// Should match the value set in the browser js
#define MAX_COOKIE_LENGTH 5

/**
  * The chatOutput datum exists to handle the goonchat browser.
  * On client, created on Client/New()
  */
/datum/chat_output
	/// The client that owns us.
	var/client/owner
	/// How many times client data has been checked
	var/total_checks = 0
	/// When to next clear the client data checks counter
	var/next_time_to_clear = 0
	/// Has the client loaded the browser output area?
	var/loaded = FALSE
	/// If they haven't loaded chat, this is where messages will go until they do
	var/list/messageQueue 
	var/cookieSent = FALSE // Has the client sent a cookie for analysis
	var/broken = FALSE
	var/list/connectionHistory //Contains the connection history passed from chat cookie
	var/adminMusicVolume = 25 //This is for the Play Global Sound verb

/datum/chat_output/New(client/C)
	owner = C
	messageQueue = list()
	connectionHistory = list()

/**
  * start: Tries to load the chat browser
  * Aborts if a problem is encountered.
  * Async because this is called from Client/New.
  */
/datum/chat_output/proc/start()
	set waitfor = FALSE
	//Check for existing chat
	if(!owner)
		return FALSE

	if(!winexists(owner, "browseroutput")) // Oh goddamnit.
		broken = TRUE
		message_admins("Couldn't start chat for [key_name_admin(owner)]!")
		. = FALSE
		alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return

	if(winget(owner, "browseroutput", "is-visible") == "true") //Already setup
		doneLoading()

	else //Not setup
		load()

	return TRUE

/// Loads goonchat and sends assets.
/datum/chat_output/proc/load()
	set waitfor = FALSE
	if(!owner)
		return

	var/datum/asset/stuff = get_asset_datum(/datum/asset/group/goonchat)
	stuff.send(owner)

	owner << browse(file('code/modules/goonchat/browserassets/html/browserOutput.html'), "window=browseroutput")

/// Interprets input from the client. Will send data back if required.
/datum/chat_output/Topic(href, list/href_list)
	if(usr.client != owner)
		return TRUE

	// Build arguments.
	// Arguments are in the form "param[paramname]=thing"
	var/list/params = list()
	for(var/key in href_list)
		if(length_char(key) > 7 && findtext(key, "param")) // 7 is the amount of characters in the basic param key template.
			var/param_name = copytext_char(key, 7, -1)
			var/item       = href_list[key]

			params[param_name] = item

	var/data // Data to be sent back to the chat.
	switch(href_list["proc"])
		if("doneLoading")
			data = doneLoading(arglist(params))

		if("debug")
			data = debug(arglist(params))

		if("ping")
			data = ping(arglist(params))

		if("analyzeClientData")
			data = analyzeClientData(arglist(params))

		if("setMusicVolume")
			data = setMusicVolume(arglist(params))
		if("swaptodarkmode")
			swaptodarkmode()
		if("swaptolightmode")
			swaptolightmode()

	if(data)
		ehjax_send(data = data)


/// Called on chat output done-loading by JS.
/datum/chat_output/proc/doneLoading()
	if(loaded)
		return

	testing("Chat loaded for [owner.ckey]")
	loaded = TRUE
	showChat()


	for(var/message in messageQueue)
		// whitespace has already been handled by the original to_chat
		to_chat(owner, message, handle_whitespace=FALSE)

	messageQueue = null
	sendClientData()

	syncRegex()

	//do not convert to to_chat()
	SEND_TEXT(owner, "<span class=\"userdanger\">Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")

/// Hides the standard output and makes the browser visible.
/datum/chat_output/proc/showChat()
	winset(owner, "output", "is-visible=false")
	winset(owner, "browseroutput", "is-disabled=false;is-visible=true")

/// Calls syncRegex on all currently owned chatOutput datums
/proc/syncChatRegexes()
	for (var/user in GLOB.clients)
		var/client/C = user
		var/datum/chat_output/Cchat = C.chatOutput
		if (Cchat && !Cchat.broken && Cchat.loaded)
			Cchat.syncRegex()

/// Used to dynamically add regexes to the browser output. Currently only used by the IC filter.
/datum/chat_output/proc/syncRegex()
	var/list/regexes = list()

	if (config.ic_filter_regex)
		regexes["show_filtered_ic_chat"] = list(
			config.ic_filter_regex.name,
			"ig",
			"<span class='boldwarning'>$1</span>"
		)

	if (regexes.len)
		ehjax_send(data = list("syncRegex" = regexes))

/// Sends json encoded data to the browser.
/datum/chat_output/proc/ehjax_send(client/C = owner, window = "browseroutput", data)
	if(islist(data))
		data = json_encode(data)
	C << output("[data]", "[window]:ehjaxCallback")

/**
  * Sends music data to the browser. If enabled by the browser, it will start playing.
  * Arguments:
  * music must be a https adress.
  * extra_data is a list. The keys "pitch", "start" and "end" are used.
  ** "pitch" determines the playback rate
  ** "start" determines the start time of the sound
  ** "end" determines when the musics stops playing
  */
/datum/chat_output/proc/sendMusic(music, list/extra_data)
	if(!findtext(music, GLOB.is_http_protocol))
		return
	var/list/music_data = list("adminMusic" = url_encode(url_encode(music)))

	if(extra_data?.len)
		music_data["musicRate"] = extra_data["pitch"]
		music_data["musicSeek"] = extra_data["start"]
		music_data["musicHalt"] = extra_data["end"]

	ehjax_send(data = music_data)

/// Stops music playing throw the browser.
/datum/chat_output/proc/stopMusic()
	ehjax_send(data = "stopMusic")

/// Setter for adminMusicVolume. Sanitizes the value to between 0 and 100.
/datum/chat_output/proc/setMusicVolume(volume = "")
	if(volume)
		adminMusicVolume = clamp(text2num(volume), 0, 100)

/// Sends client connection details to the chat to handle and save
/datum/chat_output/proc/sendClientData()
	//Get dem deets
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = owner.ckey
	deets["clientData"]["ip"] = owner.address
	deets["clientData"]["compid"] = owner.computer_id
	var/data = json_encode(deets)
	ehjax_send(data = data)

/// Called by client, sent data to investigate (cookie history so far)
/datum/chat_output/proc/analyzeClientData(cookie = "")
	//Spam check
	if(world.time  >  next_time_to_clear)
		next_time_to_clear = world.time + (3 SECONDS)
		total_checks = 0

	total_checks += 1

	if(total_checks > SPAM_TRIGGER_AUTOMUTE)
		message_admins("[key_name(owner)] kicked for goonchat topic spam")
		qdel(owner)
		return

	if(!cookie)
		return

	if(cookie != "none")
		var/list/connData = json_decode(cookie)
		if (connData && islist(connData) && connData.len > 0 && connData["connData"])
			connectionHistory = connData["connData"] //lol fuck
			var/list/found = new()

			if(connectionHistory.len > MAX_COOKIE_LENGTH)
				message_admins("[key_name(src.owner)] was kicked for an invalid ban cookie)")
				qdel(owner)
				return

			for(var/i in connectionHistory.len to 1 step -1)
				if(QDELETED(owner))
					//he got cleaned up before we were done
					return
				var/list/row = src.connectionHistory[i]
				if (!row || row.len < 3 || (!row["ckey"] || !row["compid"] || !row["ip"])) //Passed malformed history object
					return
				if (world.IsBanned(row["ckey"], row["ip"], row["compid"], real_bans_only=TRUE))
					found = row
					break
				CHECK_TICK

			//Uh oh this fucker has a history of playing on a banned account!!
			if (found.len > 0)
				message_admins("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				log_admin_private("[key_name(owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")

	cookieSent = TRUE

/// Called by js client every 60 seconds
/datum/chat_output/proc/ping()
	return "pong"

/// Called by js client on js error
/datum/chat_output/proc/debug(error)
	log_world("\[[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")]\] Client: [(src.owner.key ? src.owner.key : src.owner)] triggered JS error: [error]")

/// Global chat proc. to_chat_immediate will circumvent SSchat and send data as soon as possible.
/proc/to_chat_immediate(target, message, handle_whitespace = TRUE, trailing_newline = TRUE, confidential = FALSE)
	if(!target || !message)
		return

	if(target == world)
		target = GLOB.clients

	var/original_message = message
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\t", "[FOURSPACES][FOURSPACES]") //EIGHT SPACES IN TOTAL!!
	if(trailing_newline)
		message += "<br>"

	if(islist(target))
		// Do the double-encoding outside the loop to save nanoseconds
		var/twiceEncoded = url_encode(url_encode(message))
		for(var/I in target)
			var/client/C = CLIENT_FROM_VAR(I) //Grab us a client if possible

			if (!C)
				continue

			//Send it to the old style output window.
			SEND_TEXT(C, original_message)

			if(!C.chatOutput || C.chatOutput.broken) // A player who hasn't updated his skin file.
				continue

			if(!C.chatOutput.loaded)
				//Client still loading, put their messages in a queue
				C.chatOutput.messageQueue += message
				continue

			C << output(twiceEncoded, "browseroutput:output")
	else
		var/client/C = CLIENT_FROM_VAR(target) //Grab us a client if possible

		if (!C)
			return

		//Send it to the old style output window.
		SEND_TEXT(C, original_message)

		if(!C.chatOutput || C.chatOutput.broken) // A player who hasn't updated his skin file.
			return

		if(!C.chatOutput.loaded)
			//Client still loading, put their messages in a queue
			C.chatOutput.messageQueue += message
			return

		// url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the Javascript.
		C << output(url_encode(url_encode(message)), "browseroutput:output")

/// Sends a text message to the target.
/proc/to_chat(target, message, handle_whitespace = TRUE, trailing_newline = TRUE, confidential = FALSE)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(target, message, handle_whitespace, trailing_newline, confidential)
		return
	SSchat.queue(target, message, handle_whitespace, trailing_newline, confidential)

/// Dark mode light mode stuff. Yell at KMC if this breaks! (See darkmode.dm for documentation)
/datum/chat_output/proc/swaptolightmode()
	owner.force_white_theme()

/// Light mode stuff. (See darkmode.dm for documentation)
/datum/chat_output/proc/swaptodarkmode()
	owner.force_dark_theme()

#undef MAX_COOKIE_LENGTH
