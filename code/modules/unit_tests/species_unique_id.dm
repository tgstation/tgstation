/**
 * Every species should use a species ID unique to it and it alone. This test runs through every subtype of /datum/species, and checks for a species ID.
 * Every ID is written to a list, gathered_species_ids, and if a previously written ID is written again, this test will fail.
 */
/datum/unit_test/species_unique_id

/datum/unit_test/species_unique_id/Run()
	var/list/gathered_species_ids = list()
	for(var/datum/species/species as anything in subtypesof(/datum/species))
		var/species_id = initial(species.id)
		if(gathered_species_ids[species_id])
			TEST_FAIL("Duplicate species ID! [species_id] is not unique to a single species.")
		else
			gathered_species_ids[species_id] = TRUE
