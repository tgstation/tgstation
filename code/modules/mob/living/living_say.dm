GLOBAL_LIST_INIT(department_radio_prefixes, list(":", "."))

GLOBAL_LIST_INIT(department_radio_keys, list(
	// Location
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	// Department
	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND,
	RADIO_KEY_SCIENCE = RADIO_CHANNEL_SCIENCE,
	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING,
	RADIO_KEY_SECURITY = RADIO_CHANNEL_SECURITY,
	RADIO_KEY_SUPPLY = RADIO_CHANNEL_SUPPLY,
	RADIO_KEY_SERVICE = RADIO_CHANNEL_SERVICE,

	// Faction
	RADIO_KEY_SYNDICATE = RADIO_CHANNEL_SYNDICATE,
	RADIO_KEY_UPLINK = RADIO_CHANNEL_UPLINK,
	RADIO_KEY_CENTCOM = RADIO_CHANNEL_CENTCOM,

	// Admin
	MODE_KEY_ADMIN = MODE_ADMIN,
	MODE_KEY_DEADMIN = MODE_DEADMIN,
	MODE_KEY_PUPPET = MODE_PUPPET,

	// Misc
	RADIO_KEY_AI_PRIVATE = RADIO_CHANNEL_AI_PRIVATE, // AI Upload channel
	RADIO_KEY_ENTERTAINMENT = RADIO_CHANNEL_ENTERTAINMENT, // Entertainment monitors


	//kinda localization -- rastaf0
	//same keys as above, but on russian keyboard layout.
	// Location
	"к" = MODE_R_HAND,
	"л" = MODE_L_HAND,
	"ш" = MODE_INTERCOM,

	// Department
	"р" = MODE_DEPARTMENT,
	"с" = RADIO_CHANNEL_COMMAND,
	"т" = RADIO_CHANNEL_SCIENCE,
	"ь" = RADIO_CHANNEL_MEDICAL,
	"у" = RADIO_CHANNEL_ENGINEERING,
	"ы" = RADIO_CHANNEL_SECURITY,
	"г" = RADIO_CHANNEL_SUPPLY,
	"м" = RADIO_CHANNEL_SERVICE,

	// Faction
	"е" = RADIO_CHANNEL_SYNDICATE,
	"н" = RADIO_CHANNEL_CENTCOM,

	// Admin
	"з" = MODE_ADMIN,
	"в" = MODE_KEY_DEADMIN,

	// Misc
	"щ" = RADIO_CHANNEL_AI_PRIVATE,
	"з" = RADIO_CHANNEL_ENTERTAINMENT,
))

/**
 * Whitelist of saymodes or radio extensions that can be spoken through even if not fully conscious.
 * Associated values are their maximum allowed mob stats.
 */
GLOBAL_LIST_INIT(message_modes_stat_limits, list(
	MODE_INTERCOM = HARD_CRIT,
	MODE_CHANGELING = HARD_CRIT,
	MODE_ALIEN = HARD_CRIT,
	MODE_BINARY = HARD_CRIT, //extra stat check on human/binarycheck()
	MODE_MONKEY = HARD_CRIT,
	MODE_MAFIA = HARD_CRIT
))

/mob/living/proc/Ellipsis(original_msg, chance = 50, keep_words)
	if(chance <= 0)
		return "..."
	if(chance >= 100)
		return original_msg

	var/list/words = splittext(original_msg," ")
	var/list/new_words = list()

	var/new_msg = ""

	for(var/w in words)
		if(prob(chance))
			new_words += "..."
			if(!keep_words)
				continue
		new_words += w

	new_msg = jointext(new_words," ")

	return new_msg

/mob/living/say(
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
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	var/original_message = message
	message = get_message_mods(message, message_mods)
	saymode = SSradio.saymodes[message_mods[RADIO_KEY]]
	if (!forced && !saymode)
		message = check_for_custom_say_emote(message, message_mods)

	if(!message)
		return

	if(message_mods[RADIO_EXTENSION] == MODE_ADMIN)
		SSadmin_verbs.dynamic_invoke_verb(client, /datum/admin_verb/cmd_admin_say, message)
		return

	if(message_mods[RADIO_EXTENSION] == MODE_DEADMIN)
		SSadmin_verbs.dynamic_invoke_verb(client, /datum/admin_verb/dsay, message)
		return

	// dead is the only state you can never emote
	if(stat != DEAD && check_emote(original_message, forced))
		return

	// Checks if the saymode or channel extension can be used even if not totally conscious.
	var/say_radio_or_mode = saymode || message_mods[RADIO_EXTENSION]
	if(say_radio_or_mode)
		var/mob_stat_limit = GLOB.message_modes_stat_limits[say_radio_or_mode]
		if(stat > (isnull(mob_stat_limit) ? CONSCIOUS : mob_stat_limit))
			saymode = null
			message_mods -= RADIO_EXTENSION

	switch(stat)
		if(SOFT_CRIT)
			message_mods[WHISPER_MODE] = MODE_WHISPER
		if(UNCONSCIOUS)
			return
		if(HARD_CRIT)
			if(!message_mods[WHISPER_MODE])
				return
		if(DEAD)
			say_dead(original_message, message_mods[MANNEQUIN_CONTROLLED])
			return

	if(HAS_TRAIT(src, TRAIT_SOFTSPOKEN) && !HAS_TRAIT(src, TRAIT_SIGN_LANG)) // softspoken trait only applies to spoken languages
		message_mods[WHISPER_MODE] = MODE_WHISPER

	if(client && SSlag_switch.measures[SLOWMODE_SAY] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES) && !forced && src == usr)
		if(!COOLDOWN_FINISHED(client, say_slowmode))
			to_chat(src, span_warning("Message not sent due to slowmode. Please wait [SSlag_switch.slowmode_cooldown/10] seconds between messages.\n\"[message]\""))
			return
		COOLDOWN_START(client, say_slowmode, SSlag_switch.slowmode_cooldown)

	if(!try_speak(original_message, ignore_spam, forced, filterproof))
		return

	language ||= message_mods[LANGUAGE_EXTENSION] || get_selected_language()

	var/succumbed = FALSE

	// If there's a custom say emote it gets logged differently.
	if(message_mods[MODE_CUSTOM_SAY_EMOTE])
		log_message(message_mods[MODE_CUSTOM_SAY_EMOTE], LOG_RADIO_EMOTE)

	// If it's not erasing the input portion, then something is being said and this isn't a pure custom say emote.
	if(!message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		if(message_mods[WHISPER_MODE] == MODE_WHISPER)
			message_range = 1
			log_talk(message, LOG_WHISPER, forced_by = forced, custom_say_emote = message_mods[MODE_CUSTOM_SAY_EMOTE])
			if(stat == HARD_CRIT)
				var/health_diff = round(-HEALTH_THRESHOLD_DEAD + health)
				// If we cut our message short, abruptly end it with a-..
				var/message_len = length_char(message)
				message = copytext_char(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
				message = Ellipsis(message, 10, 1)
				last_words = message
				message_mods[WHISPER_MODE] = MODE_WHISPER_CRIT
				succumbed = TRUE
		else
			log_talk(message, LOG_SAY, forced_by = forced, custom_say_emote = message_mods[MODE_CUSTOM_SAY_EMOTE])

#ifdef UNIT_TESTS
	// Saves a ref() to our arglist specifically.
	// We do this because we need to check that COMSIG_MOB_SAY is getting EXACTLY this list.
	last_say_args_ref = REF(args)
#endif

	// Make sure the arglist is passed exactly - don't pass a copy of it. Say signal handlers will modify some of the parameters.
	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_SAY, args)
	if(sigreturn & COMPONENT_UPPERCASE_SPEECH)
		message = uppertext(message)

	var/list/message_data = treat_message(message) // unfortunately we still need this
	message = message_data["message"]
	var/tts_message = message_data["tts_message"]
	var/list/tts_filter = message_data["tts_filter"]

	spans |= speech_span

	var/datum/language/spoken_lang = GLOB.language_datum_instances[language]
	if(LAZYLEN(spoken_lang?.spans))
		spans |= spoken_lang.spans

	if(message_mods[MODE_SING])
		var/randomnote = pick("\u2669", "\u266A", "\u266B")
		message = "[randomnote] [message] [randomnote]"
		spans |= SPAN_SINGING

	if(message_mods[WHISPER_MODE]) // whisper away
		spans |= SPAN_ITALICS

	if(!message)
		if(succumbed)
			succumb()
		return

	//Get which verb is prefixed to the message before radio but after most modifications
	message_mods[SAY_MOD_VERB] = say_mod(message, message_mods)

	//This is before anything that sends say a radio message, and after all important message type modifications, so you can scumb in alien chat or something
	if(saymode && !saymode.handle_message(src, message, language))
		return

	var/radio_return = radio(message, message_mods, spans, language)//roughly 27% of living/say()'s total cost
	if(radio_return & NOPASS)
		return TRUE

	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS
	if(radio_return & REDUCE_RANGE)
		message_range = 1
		if(!message_mods[WHISPER_MODE])
			message_mods[WHISPER_MODE] = MODE_WHISPER
			message_mods[SAY_MOD_VERB] = say_mod(message, message_mods)

	//No screams in space, unless you're next to someone.
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = (environment)? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE && !HAS_TRAIT(src, TRAIT_SIGN_LANG))
		message_range = 1

	if(pressure < ONE_ATMOSPHERE * (HAS_TRAIT(src, TRAIT_SPEECH_BOOSTER) ? 0.1 : 0.4)) //Thin air, let's italicise the message unless we have a loud low pressure speech trait and not in vacuum
		spans |= SPAN_ITALICS

	send_speech(message, message_range, src, bubble_type, spans, language, message_mods, forced = forced, tts_message = tts_message, tts_filter = tts_filter)//roughly 58% of living/say()'s total cost
	if(succumbed)
		succumb(TRUE)
		to_chat(src, compose_message(src, language, message, null, null, null, spans, message_mods))

	return TRUE


/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, list/spans, list/message_mods = list(), message_range=0)
	if((SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_HEAR, args) & COMSIG_MOVABLE_CANCEL_HEARING) || !GET_CLIENT(src))
		return FALSE

	var/deaf_message
	var/deaf_type

	if(speaker != src)
		deaf_type = !radio_freq ? MSG_VISUAL : null
	else
		deaf_type = MSG_AUDIBLE

	var/atom/movable/virtualspeaker/holopad_speaker = speaker
	var/avoid_highlight = src == (istype(holopad_speaker) ? holopad_speaker.source : speaker)

	var/is_custom_emote = message_mods[MODE_CUSTOM_SAY_ERASE_INPUT]
	var/understood = TRUE
	if(!is_custom_emote) // we do not translate emotes
		var/untranslated_raw_message = raw_message
		raw_message = translate_language(speaker, message_language, raw_message, spans, message_mods) // translate
		if(raw_message != untranslated_raw_message)
			understood = FALSE

	var/speaker_is_signing = HAS_TRAIT(speaker, TRAIT_SIGN_LANG)
	var/use_runechat = client?.prefs.read_preference(/datum/preference/toggle/enable_runechat)
	if (stat == UNCONSCIOUS || stat == HARD_CRIT)
		use_runechat = FALSE
	else if (!ismob(speaker) && !client?.prefs.read_preference(/datum/preference/toggle/enable_runechat_non_mobs))
		use_runechat = FALSE

	// if someone is whispering we make an extra type of message that is obfuscated for people out of range
	// Less than or equal to 0 means normal hearing. More than 0 and less than or equal to EAVESDROP_EXTRA_RANGE means
	// partial hearing. More than EAVESDROP_EXTRA_RANGE means no hearing. Exception for GOOD_HEARING trait
	var/dist = get_dist(speaker, src) - message_range
	if(dist > 0 && dist <= EAVESDROP_EXTRA_RANGE && !HAS_TRAIT(src, TRAIT_GOOD_HEARING) && !isobserver(src)) // ghosts can hear all messages clearly
		raw_message = stars(raw_message)
	if(message_range != INFINITY && dist > EAVESDROP_EXTRA_RANGE && !HAS_TRAIT(src, TRAIT_GOOD_HEARING) && !isobserver(src))
		// Too far away and don't have good hearing, you can't hear anything
		if(is_blind() || HAS_TRAIT(speaker, TRAIT_INVISIBLE_MAN)) // Can't see them speak either
			return FALSE
		if(!isturf(speaker.loc)) // If they're inside of something, probably can't see them speak
			return FALSE

		// But we can still see them speak
		if(speaker_is_signing)
			deaf_message = "[span_name("[speaker]")] [speaker.get_default_say_verb()] something, but the motions are too subtle to make out from afar."
		else if(can_hear()) // If we can't hear we want to continue to the default deaf message
			if(isliving(speaker))
				var/mob/living/living_speaker = speaker
				var/mouth_hidden = living_speaker.is_mouth_covered() || HAS_TRAIT(living_speaker, TRAIT_FACE_COVERED)
				if(!HAS_TRAIT(src, TRAIT_EMPATH) && mouth_hidden) // Can't see them speak if their mouth is covered or hidden, unless we're an empath
					return FALSE

			deaf_message = "[span_name("[speaker]")] [speaker.verb_whisper] something, but you are too far away to hear [speaker.p_them()]."

		if(deaf_message)
			deaf_type = MSG_VISUAL
			message = deaf_message
			show_message(message, MSG_VISUAL, deaf_message, deaf_type, avoid_highlight)
			return FALSE


	// we need to send this signal before compose_message() is used since other signals need to modify
	// the raw_message first. After the raw_message is passed through the various signals, it's ready to be formatted
	// by compose_message() to be displayed in chat boxes for to_chat or runechat
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)

	if(speaker_is_signing) //Checks if speaker is using sign language
		deaf_message = compose_message(speaker, message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, spans, message_mods, TRUE)

		if(speaker != src)
			if(!radio_freq) //I'm about 90% sure there's a way to make this less cluttered
				deaf_type = MSG_VISUAL
		else
			deaf_type = MSG_AUDIBLE

		// Create map text prior to modifying message for goonchat, sign lang edition
		if (use_runechat && !is_blind())
			if (message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
				create_chat_message(speaker, null, message_mods[MODE_CUSTOM_SAY_EMOTE], spans, EMOTE_MESSAGE)
			else
				create_chat_message(speaker, message_language, raw_message, spans)

		if(is_blind())
			return FALSE

		message = deaf_message

		var/show_message_success = show_message(message, MSG_VISUAL, deaf_message, deaf_type, avoid_highlight)
		return understood && show_message_success

	if(speaker != src)
		if(!radio_freq) //These checks have to be separate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "[span_name("[speaker]")] [speaker.get_default_say_verb()] something but you cannot hear [speaker.p_them()]."
			deaf_type = MSG_VISUAL
	else
		deaf_message = span_notice("You can't hear yourself!")
		deaf_type = MSG_AUDIBLE // Since you should be able to hear yourself without looking

	// Create map text prior to modifying message for goonchat
	if (use_runechat && can_hear())
		if (message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
			create_chat_message(speaker, null, message_mods[MODE_CUSTOM_SAY_EMOTE], spans, EMOTE_MESSAGE)
		else
			create_chat_message(speaker, message_language, raw_message, spans)

	// Recompose message for AI hrefs, language incomprehension.
	message = compose_message(speaker, message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, spans, message_mods)
	var/show_message_success = show_message(message, MSG_AUDIBLE, deaf_message, deaf_type, avoid_highlight)
	return understood && show_message_success

/mob/living/send_speech(message_raw, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language = null, list/message_mods = list(), forced = null, tts_message, list/tts_filter)
	var/whisper_range = 0
	var/is_speaker_whispering = FALSE
	if(message_mods[WHISPER_MODE]) //If we're whispering
		// Needed for good hearing trait. The actual filtering for whispers happens at the /mob/living/Hear proc
		whisper_range = MESSAGE_RANGE - WHISPER_RANGE
		is_speaker_whispering = TRUE

	var/list/in_view = get_hearers_in_view(message_range + whisper_range, source)
	var/list/listening = get_hearers_in_range(message_range + whisper_range, source)

	// Pre-process listeners to account for line-of-sight
	for(var/atom/movable/listening_movable as anything in listening)
		if(!(listening_movable in in_view) && !HAS_TRAIT(listening_movable, TRAIT_XRAY_HEARING))
			listening.Remove(listening_movable)

	if(imaginary_group)
		listening |= imaginary_group

	if(client) //client is so that ghosts don't have to listen to mice
		for(var/mob/player_mob as anything in GLOB.player_list)
			if(QDELETED(player_mob)) //Some times nulls and deleteds stay in this list. This is a workaround to prevent ic chat breaking for everyone when they do.
				continue //Remove if underlying cause (likely byond issue) is fixed. See TG PR #49004.
			if(player_mob.stat != DEAD) //not dead, not important
				continue
			if(player_mob.z != z || get_dist(player_mob, src) > 7) //they're out of range of normal hearing
				if(is_speaker_whispering)
					if(!(get_chat_toggles(player_mob.client) & CHAT_GHOSTWHISPER)) //they're whispering and we have hearing whispers at any range off
						continue
				else if(!(get_chat_toggles(player_mob.client) & CHAT_GHOSTEARS)) //they're talking normally and we have hearing at any range off
					continue
			listening |= player_mob

	// this signal ignores whispers or language translations (only used by beetlejuice component)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_LIVING_SAY_SPECIAL, src, message_raw)

	var/list/listened = list()
	for(var/atom/movable/listening_movable as anything in listening)
		if(!listening_movable)
			stack_trace("somehow theres a null returned from get_hearers_in_view() in send_speech!")
			continue

		if(listening_movable.Hear(null, src, message_language, message_raw, null, null, null, spans, message_mods, message_range))
			listened += listening_movable

	//speech bubble
	var/list/speech_bubble_recipients = list()
	var/found_client = FALSE
	var/talk_icon_state = say_test(message_raw)
	for(var/mob/M in listening)
		if(M.client)
			if(!M.client.prefs.read_preference(/datum/preference/toggle/enable_runechat) || (SSlag_switch.measures[DISABLE_RUNECHAT] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES)))
				speech_bubble_recipients.Add(M.client)
			found_client = TRUE
	if(SStts.tts_enabled && voice && found_client && !message_mods[MODE_CUSTOM_SAY_ERASE_INPUT] && !HAS_TRAIT(src, TRAIT_SIGN_LANG) && !HAS_TRAIT(src, TRAIT_UNKNOWN))
		var/tts_message_to_use = tts_message
		if(!tts_message_to_use)
			tts_message_to_use = message_raw

		var/list/filter = list()
		var/list/special_filter = list()
		if(length(voice_filter) > 0)
			filter += voice_filter

		if(length(tts_filter) > 0)
			filter += tts_filter.Join(",")

		var/voice_to_use = get_tts_voice(filter, special_filter)
		if (!CONFIG_GET(flag/tts_no_whisper) || (CONFIG_GET(flag/tts_no_whisper) && !message_mods[WHISPER_MODE]))
			INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), src, html_decode(tts_message_to_use), message_language, voice_to_use, filter.Join(","), listened, message_range = message_range, pitch = pitch, special_filters = special_filter.Join("|"))

	var/image/say_popup = image('icons/mob/effects/talk.dmi', src, "[bubble_type][talk_icon_state]", FLY_LAYER)
	SET_PLANE_EXPLICIT(say_popup, ABOVE_GAME_PLANE, src)
	say_popup.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), say_popup, speech_bubble_recipients, 3 SECONDS)
	LAZYADD(update_on_z, say_popup)
	addtimer(CALLBACK(src, PROC_REF(clear_saypopup), say_popup), 3.5 SECONDS)

/mob/living/proc/get_tts_voice(list/filter, list/special_filter)
	. = voice
	var/obj/item/clothing/mask/mask = get_item_by_slot(ITEM_SLOT_MASK)
	if(!istype(mask) || mask.up)
		return
	if(mask.voice_override)
		. = mask.voice_override
	if(mask.voice_filter)
		filter += mask.voice_filter
	if(mask.use_radio_beeps_tts)
		special_filter |= TTS_FILTER_RADIO

/mob/living/silicon/get_tts_voice(list/filter, list/special_filter)
	. = ..()
	special_filter |= TTS_FILTER_SILICON

/mob/living/proc/clear_saypopup(image/say_popup)
	LAZYREMOVE(update_on_z, say_popup)

/mob/proc/binarycheck()
	return FALSE

/**
 * Treats the passed message with things that may modify speech (stuttering, slurring etc).
 *
 * message - The message to treat.
 * capitalize_message - Whether we run capitalize() on the message after we're done.
 *
 * Returns a list, which is a packet of information corresponding to the message that has been treated, which
 * contains the new message, as well as text-to-speech information.
 */
/mob/living/proc/treat_message(message, tts_message, tts_filter, capitalize_message = TRUE)
	RETURN_TYPE(/list)

	if(HAS_TRAIT(src, TRAIT_UNINTELLIGIBLE_SPEECH))
		message = unintelligize(message)

	tts_filter = list()
	var/list/data = list(message, tts_message, tts_filter, capitalize_message)
	SEND_SIGNAL(src, COMSIG_LIVING_TREAT_MESSAGE, data)
	message = data[TREAT_MESSAGE_ARG]
	tts_message = data[TREAT_TTS_MESSAGE_ARG]
	tts_filter = data[TREAT_TTS_FILTER_ARG]
	capitalize_message = data[TREAT_CAPITALIZE_MESSAGE]

	if(!tts_message)
		tts_message = message

	if(capitalize_message)
		message = capitalize(message)
		tts_message = capitalize(tts_message)

	///caps the length of individual letters to 3: ex: heeeeeeyy -> heeeyy
	/// prevents TTS from choking on unrealistic text while keeping emphasis
	var/static/regex/length_regex = regex(@"(.+)\1\1\1", "gi")
	while(length_regex.Find(tts_message))
		var/replacement = tts_message[length_regex.index]+tts_message[length_regex.index]+tts_message[length_regex.index]
		tts_message = replacetext(tts_message, length_regex.match, replacement, length_regex.index)

	// removes repeated consonants at the start of a word: ex: sss
	var/static/regex/word_start_regex = regex(@"\b([^aeiou\L])\1", "gi")
	while(word_start_regex.Find(tts_message))
		var/replacement = tts_message[word_start_regex.index]
		tts_message = replacetext(tts_message, word_start_regex.match, replacement, word_start_regex.index)

	return list("message" = message, "tts_message" = tts_message, "tts_filter" = tts_filter)

/mob/living/proc/radio(message, list/message_mods = list(), list/spans, language)
	var/obj/item/implant/radio/imp = locate() in src
	if(imp?.radio.is_on())
		if(message_mods[MODE_HEADSET])
			imp.radio.talk_into(src, message, , spans, language, message_mods)
			return ITALICS | REDUCE_RANGE
		if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT || (message_mods[RADIO_EXTENSION] in imp.radio.channels))
			imp.radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE
	switch(message_mods[RADIO_EXTENSION])
		if(MODE_R_HAND)
			for(var/obj/item/r_hand in get_held_items_for_side(RIGHT_HANDS, all = TRUE))
				if (r_hand)
					return r_hand.talk_into(src, message, , spans, language, message_mods)
				return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			for(var/obj/item/l_hand in get_held_items_for_side(LEFT_HANDS, all = TRUE))
				if (l_hand)
					return l_hand.talk_into(src, message, , spans, language, message_mods)
				return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for (var/obj/item/radio/intercom/I in view(MODE_RANGE_INTERCOM, null))
				I.talk_into(src, message, , spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return NONE

/mob/living/say_mod(input, list/message_mods = list())
	if(message_mods[WHISPER_MODE] == MODE_WHISPER)
		. = verb_whisper
	else if(message_mods[WHISPER_MODE] == MODE_WHISPER_CRIT && !HAS_TRAIT(src, TRAIT_SUCCUMB_OVERRIDE))
		. = "[verb_whisper] in [p_their()] last breath"
	else if(message_mods[MODE_SING])
		. = verb_sing
	// Any subtype of slurring in our status effects make us "slur"
	else if(locate(/datum/status_effect/speech/slurring) in status_effects)
		if (HAS_TRAIT(src, TRAIT_SIGN_LANG))
			. = "loosely signs"
		else
			. = "slurs"
	else if(has_status_effect(/datum/status_effect/speech/stutter))
		if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
			. = "shakily signs"
		else
			. = "stammers"
	else if(has_status_effect(/datum/status_effect/speech/stutter/derpspeech))
		if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
			. = "incoherently signs"
		else
			. = "gibbers"
	else
		. = ..()

/**
 * Living level whisper.
 *
 * Living mobs which whisper have their message only appear to people very close.
 *
 * message - the message to display
 * bubble_type - the type of speech bubble that shows up when they speak (currently does nothing)
 * spans - a list of spans to apply around the message
 * sanitize - whether we sanitize the message
 * language - typepath language to force them to speak / whisper in
 * ignore_spam - whether we ignore the spam filter
 * forced - string source of what forced this speech to happen, also bypasses spam filter / mutes if supplied
 * filterproof - whether we ignore the word filter
 */
/mob/living/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof)
	if(!message)
		return
	say("#[message]", bubble_type, spans, sanitize, language, ignore_spam, forced, filterproof)
