/// During map rotation, this will help determine the chosen map.
/datum/preference/choiced/preferred_map
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "preferred_map"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/preferred_map/init_possible_values()
	var/list/maps = list()
	maps += ""

	for (var/map in config.maplist)
		var/datum/map_config/map_config = config.maplist[map]
		if (!map_config.votable)
			continue

		maps += map

	return maps

/datum/preference/choiced/preferred_map/create_default_value()
	return ""

/datum/preference/choiced/preferred_map/compile_constant_data()
	var/list/data = ..()

	var/display_names = list()

	if (config.defaultmap)
		display_names[""] = "Default ([config.defaultmap.map_name])"
	else
		display_names[""] = "Default"

	for (var/choice in get_choices())
		if (choice == "")
			continue

		var/datum/map_config/map_config = config.maplist[choice]

		var/map_name = map_config.map_name
		if (map_config.voteweight <= 0)
			map_name += " (disabled)"
		display_names[choice] = map_name

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = display_names

	return data

/datum/preference/choiced/preferred_map/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return CONFIG_GET(flag/preference_map_voting)
