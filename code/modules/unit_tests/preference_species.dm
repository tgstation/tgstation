
/**
 * Checks that all enabled roundstart species
 * selectable within the preferences menu
 * have their info / page setup correctly.
 */
/datum/unit_test/preference_species

/datum/unit_test/preference_species/Run()

	// Go though all selectable species to see if they have their page setup correctly.
	for(var/species_id in get_selectable_species())

		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type()

		// Check the species decription.
		// If it's not overridden, a stack trace will be thrown (and fail the test).
		// If it's null, it was improperly overriden. Fail the test.
		var/species_desc = species.get_species_description()
		if(isnull(species_desc))
			TEST_FAIL("Species [species] ([species_type]) is selectable, but did not properly implement get_species_description().")

		qdel(species)
