GLOBAL_LIST_INIT(ghost_lighting_options, list(
	"Fullbright" = LIGHTING_CUTOFF_FULLBRIGHT,
	"Night Vision" = LIGHTING_CUTOFF_HIGH,
	"Darker" = LIGHTING_CUTOFF_MEDIUM,
	"Normal" = LIGHTING_CUTOFF_VISIBLE,
))

/// How bright a ghost's lighting plane is
/datum/preference/choiced/ghost_lighting
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ghost_lighting"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/ghost_lighting/create_default_value()
	return "Darker"

/datum/preference/choiced/ghost_lighting/init_possible_values()
	var/list/values = list()
	for(var/option_name in GLOB.ghost_lighting_options)
		values += option_name
	return values

/datum/preference/choiced/ghost_lighting/apply_to_client(client/client, value)
	var/mob/current_mob = client?.mob
	if(!isobserver(current_mob))
		return
	current_mob.lighting_cutoff = current_mob.default_lighting_cutoff()
	current_mob.update_sight()
