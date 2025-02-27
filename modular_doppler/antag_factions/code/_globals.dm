GLOBAL_LIST_INIT(antag_factions, init_antag_factions())

/proc/init_antag_factions()
	var/list/antag_faction_list = list()
	for(var/datum/antag_faction/faction_path as anything in subtypesof(/datum/antag_faction))
		var/datum/antag_faction/the_faction = new faction_path()
		antag_faction_list += the_faction
	return antag_faction_list
