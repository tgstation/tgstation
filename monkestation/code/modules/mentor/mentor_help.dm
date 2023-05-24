

/client/verb/mentorhelp(msg as text)
	set category = "Mentor"
	set name = "Mentorhelp"

	//clean the input msg
	if(!msg)	return

	//remove out mentorhelp verb temporarily to prevent spamming of mentors.
	verbs -= /client/verb/mentorhelp
	spawn(300)
		verbs += /client/verb/mentorhelp	// 30 second cool-down for mentorhelp

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)	return
	if(!mob)	return						//this doesn't happen

	var/show_char = CONFIG_GET(flag/mentors_mobname_only)
	var/mentor_msg = "<span class='mentornotice'><b><font color='purple'>MENTORHELP:</b> <b>[key_name_mentor(src, 1, 0, 1, show_char)]</b>: [msg]</font></span>"
	log_mentor("MENTORHELP: [key_name_mentor(src, 0, 0, 0, 0)]: [msg]")

	for(var/client/X in GLOB.mentors | GLOB.admins)
		X << 'sound/items/bikehorn.ogg'
		to_chat(X, mentor_msg)

	to_chat(src,
		type = MESSAGE_TYPE_MENTORCHAT,
		html = "<span class='mentornotice'><font color='purple'>PM to-<b>Mentors</b>: [msg]</font></span>")


	var/regular_webhook_url = CONFIG_GET(string/regular_mentorhelp_webhook_url)
	if(regular_webhook_url)
		var/extra_message = CONFIG_GET(string/mhelp_message)
		var/datum/discord_embed/embed = format_mhelp_embed(msg)
		embed.content = extra_message
		send2mentorchat_webhook(embed, key)

	return

/proc/get_mentor_counts()
	. = list("total" = 0, "afk" = 0, "present" = 0)
	for(var/X in GLOB.mentors)
		var/client/C = X
		.["total"]++
		if(C.is_afk())
			.["afk"]++
		else
			.["present"]++

/proc/key_name_mentor(var/whom, var/include_link = null, var/include_name = 0, var/include_follow = 0, var/char_name_only = 0)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = GLOB.directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(include_link)
			if(CONFIG_GET(flag/mentors_mobname_only))
				. += "<a href='?_src_=mentor;mentor_msg=[REF(M)];[MentorHrefToken(TRUE)]'>"
			else
				. += "<a href='?_src_=mentor;mentor_msg=[ckey];[MentorHrefToken(TRUE)]'>"

		if(C && C.holder && C.holder.fakekey)
			. += "Administrator"
		else if (char_name_only && CONFIG_GET(flag/mentors_mobname_only))
			if(istype(C.mob,/mob/dead/new_player) || istype(C.mob, /mob/dead/observer)) //If they're in the lobby or observing, display their ckey
				. += key
			else if(C && C.mob) //If they're playing/in the round, only show the mob name
				. += C.mob.name
			else //If for some reason neither of those are applicable and they're mentorhelping, show ckey
				. += key
		else
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_follow)
		. += " (<a href='?_src_=mentor;mentor_follow=[REF(M)];[MentorHrefToken(TRUE)]'>F</a>)"

	return .

/proc/format_mhelp_embed(message, ckey)
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
	var/list/mentor_count = get_mentor_counts()
	var/player_count = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"
	if(mentor_count)
		admin_text = "**Mentors**:[mentor_count.len]"
	embed.fields = list(
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
