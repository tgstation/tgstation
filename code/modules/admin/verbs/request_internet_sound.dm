/mob/verb/request_internet_sound()
	set category = "OOC"
	set name = "Request Internet Sound"

	if(!CONFIG_GET(flag/request_internet_sound))
		to_chat(usr, span_danger("This server has disabled internet sound requests."), confidential = TRUE)
		return

	var/request_url = tgui_input_text(usr, "Please input a URL. Supported sources: [replacetext(replacetext(CONFIG_GET(string/request_internet_allowed), "\\", ""), ",", ", ")].", "Request Intenet sound")
	if(!request_url)
		return

	var/regex/allowed_regex = regex(replacetext(CONFIG_GET(string/request_internet_allowed), ",", "|"), "i")
	if(!allowed_regex.Find(request_url))
		to_chat(usr, span_danger("Invalid URL. Please use a URL from one of the following sites: [replacetext(CONFIG_GET(string/request_internet_allowed), "\\", " ")]"), confidential = TRUE)
		return

	var/credit = tgui_alert(usr, "Credit yourself for requesting this song? (will show up as [usr.ckey])", "Credit Yourself?", list("No", "Yes", "Cancel"))

	if(credit == "Cancel" || isnull(credit))
		return

	else if (credit == "Yes")
		credit = "[usr.ckey] requested this track."
	else
		credit = null

	log_internet_request("[src.key]/([src.name]): [request_url]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_INTERNET_REQUEST)
			to_chat(usr, span_danger("You cannot request music at this time. (muted)."), confidential = TRUE)
			return
		if(src.client.handle_spam_prevention(request_url,MUTE_INTERNET_REQUEST))
			return

	GLOB.requests.music_request(usr.client, request_url, credit)
	to_chat(usr, span_info("You requested [span_linkify(request_url)] to be played."), confidential = TRUE)

	var/list/admin_message = list()
	admin_message += ("[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)] has requested the following to be played:<br>")
	admin_message += ("[span_linkify(request_url)] [ADMIN_PLAY_INTERNET(request_url, credit)]")

	for(var/client/admin_client in GLOB.admins)
		if(get_chat_toggles(admin_client) & CHAT_PRAYER)
			to_chat(admin_client, fieldset_block("Internet sound requested", jointext(admin_message, ""), "boxed_message"), type = MESSAGE_TYPE_PRAYER, confidential = TRUE)

	SSblackbox.record_feedback("tally", "music_request", 1, "Music Request") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
