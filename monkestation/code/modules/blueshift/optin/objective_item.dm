/datum/objective_item
	/// The opt in level all owners of the item must meet for this to be eligible as an objective target.
	var/opt_in_level = OPT_IN_YES_TEMP

/// Returns TRUE if we have no owners, or all owners's effective opt in level is above [opt_in_level]. FALSE otherwise.
/datum/objective_item/proc/owner_opted_in()
	if (!length(item_owner))
		return TRUE
	for (var/mob/living/player as anything in GLOB.player_list)
		if ((player.mind?.assigned_role.title in item_owner) && player.stat != DEAD && !is_centcom_level(player.z)) // is an owner, copypasted from objective_items.dm owner_exists()
			if (player.mind.get_effective_opt_in_level() < opt_in_level)
				return FALSE
	return TRUE

/datum/objective_item/valid_objective_for(list/potential_thieves, require_owner)
	var/opt_in_disabled = CONFIG_GET(flag/disable_antag_opt_in_preferences)
	if (!opt_in_disabled && require_owner && !owner_opted_in())
		return FALSE

	return ..()
