
/*
/datum/holiday/april_fools/shouldCelebrate(dd, mm, yy)
	return 1 // Testing testing
*/

/datum/holiday/april_fools/getStationPrefix()
	return pick("Friendship","Magic","My Little","Pony")

/datum/holiday/april_fools/celebrate()
	// Here we go...
	spawn(40)
		// Let the species config load, and then OVERRIDE IT MUHAHAHAHAHA!!!
		if(!config.mutant_races)
			config.mutant_races = TRUE
		roundstart_species["pony"] = /datum/species/pony
