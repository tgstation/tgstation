/mob/living/proc/flock_talk(message, list/spans = list(), list/message_mods = list(), system = FALSE)
	log_sayverb_talk(message, message_mods, tag="flock comms")

	spans |= SPAN_FLOCK
	message_mods[SAY_MOD_VERB] = "transmits"

	var/namepart = name
	if(isflock(src))
		var/mob/living/basic/flock/flockmob = src
		namepart = "[flockmob.get_lord_name()].[name]"
	var/messagepart = ""
	if(system) // system announcements for flock agents
		messagepart = "!![uppertext(message)]!!"
	else
		messagepart = generate_messagepart(
		message,
		spans,
		message_mods,
	)
	// TODO: some way for flock talk to leak/be listened into?
	// var/translated_message = hearing_mob.translate_language(src, /datum/language/flock, message, spans, message_mods)

	var/final_message = "\[FLK::[span_name("[namepart]")] <span class='message'>[messagepart]</span>\]"
	for(var/mob/hearing_mob in GLOB.player_list)
		if(isflock(hearing_mob))
			to_chat(
				hearing_mob,
				system ? span_flocklord(final_message) : span_flock(final_message),
				type = MESSAGE_TYPE_RADIO,
				avoid_highlighting = (src == hearing_mob)
			)

		if(HAS_TRAIT(hearing_mob, TRAIT_FLOCKISH_EAVESDROPPER))
			var/raw_translated_message = hearing_mob.translate_language(src, /datum/language/flock, message, spans, message_mods)
			var/translated_messagepart = generate_messagepart(
				raw_translated_message,
				spans,
				message_mods,
			)
			var/translated_message = system ? \
				"\[???\] [span_name("A cold synthetic choir")] <span class='message'>chants, \"[uppertext(raw_translated_message)]\"</span>" : \
				"\[???\] [span_name("[namepart]")] <span class='message'>[translated_messagepart]</span>"
			to_chat(
				hearing_mob,
				system ? span_flocklord(translated_message) : span_flock(translated_message),
				type = MESSAGE_TYPE_RADIO,
				avoid_highlighting = (src == hearing_mob)
			)

		if(isobserver(hearing_mob))
			var/follow_link = FOLLOW_LINK(hearing_mob, src)
			to_chat(
				hearing_mob,
				system ? span_flocklord("[follow_link] [final_message]") : span_flock("[follow_link] [final_message]"),
				type = MESSAGE_TYPE_RADIO,
				avoid_highlighting = (src == hearing_mob)
			)


/datum/saymode/flock
	key = MODE_KEY_FLOCK
	mode = MODE_FLOCK
	allows_custom_say_emotes = TRUE

/datum/saymode/flock/can_be_used_by(mob/living/user)
	if(!isflock(user))
		return FALSE
	return TRUE

/datum/saymode/flock/handle_message(
	mob/living/user,
	message,
	list/spans = list(),
	datum/language/language,
	list/message_mods = list()
)
	user.flock_talk(message, spans, message_mods)
	return SAYMODE_MESSAGE_HANDLED
