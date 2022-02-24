
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

		var/species_desc = species.get_species_description()
		if(isnull(species_desc))
			Fail("Species [species] ([species_type]) is selectable, but did not implement get_species_description().")

		var/species_lore = species.get_species_lore()
		if(isnull(species_lore))
			Fail("Species [species] ([species_type]) is selectable, but did not implement get_species_lore().")
		else if(!islist(species_lore))
			Fail("Species [species] ([species_type]) is selectable, but implemented get_species_lore() incorrectly (Did not return a list).")

		qdel(species)
