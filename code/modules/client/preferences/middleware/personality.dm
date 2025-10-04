/datum/preference_middleware/personality
	action_delegations = list(
		"handle_personality" = PROC_REF(handle_personality),
		"clear_personalities" = PROC_REF(clear_personalities),
	)

/datum/preference_middleware/personality/proc/handle_personality(list/params, mob/user)
	var/datum/personality/personality_type = text2path(params["personality_type"])
	if(!ispath(personality_type, /datum/personality))
		return FALSE

	var/personality_key = initial(personality_type.savefile_key)
	var/list/personalities = preferences.read_preference(/datum/preference/personality)
	if(personality_key in personalities)
		LAZYREMOVE(personalities, personality_key)
	else
		if(LAZYLEN(personalities) >= CONFIG_GET(number/max_personalities))
			return TRUE
		if(SSpersonalities.is_incompatible(personalities, personality_type))
			return TRUE
		LAZYADD(personalities, personality_key)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/personality], personalities)
	return TRUE

/datum/preference_middleware/personality/proc/clear_personalities(list/params, mob/user)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/personality], null)
	return TRUE

/datum/preference_middleware/personality/get_constant_data()
	var/list/data = list()

	data["personalities"] = list()
	for(var/datum/personality/personality_type as anything in SSpersonalities.personalities_by_type)
		var/datum/personality/personality = SSpersonalities.personalities_by_type[personality_type]
		data["personalities"] += list(list(
			"description" = personality.desc,
			"pos_gameplay_description" = personality.pos_gameplay_desc,
			"neg_gameplay_description" = personality.neg_gameplay_desc,
			"neut_gameplay_description" = personality.neut_gameplay_desc,
			"name" = personality.name,
			"path" = personality_type,
			"groups" = personality.groups,
		))

	data["personality_incompatibilities"] = SSpersonalities.incompatibilities_by_group

	return data

/datum/preference_middleware/personality/get_ui_static_data(mob/user)
	var/list/data = list()

	var/max = CONFIG_GET(number/max_personalities)
	data["max_personalities"] = max >= length(SSpersonalities.personalities_by_type) ? -1 : max
	data["mood_enabled"] = !CONFIG_GET(flag/disable_human_mood)

	return data

/datum/preference_middleware/personality/get_ui_data(mob/user)
	var/list/data = list()

	data["selected_personalities"] = list()
	for(var/personality_key in preferences.read_preference(/datum/preference/personality))
		var/datum/personality/personality = SSpersonalities.personalities_by_key[personality_key]
		data["selected_personalities"] += personality.type

	return data
