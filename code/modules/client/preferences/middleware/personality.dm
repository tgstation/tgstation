/datum/preference_middleware/personality
	action_delegations = list(
		"handle_personality" = PROC_REF(handle_personality),
	)

/datum/preference_middleware/personality/proc/handle_personality(list/params, mob/user)
	var/personality_type = text2path(params["personality_type"])
	if(!ispath(personality_type, /datum/personality))
		return FALSE

	var/list/personalities = preferences.read_preference(/datum/preference/personality)
	if(personality_type in personalities)
		LAZYREMOVE(personalities, personality_type)
	else
		if(LAZYLEN(personalities) >= CONFIG_GET(number/max_personalities))
			LAZYREMOVE(personalities, personalities[1])
		LAZYADD(personalities, personality_type)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/personality], personalities)
	return TRUE

/datum/preference_middleware/personality/get_constant_data()
	var/list/data = list()

	data["personalities"] = list()
	for(var/datum/personality/personality_type as anything in subtypesof(/datum/personality))
		data["personalities"] += list(list(
			"description" = initial(personality_type.desc),
			"pos_gameplay_description" = initial(personality_type.pos_gameplay_desc),
			"neg_gameplay_description" = initial(personality_type.neg_gameplay_desc),
			"neut_gameplay_description" = initial(personality_type.neut_gameplay_desc),
			"name" = initial(personality_type.name),
			"path" = personality_type,
		))

	return data

/datum/preference_middleware/personality/get_ui_static_data(mob/user)
	var/list/data = list()

	data["max_personalities"] = CONFIG_GET(number/max_personalities)

	return data

/datum/preference_middleware/personality/get_ui_data(mob/user)
	var/list/data = list()

	data["selected_personalities"] = preferences.read_preference(/datum/preference/personality)

	return data
