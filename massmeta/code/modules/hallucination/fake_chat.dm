/datum/hallucination/chat/start()
	var/mob/living/carbon/human/speaker
	var/datum/language/understood_language = hallucinator.get_random_understood_language()
	for(var/mob/living/carbon/nearby_human in view(hallucinator))
		if(nearby_human == hallucinator)
			continue

		if(!speaker)
			speaker = nearby_human
		else if(get_dist(hallucinator, nearby_human) < get_dist(hallucinator, speaker))
			speaker = nearby_human

	// Get person to affect if radio hallucination
	var/is_radio = !speaker || force_radio
	if(is_radio)
		var/list/humans = list()

		for(var/datum/mind/crew_mind in get_crewmember_minds())
			if(crew_mind.current)
				humans += crew_mind.current
		if(humans.len)
			speaker = pick(humans)

	if(!speaker)
		return

	// Time to generate a message.
	// Spans of our message
	var/spans = list(speaker.speech_span)

	// Contents of our message
	var/chosen = specific_message
	// If we didn't have a preset one, let's make one up.
	if(!chosen)
		if(is_radio)
			chosen = pick(list("Помогите!",
				"[pick_list_replacements(HALLUCINATION_FILE, "people")] [pick_list_replacements(HALLUCINATION_FILE, "accusations")]!",
				"[pick_list_replacements(HALLUCINATION_FILE, "threat")] в [pick_list_replacements(HALLUCINATION_FILE, "location")][prob(50)?"!":"!!"]",
				"[pick("Где [hallucinator.first_name()]?", "Поставьте [hallucinator.first_name()] на арест!")]",
				"[pick("Выз","ИИ, з","Отз")]овите шаттл!",
				"ИИ [pick("малф", "мертв")]!!",
				"Борги плохие!",
			))
		else
			chosen = pick(list("[pick_list_replacements(HALLUCINATION_FILE, "suspicion")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "conversation")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "greetings")][hallucinator.first_name()]!",
				"[pick_list_replacements(HALLUCINATION_FILE, "getout")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "weird")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "didyouhearthat")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "doubt")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "aggressive")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "help")]!!",
				"[pick_list_replacements(HALLUCINATION_FILE, "escape")]",
				"У меня болезнь, [pick_list_replacements(HALLUCINATION_FILE, "infection_advice")]!",
			))

		chosen = capitalize(chosen)

	chosen = replacetext(chosen, "%TARGETNAME%", hallucinator.first_name())

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
	var/message = hallucinator.compose_message(speaker, understood_language, chosen, is_radio ? "[FREQ_COMMON]" : null, spans, visible_name = TRUE)
	to_chat(hallucinator, message)

	// Then clean up.
	qdel(src)
	return TRUE
