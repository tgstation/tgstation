/datum/hallucination/telepathy
	random_hallucination_weight = 4
	hallucination_tier = HALLUCINATION_TIER_COMMON

/datum/hallucination/telepathy/start()
	var/datum/action/cooldown/spell/list_target/telepathy/mimiced_type = pick(typesof(/datum/action/cooldown/spell/list_target/telepathy))
	hallucinator.balloon_alert(hallucinator, "you hear a voice")
	to_chat(hallucinator, "\
		<span class='[initial(mimiced_type.bold_telepathy_span)]'>You hear a voice in your head...</span>\
		<span class='[initial(mimiced_type.telepathy_span)]'> [get_telepath_message()]</span>\
	")
	return TRUE

/datum/hallucination/telepathy/proc/get_telepath_message()
	if(prob(0.001))
		return "horse"

	var/memo = pick(
		pick_list_replacements(HALLUCINATION_FILE, "advice"),
		pick_list_replacements(HALLUCINATION_FILE, "aggressive"),
		pick_list_replacements(HALLUCINATION_FILE, "conversation"),
		pick_list_replacements(HALLUCINATION_FILE, "didyouhearthat"),
		pick_list_replacements(HALLUCINATION_FILE, "doubt"),
		pick_list_replacements(HALLUCINATION_FILE, "escape"),
		pick_list_replacements(HALLUCINATION_FILE, "getout"),
		pick_list_replacements(HALLUCINATION_FILE, "greetings"),
		pick_list_replacements(HALLUCINATION_FILE, "suspicion"),
	)
	var/names = pick(
		first_name(hallucinator.name),
		last_name(hallucinator.name),
		first_name(hallucinator.real_name),
		last_name(hallucinator.real_name),
	)

	return replacetext(memo, "%TARGETNAME%", names)
