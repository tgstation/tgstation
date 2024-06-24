/datum/reagent
	///do we need to start checking processes of chemicals?
	var/requires_process = FALSE

///called whenever a reagent container processes its internal chemicals
/datum/reagent/proc/reagent_fire(obj/item/reagent_containers/host)
	return
