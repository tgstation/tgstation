/datum/preference_middleware/personality
	action_delegations = list(
		"handle_personality" = PROC_REF(handle_personality),
		"clear_personalities" = PROC_REF(clear_personalities),
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
			return TRUE
		if(GLOB.personality_controller.is_incompatible(personalities, personality_type))
			return TRUE
		LAZYADD(personalities, personality_type)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/personality], personalities)
	return TRUE

/datum/preference_middleware/personality/proc/clear_personalities(list/params, mob/user)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/personality], null)
	return TRUE

/datum/preference_middleware/personality/get_constant_data()
	var/list/data = list()

	data["personalities"] = list()
	for(var/datum/personality/personality_type as anything in GLOB.personality_controller.personalities)
		var/datum/personality/personality = GLOB.personality_controller.personalities[personality_type]
		data["personalities"] += list(list(
			"description" = personality.desc,
			"pos_gameplay_description" = personality.pos_gameplay_desc,
			"neg_gameplay_description" = personality.neg_gameplay_desc,
			"neut_gameplay_description" = personality.neut_gameplay_desc,
			"name" = personality.name,
			"path" = personality_type,
		))

	data["personality_incompatibilities"] = GLOB.personality_controller.incompatibilities

	return data

/datum/preference_middleware/personality/get_ui_static_data(mob/user)
	var/list/data = list()

	data["max_personalities"] = CONFIG_GET(number/max_personalities)

	return data

/datum/preference_middleware/personality/get_ui_data(mob/user)
	var/list/data = list()

	data["selected_personalities"] = preferences.read_preference(/datum/preference/personality)

	return data
