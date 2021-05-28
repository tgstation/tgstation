GLOBAL_DATUM_INIT(global_roster, /datum/roster, new)

/datum/roster
	var/list/contestent_ckeys

	var/list/all_contestants

	var/list/active_contestants

	var/list/active_teams


/datum/roster/proc/load_contestants_from_file(filepath)
	if(!filepath)
		CRASH("No filepath!")

	contestant_ckeys = strings(filepath, "contestants", directory = "strings/rosters")

	qdel(all_contestants) // ?

	all_contestants = list()

	for(var/iter_ckey in contestant_ckeys)
