/proc/format_mhelp_embed(message, id, ckey)
	var/datum/discord_embed/embed = new()
	embed.title = "Mentor Help"
	embed.description = @"[Join Server!](http://play.monkestation.com:7420)"
	embed.author = key_name(ckey)
	var/round_state
	var/admin_text
	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP, GAME_STATE_PREGAME, GAME_STATE_SETTING_UP)
			round_state = "Round has not started"
		if(GAME_STATE_PLAYING)
			round_state = "Round is ongoing."
			if(SSshuttle.emergency.getModeStr())
				round_state += "\n[SSshuttle.emergency.getModeStr()]: [SSshuttle.emergency.getTimerStr()]"
				if(SSticker.emergency_reason)
					round_state += ", Shuttle call reason: [SSticker.emergency_reason]"
		if(GAME_STATE_FINISHED)
			round_state = "Round has ended"
	var/player_count = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"
	embed.fields = list(
		"MENTOR ID" = id,
		"CKEY" = ckey,
		"PLAYERS" = player_count,
		"ROUND STATE" = round_state,
		"ROUND ID" = GLOB.round_id,
		"ROUND TIME" = ROUND_TIME(),
		"MESSAGE" = message,
		"ADMINS" = admin_text,
	)
	return embed

/proc/send2mentorchat_webhook(message_or_embed, urgent)
	var/webhook = CONFIG_GET(string/regular_mentorhelp_webhook_url)

	if(!webhook)
		return
	var/list/webhook_info = list()
	if(istext(message_or_embed))
		var/message_content = replacetext(replacetext(message_or_embed, "\proper", ""), "\improper", "")
		message_content = GLOB.has_discord_embeddable_links.Replace(replacetext(message_content, "`", ""), " ```$1``` ")
		webhook_info["content"] = message_content
	else
		var/datum/discord_embed/embed = message_or_embed
		webhook_info["embeds"] = list(embed.convert_to_list())
		if(embed.content)
			webhook_info["content"] = embed.content
	if(CONFIG_GET(string/mentorhelp_webhook_name))
		webhook_info["username"] = CONFIG_GET(string/mentorhelp_webhook_name)
	if(CONFIG_GET(string/mentorhelp_webhook_pfp))
		webhook_info["avatar_url"] = CONFIG_GET(string/mentorhelp_webhook_pfp)
	// Uncomment when servers are moved to TGS4
	// send2chat(new /datum/tgs_message_conent("[initiator_ckey] | [message_content]"), "ahelp", TRUE)
	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers, "tmp/response.json")
	request.begin_async()


/client/verb/mentorhelp(msg as text)
	set category = "Mentor"
	set name = "Mentorhelp"

	if(usr?.client?.prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<span class='danger'>Error: MentorPM: You are muted from Mentorhelps. (muted).</span>",
			confidential = TRUE)
		return
	/// Cleans the input message
	if(!msg)
		return
	/// This shouldn't happen, but just in case.
	if(!mob)
		return

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	var/mentor_msg = "<font color='purple'><span class='mentornotice'><b>MENTORHELP:</b> <b>[key_name_mentor(src, TRUE, FALSE)]</b>: </span><span class='message linkify'>[msg]</span></font>"
	log_mentor("MENTORHELP: [key_name_mentor(src, null, FALSE, FALSE)]: [msg]")

	/// Send the Mhelp to all Mentors/Admins
	for(var/client/honked_clients in GLOB.mentors | GLOB.admins)
		if(QDELETED(honked_clients?.mentor_datum) || honked_clients?.mentor_datum?.not_active)
			continue
		honked_clients << 'sound/items/bikehorn.ogg'
		to_chat(honked_clients,
			type = MESSAGE_TYPE_MODCHAT,
			html = mentor_msg,
			confidential = TRUE)

	/// Also show it to person Mhelping
	to_chat(usr,
		type = MESSAGE_TYPE_MODCHAT,
		html = "<font color='purple'><span class='mentornotice'>PM to-<b>Mentors</b>:</span> <span class='message linkify'>[msg]</span></font>",
		confidential = TRUE)

	GLOB.mentor_requests.mentorhelp(usr.client, msg)


	var/datum/request/request = GLOB.mentor_requests.requests[ckey][length(GLOB.mentor_requests.requests[ckey])]
	if(request)
		var/id = "[request.id]"
		var/regular_webhook_url = CONFIG_GET(string/regular_mentorhelp_webhook_url)
		if(regular_webhook_url)
			var/extra_message = CONFIG_GET(string/mhelp_message)
			var/datum/discord_embed/embed = format_mhelp_embed(msg, id)
			embed.content = extra_message
			send2mentorchat_webhook(embed, key)
	return

/proc/key_name_mentor(whom, include_link = null, include_name = TRUE, include_follow = TRUE, char_name_only = TRUE)
	var/mob/user
	var/client/chosen_client
	var/key
	var/ckey
	if(!whom)
		return "*null*"

	if(istype(whom, /client))
		chosen_client = whom
		user = chosen_client.mob
		key = chosen_client.key
		ckey = chosen_client.ckey
	else if(ismob(whom))
		user = whom
		chosen_client = user.client
		key = user.key
		ckey = user.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		chosen_client = GLOB.directory[ckey]
		if(chosen_client)
			user = chosen_client.mob
	else if(findtext(whom, "Discord"))
		return "<a href='?_src_=mentor;mentor_msg=[whom];[MentorHrefToken(TRUE)]'>"
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = null

	if(key)
		if(include_link != null)
			. += "<a href='?_src_=mentor;mentor_msg=[ckey];[MentorHrefToken(TRUE)]'>"

		if(chosen_client && chosen_client.holder && chosen_client.holder.fakekey)
			. += "Administrator"
		else
			. += key
		if(!chosen_client)
			. += "\[DC\]"

		if(include_link != null)
			. += "</a>"
	else
		. += "*no key*"

	if(include_follow)
		. += " (<a href='?_src_=mentor;mentor_follow=[REF(user)];[MentorHrefToken(TRUE)]'>F</a>)"

	return .
