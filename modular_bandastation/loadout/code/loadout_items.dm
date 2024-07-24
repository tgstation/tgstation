/datum/loadout_item
	var/donator_level = 0

/datum/loadout_item/get_item_information()
	. = ..()
	if(donator_level)
		. += "Tier [donator_level]"

// Removes item from the preferences menu, period. Use it only to remove stuff for ALL players.
/datum/loadout_item/proc/is_available()
	return TRUE
