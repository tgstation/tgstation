

/datum/unit_test/reagent_id_typos

/datum/unit_test/reagent_id_typos/Run()
	build_chemical_reactions_lists()

	for(var/I in GLOB.chemical_reactions_list_reactant_index)
		for(var/V in GLOB.chemical_reactions_list_reactant_index[I])
			var/datum/chemical_reaction/R = V
			for(var/id in (R.required_reagents + R.required_catalysts))
				if(!GLOB.chemical_reagents_list[id])
					TEST_FAIL("Unknown chemical id \"[id]\" in recipe [R.type]")
