/mob/verb/request_music()
	set category = "OOC"
	set name = "Request Music"

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	var/msg = tgui_input_text(usr.client, "Please Input a URL", "Music Request", "")
	if(!msg)
		return
	log_prayer("[src.key]/([src.name]): [msg]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, span_danger("You cannot pray (pray-muted)."), confidential = TRUE)
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/msg_tmp = msg
	msg = span_adminnotice("<b><font color='cyan'>MUSIC REQUEST: </font>[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> [span_linkify(msg_tmp)] [ADMIN_PLAY_MUSIC(msg_tmp)]")
	for(var/client/admin_client in GLOB.admins)
		if(admin_client.prefs.chat_toggles & CHAT_PRAYER)
			to_chat(admin_client, msg, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)
	to_chat(usr, span_info("You requested: \"[msg_tmp]\" to be played."), confidential = TRUE)

	GLOB.requests.music_request(usr.client, msg_tmp)

	SSblackbox.record_feedback("tally", "requested_music", 1, "music_request") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
