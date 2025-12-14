/// Sends a fake chat message to the hallucinator.
/datum/hallucination/chat
	random_hallucination_weight = 100
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// If TRUE, we force the message to be hallucinated from common radio. Only set in New()
	var/force_radio
	/// If set, a message we force to be picked, rather than an auto-generated message. Only set in New()
	var/specific_message

/datum/hallucination/chat/New(mob/living/hallucinator, force_radio = FALSE, specific_message)
	src.force_radio = force_radio
	src.specific_message = specific_message
	return ..()

/// When passed a mob, returns a list of languages that mob could theoretically speak IF a blank slate.
/datum/hallucination/chat/proc/get_hallucinating_spoken_languages(atom/movable/who)
	var/override_typepath
	if(iscarbon(who))
		var/mob/living/carbon/human_who = who
		override_typepath = human_who.dna?.species?.species_language_holder

	var/datum/language_holder/what_they_speak = GLOB.prototype_language_holders[override_typepath || who.initial_language_holder]
	return what_they_speak?.spoken_languages?.Copy() || list()

/datum/hallucination/chat/start()
	var/mob/living/carbon/human/speaker
	var/list/datum/language/understood_languages = hallucinator.get_language_holder().understood_languages
	var/understood_language

	if(!force_radio)
		var/list/valid_humans = list()
		var/list/valid_corpses = list()
		for(var/mob/living/carbon/nearby_human in view(hallucinator))
			if(nearby_human == hallucinator)
				continue
			if(nearby_human.stat == DEAD)
				valid_corpses += nearby_human
				continue
			valid_humans += nearby_human

		// pick a nearby human which can speak a language the hallucinator understands
		for(var/mob/living/carbon/nearby_human in shuffle(valid_humans))
			var/list/shared_languages = get_hallucinating_spoken_languages(nearby_human) & understood_languages
			if(!length(shared_languages)) // future idea : have people hallucinating off their minds ignore this check
				continue
			speaker = nearby_human
			understood_language = pick(shared_languages)
			break

		// corpses disrespect language because they're... dead
		if(isnull(speaker) && length(valid_corpses))
			speaker = pick(valid_corpses)

	// Get person to affect if radio hallucination
	var/is_radio = force_radio || isnull(speaker)
	if(is_radio)
		for(var/datum/mind/crew_mind in shuffle(get_crewmember_minds()))
			if(crew_mind == hallucinator.mind)
				continue
			var/list/shared_languages = get_hallucinating_spoken_languages(crew_mind.current) & understood_languages
			if(!length(shared_languages))
				continue
			speaker = crew_mind.current
			understood_language = pick(shared_languages)
			break

	if(isnull(speaker))
		return

	// Time to generate a message.
	// Spans of our message
	var/spans = list(speaker.speech_span)

	// Contents of our message
	var/chosen = specific_message
	// If we didn't have a preset one, let's make one up.
	if(!chosen)
		if(is_radio)
			chosen = pick(list("Help!",
				"Help [pick_list_replacements(HALLUCINATION_FILE, "location")][prob(50)?"!":"!!"]",
				"[pick_list_replacements(HALLUCINATION_FILE, "people")] is [pick_list_replacements(HALLUCINATION_FILE, "accusations")]!",
				"[pick_list_replacements(HALLUCINATION_FILE, "people")] has [pick_list_replacements(HALLUCINATION_FILE, "contraband")]!",
				"[pick_list_replacements(HALLUCINATION_FILE, "threat")] in [pick_list_replacements(HALLUCINATION_FILE, "location")][prob(50)?"!":"!!"]",
				"[pick("Where's [first_name(hallucinator.name)]?", "Set [first_name(hallucinator.name)] to arrest!")]",
				"[pick("C","Ai, c","Someone c","Rec")]all the shuttle!",
				"AI [pick("rogue", "is dead")]!!",
				"Borgs rogue!",
			))
		else
			chosen = pick(list("[pick_list_replacements(HALLUCINATION_FILE, "suspicion")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "conversation")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "greetings")][first_name(hallucinator.name)]!",
				"[pick_list_replacements(HALLUCINATION_FILE, "getout")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "weird")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "didyouhearthat")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "doubt")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "aggressive")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "help")]!!",
				"[pick_list_replacements(HALLUCINATION_FILE, "escape")]",
				"I'm infected, [pick_list_replacements(HALLUCINATION_FILE, "infection_advice")]!",
			))

		chosen = capitalize(chosen)

	chosen = replacetext(chosen, "%TARGETNAME%", first_name(hallucinator.name))

	// Log the message
	feedback_details += "Type: [is_radio ? "Radio" : "Talk"], Source: [speaker.real_name], Message: [chosen]"

	var/plus_runechat = hallucinator.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat)

	// Display the message
	if(!is_radio && !plus_runechat)
		var/image/speech_overlay = image('icons/mob/effects/talk.dmi', speaker, "default0", layer = ABOVE_MOB_LAYER)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), speech_overlay, list(hallucinator.client), 30)

	if(plus_runechat)
		hallucinator.create_chat_message(speaker, understood_language, chosen, spans)

	// And actually show them the message, for real.
	var/message = hallucinator.compose_message(speaker, understood_language, chosen, is_radio ? "[FREQ_COMMON]" : null, is_radio ? RADIO_CHANNEL_COMMON : null, is_radio ? RADIO_COLOR_COMMON : null, spans, visible_name = TRUE)
	to_chat(hallucinator, message)

	// Then clean up.
	qdel(src)
	return TRUE
