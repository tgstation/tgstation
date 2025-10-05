/datum/unit_test/reagent_recipe_collisions

/datum/unit_test/reagent_recipe_collisions/Run()
	build_chemical_reactions_lists()

	// Exclude soup from this test, they all have the same "reagents" just about
	var/list/reactions_sans_soup = GLOB.chemical_reactions_list - subtypesof(/datum/chemical_reaction/food/soup)

	for(var/reaction_type_a in reactions_sans_soup)
		for(var/reaction_type_b in reactions_sans_soup)
			if(reaction_type_a == reaction_type_b)
				continue
			var/datum/chemical_reaction/reaction_a = reactions_sans_soup[reaction_type_a]
			var/datum/chemical_reaction/reaction_b = reactions_sans_soup[reaction_type_b]
			if(chem_recipes_do_conflict(reaction_a, reaction_b))
				TEST_FAIL("Chemical recipe conflict between [reaction_type_a] and [reaction_type_b]")
