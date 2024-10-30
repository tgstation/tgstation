///Checks the gene combination recipes for validity.
///Tests:
///Check that recipe contains exactly two genes as ingredients
///Checks that both ingredients are valid types
/datum/unit_test/genetics_recipes

/datum/unit_test/genetics_recipes/Run()
	for(var/datum/generecipe/recipe as anything in subtypesof(/datum/generecipe))
		var/list/ingredients = splittext(initial(recipe.required), "; ")
		if(length(ingredients) != 2)
			TEST_FAIL("[recipe] does not have exactly two ingredients!")
			continue
		if(!text2path(ingredients[1]))
			TEST_FAIL("[recipe]: [ingredients[1]] is not a valid gene type!")
		if(!text2path(ingredients[2]))
			TEST_FAIL("[recipe]: [ingredients[2]] is not a valid gene type!")
