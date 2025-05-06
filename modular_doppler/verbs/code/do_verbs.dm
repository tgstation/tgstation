/mob/verb/do_verb(message as message)
	set name = "Do"
	set category = "IC"
	set instant = TRUE

	if(GLOB.say_disabled)
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(message)
		QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_VERB_REF(/mob/living, do_actual_verb), message), SSspeech_controller)

/mob/living/verb/do_actual_verb(message as message)
	if (!message || !doverb_checks(message))
		return

	if (!try_speak(message)) // ensure we pass the vibe check (filters, etc)
		return

	var/name_stub = " (<b>[usr]</b>)"
	message = usr.apply_message_emphasis(message)
	message = trim(copytext_char(message, 1, (MAX_MESSAGE_LEN - length(name_stub))))
	var/message_with_name = message + name_stub

	usr.log_message(message, LOG_EMOTE)

	var/list/viewers = get_hearers_in_view(DEFAULT_MESSAGE_RANGE, usr)

	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = usr
		viewers = get_hearers_in_view(DEFAULT_MESSAGE_RANGE, ai.eyeobj)

	var/obj/effect/overlay/holo_pad_hologram/hologram = GLOB.hologram_impersonators[usr]
	if(hologram)
		viewers |= get_hearers_in_view(1, hologram)

	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai.client && !(ai in viewers) && (ai.eyeobj in viewers))
			viewers += ai

	for(var/mob/ghost as anything in GLOB.dead_mob_list)
		if((ghost.client?.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(ghost in viewers))
			ghost.show_message(span_emote(message_with_name))

	for(var/mob/receiver in viewers)
		receiver.show_message(span_emote(message_with_name), alt_msg = span_emote(message_with_name))
		if (receiver.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
			create_chat_message(usr, null, message, null, EMOTE_MESSAGE)
