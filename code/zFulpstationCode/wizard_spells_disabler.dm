/datum/spellbook_entry/summon/ghosts/IsAvailible()
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(istype(SSticker.mode, /datum/game_mode/dynamic)) // Disable events on dynamic
		return FALSE
	return !CONFIG_GET(flag/no_summon_ghosts)

/datum/config_entry/flag/no_summon_ghosts
