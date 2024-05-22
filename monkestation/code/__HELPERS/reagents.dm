GLOBAL_LIST_INIT(weighted_random_reagents, init_weighted_random_reagents())

/proc/init_weighted_random_reagents()
	var/regex/bad_desc_regex = new(@"(?:coder|adminhelp|bugged)", "i")
	. = list()
	for(var/datum/reagent/reagent_path as anything in subtypesof(/datum/reagent))
		if(ispath(reagent_path, /datum/reagent/consumable) && !reagent_path::bypass_restriction)
			continue
		if(reagent_path::restricted || !length(reagent_path::name) || !reagent_path::random_weight)
			continue
		if(reagent_path::description && findtext(reagent_path::description, bad_desc_regex))
			continue
		.[reagent_path] = reagent_path::random_weight
