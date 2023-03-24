/mob/verb/request_music()
	set category = "OOC"
	set name = "Request Music"

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	var/request_url = tgui_input_text(usr.client, "Please Input a URL", "Music Request", "")
	if(!request_url)
		return

	//regex filter
	if(!findtext(request_url, "youtube.com/watch?v=") && !findtext(request_url, "youtu.be/") && !findtext(request_url, "soundcloud.com/"))
		to_chat(usr, span_danger("Invalid URL. Please use a YouTube URL, or Soundcloud URL"), confidential = TRUE)
		return

	log_music_req("[src.key]/([src.name]): [request_url]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_MUSIC_REQ)
			to_chat(usr, span_danger("You cannot request music at this time. (muted)."), confidential = TRUE)
			return
		if(src.client.handle_spam_prevention(request_url,MUTE_MUSIC_REQ))
			return

	GLOB.requests.music_request(usr.client, request_url)
	to_chat(usr, span_info("You requested: \"[request_url]\" to be played."), confidential = TRUE)
	request_url = span_adminnotice("<b><font color='cyan'>MUSIC REQUEST: </font>[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> [span_linkify(request_url)] [ADMIN_PLAY_MUSIC(request_url)]")
	for(var/client/admin_client in GLOB.admins)
		if(admin_client.prefs.chat_toggles & CHAT_PRAYER)
			to_chat(admin_client, request_url, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)

	SSblackbox.record_feedback("tally", "music_request", 1, "Music Request") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
