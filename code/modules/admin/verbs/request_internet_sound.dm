/mob/verb/request_internet_sound()
	set category = "OOC"
	set name = "Request Internet Sound"

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	if (!CONFIG_GET(flag/request_internet_sound))
		to_chat(usr, span_danger("This server has disabled internet sound requests."), confidential = TRUE)
		return

	var/request_url = tgui_input_text(usr, "Please Input a URL", "Only certain sites are allowed, such as YouTube, SoundCloud, and Bandcamp.", "")
	if(!request_url)
		return

	//regex filter
	var/regex/allowed_regex = regex(replacetext(CONFIG_GET(string/request_internet_allowed), ",", "|"), "i")
	if(!allowed_regex.Find(request_url))
		to_chat(usr, span_danger("Invalid URL. Please use a URL from one of the following sites: [replacetext(CONFIG_GET(string/request_internet_allowed), "\\", "")]"), confidential = TRUE)
		return

	request_url = shell_url_scrub(request_url)
	log_internet_request("[src.key]/([src.name]): [request_url]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_INTERNET_REQUEST)
			to_chat(usr, span_danger("You cannot request music at this time. (muted)."), confidential = TRUE)
			return
		if(src.client.handle_spam_prevention(request_url,MUTE_INTERNET_REQUEST))
			return

	GLOB.requests.music_request(usr.client, request_url)
	to_chat(usr, span_info("You requested: \"[request_url]\" to be played."), confidential = TRUE)
	request_url = span_adminnotice("<b><font color='cyan'>MUSIC REQUEST: </font>[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> [span_linkify(request_url)] [ADMIN_PLAY_INTERNET(request_url)]")
	for(var/client/admin_client in GLOB.admins)
		if(admin_client.prefs.chat_toggles & CHAT_PRAYER)
			to_chat(admin_client, request_url, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)

	SSblackbox.record_feedback("tally", "music_request", 1, "Music Request") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
