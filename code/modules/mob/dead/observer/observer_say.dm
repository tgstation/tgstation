/mob/dead/observer/check_emote(message, forced)
	return emote(copytext(message, length(message[1]) + 1), intentional = !forced, force_silence = TRUE)

//Modified version of get_message_mods, removes the trimming, the only thing we care about here is admin channels
/mob/dead/observer/get_message_mods(message, list/mods)
	var/key = message[1]
	if((key in GLOB.department_radio_prefixes) && length(message) > length(key) + 1 && !mods[RADIO_EXTENSION])
		mods[RADIO_KEY] = LOWER_TEXT(message[1 + length(key)])
		mods[RADIO_EXTENSION] = GLOB.department_radio_keys[mods[RADIO_KEY]]
	return message

/mob/dead/observer/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language,
	ignore_spam = FALSE,
	forced,
	filterproof = FALSE,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	message = trim(message) //trim now and sanitize after checking for special admin radio keys

	var/list/filter_result = CAN_BYPASS_FILTER(src) ? null : is_ooc_filtered(message)
	if (filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("OOC", message, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(src) ? null : is_soft_ooc_filtered(message)
	if (soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")

	if(!message)
		return
	message = get_message_mods(message, message_mods)
	if(client?.holder && (message_mods[RADIO_EXTENSION] == MODE_ADMIN || message_mods[RADIO_EXTENSION] == MODE_DEADMIN || (message_mods[RADIO_EXTENSION] == MODE_PUPPET && mind?.current)))
		message = trim_left(copytext_char(message, length(message_mods[RADIO_KEY]) + 2))
		switch(message_mods[RADIO_EXTENSION])
			if(MODE_ADMIN)
				SSadmin_verbs.dynamic_invoke_verb(client, /datum/admin_verb/cmd_admin_say, message)
			if(MODE_DEADMIN)
				SSadmin_verbs.dynamic_invoke_verb(client, /datum/admin_verb/dsay, message)
			if(MODE_PUPPET)
				if(!mind.current.say(message))
					to_chat(src, span_warning("Your linked body was unable to speak!"))
		return

	message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(message[1] == "*" && check_emote(message, forced))
		return

	. = say_dead(message)

/mob/dead/observer/Hear(atom/movable/speaker, message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, list/spans, list/message_mods = list(), message_range)
	. = ..()
	var/atom/movable/to_follow = speaker
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker

		if(isAI(V.source))
			var/mob/living/silicon/ai/S = V.source
			to_follow = S.eyeobj
		else
			to_follow = V.source
	var/link = FOLLOW_LINK(src, to_follow)
	// Create map text prior to modifying message for goonchat
	if (safe_read_pref(client, /datum/preference/toggle/enable_runechat) && (safe_read_pref(client, /datum/preference/toggle/enable_runechat_non_mobs) || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans)
	// Recompose the message, because it's scrambled by default
	var/message = compose_message(speaker, message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, spans, message_mods)
	to_chat(src,
		html = "[link] [message]",
		avoid_highlighting = speaker == src)
	return TRUE
