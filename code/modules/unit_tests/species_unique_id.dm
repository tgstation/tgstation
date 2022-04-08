/datum/unit_test/species_unique_id

/datum/unit_test/species_unique_id/Run()
	var/list/gathered_species_ids = list()
	for(var/datum/species/species as anything in subtypesof(/datum/species))
		var/species_id = initial(species.id)
		if(!(gathered_species_ids.Find(species_id)))
			gathered_species_ids += species_id
		else
			Fail("Duplicate species ID! [species_id] is not unique to a single species.")
