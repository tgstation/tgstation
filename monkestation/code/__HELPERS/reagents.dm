///Returns a random reagent object minus ethanol reagents
/proc/get_random_reagent_id_unrestricted_non_ethanol()
	var/static/list/random_reagents
	if(!random_reagents)
		random_reagents = list()
		for(var/datum/reagent/reagent_path as anything in subtypesof(/datum/reagent))
			if(istype(reagent_path, /datum/reagent/consumable) && !initial(reagent_path.bypass_restriction))
				continue
			if(initial(reagent_path.restricted))
				continue
			random_reagents += reagent_path
	var/picked_reagent = pick(random_reagents)
	return picked_reagent
