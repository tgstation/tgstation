/datum/loadout_item
	var/donator_level = BASIC_DONATOR_LEVEL
	var/cost = 1

/datum/loadout_item/to_ui_data()
	. = ..()
	.["cost"] = cost
	.["tier"] = donator_level

// Removes item from the preferences menu, period. Use it only to remove stuff for ALL players.
/datum/loadout_item/proc/is_available()
	return TRUE
