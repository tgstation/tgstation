//Speech verbs.

///what clients use to speak. when you type a message into the chat bar in say mode, this is the first thing that goes off serverside.
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	set instant = TRUE

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	//queue this message because verbs are scheduled to process after SendMaps in the tick and speech is pretty expensive when it happens.
	//by queuing this for next tick the mc can compensate for its cost instead of having speech delay the start of the next tick
	if(message)
		QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), message), SSspeech_controller)

///Whisper verb
/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"
	set instant = TRUE

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(message)
		QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_PROC_REF(/mob, whisper), message), SSspeech_controller)

/**
 * Whisper a message.
 *
 * Basic level implementation just speaks the message, nothing else.
 */
/mob/proc/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof)
	if(!message)
		return
	say(message, language = language)

///The me emote verb
/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"
	set desc = "Perform a custom emote. Leave blank to pick between an audible or a visible emote (Defaults to visible)."

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_PROC_REF(/mob, emote), "me", EMOTE_VISIBLE|EMOTE_AUDIBLE, message, TRUE), SSspeech_controller)

/mob/try_speak(message, ignore_spam = FALSE, forced = null, filterproof = FALSE)
	var/list/filter_result
	var/list/soft_filter_result
	if(client && !forced && !filterproof)
		//The filter doesn't act on the sanitized message, but the raw message.
		filter_result = CAN_BYPASS_FILTER(src) ? null : is_ic_filtered(message)
		if(!filter_result)
			soft_filter_result = CAN_BYPASS_FILTER(src) ? null : is_soft_ic_filtered(message)

	if(filter_result && !filterproof)
		//The filter warning message shows the sanitized message though.
		to_chat(src, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules."))
		to_chat(src, span_warning("\"[message]\""))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", message, filter_result)
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, LOWER_TEXT(config.ic_filter_regex.match))
		return FALSE

	if(soft_filter_result && !filterproof)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			SSblackbox.record_feedback("tally", "soft_ic_blocked_words", 1, LOWER_TEXT(config.soft_ic_filter_regex.match))
			log_filter("Soft IC", message, filter_result)
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		SSblackbox.record_feedback("tally", "passed_soft_ic_blocked_words", 1, LOWER_TEXT(config.soft_ic_filter_regex.match))
		log_filter("Soft IC (Passed)", message, filter_result)

	if(client && !(ignore_spam || forced))
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_danger("You cannot speak IC (muted)."))
			return FALSE
		if(client.handle_spam_prevention(message, MUTE_IC))
			return FALSE

	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_TRY_SPEECH, message, ignore_spam, forced)
	if(sigreturn & COMPONENT_IGNORE_CAN_SPEAK)
		return TRUE
	if(sigreturn & COMPONENT_CANNOT_SPEAK)
		return FALSE

	if(!..()) // the can_speak check
		if(HAS_MIND_TRAIT(src, TRAIT_MIMING))
			to_chat(src, span_green("Your vow of silence prevents you from speaking!"))
		else
			to_chat(src, span_warning("You find yourself unable to speak!"))
		return FALSE

	return TRUE

/mob/can_speak(allow_mimes = FALSE)
	if(!allow_mimes && HAS_MIND_TRAIT(src, TRAIT_MIMING))
		return FALSE

	if(is_muzzled())
		return FALSE

	return ..()

///Speak as a dead person (ghost etc)
/mob/proc/say_dead(message)
	var/name = real_name
	var/alt_name = ""

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	var/jb = is_banned_from(ckey, "Deadchat")
	if(QDELETED(src))
		return

	if(jb)
		to_chat(src, span_danger("You have been banned from deadchat."))
		return

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, span_danger("You cannot talk in deadchat (muted)."))
			return

		if(SSlag_switch.measures[SLOWMODE_SAY] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES) && src == usr)
			if(!COOLDOWN_FINISHED(client, say_slowmode))
				to_chat(src, span_warning("Message not sent due to slowmode. Please wait [SSlag_switch.slowmode_cooldown/10] seconds between messages.\n\"[message]\""))
				return
			COOLDOWN_START(client, say_slowmode, SSlag_switch.slowmode_cooldown)

		if(src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	var/mob/dead/observer/O = src
	if(isobserver(src) && O.deadchat_name)
		name = "[O.deadchat_name]"
	else
		if(mind?.name)
			name = "[mind.name]"
		else
			name = real_name
		if(name != real_name)
			alt_name = " (died as [real_name])"

	var/spanned = say_quote(say_emphasis(message))
	var/source = "<span class='game'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name]"
	var/rendered = " <span class='message'>[emoji_parse(spanned)]</span></span>"
	log_talk(message, LOG_SAY, tag="DEAD")
	if(SEND_SIGNAL(src, COMSIG_MOB_DEADSAY, message) & MOB_DEADSAY_SIGNAL_INTERCEPT)
		return
	var/displayed_key = key
	if(client?.holder?.fakekey)
		displayed_key = null
	deadchat_broadcast(rendered, source, follow_target = src, speaker_key = displayed_key)

///Check if this message is an emote
/mob/proc/check_emote(message, forced)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE

///Check if the mob has a hivemind channel
/mob/proc/hivecheck()
	return FALSE

///The amount of items we are looking for in the message
#define MESSAGE_MODS_LENGTH 6

/mob/proc/check_for_custom_say_emote(message, list/mods)
	var/customsaypos = findtext(message, "*")
	if(!customsaypos)
		return message
	if (!isnull(ckey) && is_banned_from(ckey, "Emote"))
		return copytext(message, customsaypos + 1)
	mods[MODE_CUSTOM_SAY_EMOTE] = copytext(message, 1, customsaypos)
	message = copytext(message, customsaypos + 1)
	if (!message)
		mods[MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		message = "an interesting thing to say"
	return message
/**
 * Extracts and cleans message of any extenstions at the begining of the message
 * Inserts the info into the passed list, returns the cleaned message
 *
 * Result can be
 * * SAY_MODE (Things like aliens, channels that aren't channels)
 * * MODE_WHISPER (Quiet speech)
 * * MODE_SING (Singing)
 * * MODE_HEADSET (Common radio channel)
 * * RADIO_EXTENSION the extension we're using (lots of values here)
 * * RADIO_KEY the radio key we're using, to make some things easier later (lots of values here)
 * * LANGUAGE_EXTENSION the language we're trying to use (lots of values here)
 */
/mob/proc/get_message_mods(message, list/mods)
	for(var/I in 1 to MESSAGE_MODS_LENGTH)
		// Prevents "...text" from being read as a radio message
		if (length(message) > 1 && message[2] == message[1])
			continue

		var/key = message[1]
		var/chop_to = 2 //By default we just take off the first char
		if(key == "#" && !mods[WHISPER_MODE])
			mods[WHISPER_MODE] = MODE_WHISPER
		else if(key == "%" && !mods[MODE_SING])
			mods[MODE_SING] = TRUE
		else if(key == ";" && !mods[MODE_HEADSET])
			if(stat == CONSCIOUS) //necessary indentation so it gets stripped of the semicolon anyway.
				mods[MODE_HEADSET] = TRUE
		else if((key in GLOB.department_radio_prefixes) && length(message) > length(key) + 1 && !mods[RADIO_EXTENSION])
			mods[RADIO_KEY] = LOWER_TEXT(message[1 + length(key)])
			mods[RADIO_EXTENSION] = GLOB.department_radio_keys[mods[RADIO_KEY]]
			chop_to = length(key) + 2
		else if(key == "," && !mods[LANGUAGE_EXTENSION])
			for(var/ld in GLOB.all_languages)
				var/datum/language/LD = ld
				if(initial(LD.key) == message[1 + length(message[1])])
					// No, you cannot speak in xenocommon just because you know the key
					if(!can_speak_language(LD))
						return message
					mods[LANGUAGE_EXTENSION] = LD
					chop_to = length(key) + length(initial(LD.key)) + 1
			if(!mods[LANGUAGE_EXTENSION])
				return message
		else
			return message
		message = trim_left(copytext_char(message, chop_to))
		if(!message)
			return
	return message

#undef MESSAGE_MODS_LENGTH
