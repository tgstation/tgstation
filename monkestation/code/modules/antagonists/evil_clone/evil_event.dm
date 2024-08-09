/datum/round_event_control/cloner_corruption
	name = "Experimental Cloner Corruption"
	typepath = /datum/round_event/cloner_corruption
	max_occurrences = 1
	weight = 3
	category = EVENT_CATEGORY_ENTITIES //Kinda, evil clones ARE entities.
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMBAT) // Clones will likely start a fight, but will usually not cause wanton destruction.
	earliest_start = 35 MINUTES //This requires an experimental cloner to be made, so should wait until later to fire when there's better chance one has been set up.

/datum/round_event/cloner_corruption/start()
	var/found = FALSE
	for(var/obj/machinery/clonepod/experimental/cloner in GLOB.machines)
		if(!cloner.locked)
			cloner.evil_objective = pick(subtypesof(/datum/objective/evil_clone))
			cloner.RefreshParts()
			found = TRUE
	if(!found) // Refund if no experimental cloners are found.
		control.occurrences--
