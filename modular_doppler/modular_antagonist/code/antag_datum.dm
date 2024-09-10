/datum/antagonist
	/// the list of recipes that an antag will learn/unlearn on gain/loss
	var/list/antag_recipes = list()

/datum/antagonist/on_gain()
	. = ..()
	for(var/recipe_datum in antag_recipes)
		owner.teach_crafting_recipe(recipe_datum)

/datum/antagonist/on_removal()
	. = ..()
	for(var/recipe_datum in antag_recipes)
		owner.unteach_crafting_recipe(recipe_datum)
