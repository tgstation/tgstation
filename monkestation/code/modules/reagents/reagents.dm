/datum/reagent
	///do we need to start checking processes of chemicals?
	var/requires_process = FALSE

///called whenever a reagent container processes its internal chemicals
/datum/reagent/proc/on_container_process(obj/item/reagent_containers/host)
	return
