/mob/verb/request_music()
	set category = "OOC"
	set name = "Request Music"

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	var/msg = tgui_input_text(usr.client, "Please Input a URL", "Music Request", "")
	//msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	log_prayer("[src.key]/([src.name]): [msg]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, span_danger("You cannot pray (muted)."), confidential = TRUE)
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/msg_tmp = msg
	msg = span_adminnotice("<b><font color='cyan'>MUSIC REQUEST: </font>[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> [span_linkify(msg_tmp)] [ADMIN_PLAY_MUSIC(msg_tmp)]")
	for(var/client/C in GLOB.admins)
		if(C.prefs.chat_toggles & CHAT_PRAYER)
			to_chat(C, msg, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)
	to_chat(usr, span_info("You request music: \"[msg_tmp]\""), confidential = TRUE)

	GLOB.requests.music_request(usr.client, msg_tmp)
