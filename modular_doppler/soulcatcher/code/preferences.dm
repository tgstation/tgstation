/datum/preference/toggle/soulcatcher_join_action
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "soulcatcher_join_action"
	default_value = TRUE

/datum/preference/toggle/soulcatcher_join_action/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if(!istype(ghost))
		return FALSE

	var/datum/action/innate/join_soulcatcher/join_action = locate(/datum/action/innate/join_soulcatcher) in ghost.actions
	if((!join_action && !value) || (join_action && value))
		return TRUE

	if(join_action && !value)
		join_action.Remove(ghost)
		return TRUE

	var/datum/action/innate/join_soulcatcher/new_join_action = new(ghost)
	new_join_action.Grant(ghost)
	return TRUE
