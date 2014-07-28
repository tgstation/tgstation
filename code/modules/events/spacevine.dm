/var/global/spacevines_spawned = 0

/datum/event/spacevine

/datum/event/spacevine/start()
	//biomass is basically just a resprited version of space vines
	if(prob(50))
		spacevine_infestation()
	else
		biomass_infestation()
	spacevines_spawned = 1
