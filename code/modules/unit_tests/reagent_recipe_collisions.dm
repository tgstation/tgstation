/datum/unit_test/reagent_recipe_collisions

/datum/unit_test/reagent_recipe_collisions/Run()
	build_chemical_reactions_lists()

	// Exclude soup from this test, they all have the same "reagents" just about
	var/list/reactions_sans_soup = GLOB.chemical_reactions_list - subtypesof(/datum/chemical_reaction/food/soup)

	for(var/reaction_type_a as anything in reactions_sans_soup)
		for(var/reaction_type_b as anything in reactions_sans_soup)
			if(reaction_type_a == reaction_type_b)
				continue
			var/datum/chemical_reaction/reaction_a = reactions_sans_soup[reaction_type_a]
			var/datum/chemical_reaction/reaction_b = reactions_sans_soup[reaction_type_b]
			if(chem_recipes_do_conflict(reaction_a, reaction_b))
				TEST_FAIL("Chemical recipe conflict between [reaction_type_a] and [reaction_type_b]")

/*
Melbert todo
/datum/unit_test/soup_recipe_collisions

/datum/unit_test/soup_recipe_collisions/Run()
	build_chemical_reactions_lists()

	var/list/datum/chemical_reaction/soup/reactions_only_soup = list()
	for(var/reaction_type in GLOB.chemical_reactions_list)
		if(ispath(reaction_type, /datum/chemical_reaction/food/soup))
			reactions_only_soup += GLOB.chemical_reactions_list[reaction_type]

	for(var/datum/chemical_reaction/soup/soup_reaction_a as anything in reactions_only_soup)
		for(var/datum/chemical_reaction/soup/soup_reaction_b as anything in reactions_only_soup)
*/
