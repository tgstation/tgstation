/// Ratwood slapcraft recipe (code/controllers/subsystem/rogue/cooking/cooking_recipes.dm, /datum/food_recipe): start with the
/// base item on a table and add the ingredients in order, items or reagents from a container; the result appears, or the base
/// becomes ready to be cooked (needs_cooking) or deep fried (deep_fry) into it. Most recipes are ported (survival/ported/food.dm);
/// the step-by-step dishes Ratwood wrote by hand in attackby() (pies, nitzels, handpies) are recipes too (survival/kneading.dm).
/datum/rogue_food_recipe
	var/name = "Generic Recipe"
	/// What the recipe starts with (exact type).
	var/base_item
	/// In order: item types, lists of item types any of which does, and reagent = amount.
	var/list/ingredients = list()
	var/result_type
	/// The finished dish still has to be cooked (pan, fire or oven).
	var/needs_cooking = FALSE
	/// The finished dish is deep fried in a pot of tallow instead (Ratwood deep_fried_type of the coated nitzels).
	var/deep_fry = FALSE
	/// Time of each step before the cook's skill.
	var/time_per_step = 2 SECONDS
	/// Share of the cook's intelligence each step teaches (Ratwood experience_per_step).
	var/experience_per_step = 0.5
	/// Item steps take exactly the listed types, not their subtypes (Ratwood pies: poisoned berries are no berries).
	var/exact_types = FALSE
	/// Ratwood step sprites: the icon state of the base after each step, instead of the added ingredient drawn small...
	var/list/step_icon_states
	/// ...or an overlay after each step from overlay_icon (Ratwood pie fillings and roofs).
	var/list/step_overlays
	var/overlay_icon
	/// Names of the base once begun and once everything is in (Ratwood "unfinished meat pie", "uncooked meat pie").
	var/started_name
	var/ready_name
	/// What the dish ready to cook will smell of once cooked (Ratwood pies set cooked_smell when roofed).
	var/ready_smell
	/// What a cook who may not prepare it is told (can_prepare()).
	var/refusal = "I don't know how to prepare this."

/// Whether this cook knows the dish (Ratwood's spider pie wants a dark elf or an Underdark Chef). Asked at every step.
/datum/rogue_food_recipe/proc/can_prepare(mob/living/user)
	return TRUE

/// What to add at a step, for messages: the name alone, as Ratwood shows it ("Next step: Add water."); a reagent's amount
/// goes into the message that needs it, so the name stays a plain noun the translation can decline.
/datum/rogue_food_recipe/proc/step_name(step)
	var/requirement = ingredients[step]
	if(ispath(requirement, /datum/reagent))
		var/datum/reagent/reagent = requirement
		return initial(reagent.name)
	var/list/names = list()
	for(var/atom/option as anything in (islist(requirement) ? requirement : list(requirement)))
		names |= initial(option.name)
	return names.Join(" or ")

/// Whether this item or the reagents in it do for the step.
/datum/rogue_food_recipe/proc/step_accepts(step, obj/item/ingredient)
	var/requirement = ingredients[step]
	if(ispath(requirement, /datum/reagent))
		return !!ingredient.reagents?.has_reagent(requirement, ingredients[requirement])
	for(var/option in (islist(requirement) ? requirement : list(requirement)))
		if(exact_types ? ingredient.type == option : istype(ingredient, option))
			return TRUE
	return FALSE

/// Ratwood SScooking.recipe_index: base type to the recipes that start with it.
GLOBAL_LIST_INIT(rogue_food_recipes, init_rogue_food_recipes())

/proc/init_rogue_food_recipes()
	var/list/index = list()
	for(var/recipe_type in subtypesof(/datum/rogue_food_recipe))
		var/datum/rogue_food_recipe/recipe = new recipe_type
		if(!recipe.base_item || !recipe.result_type || !length(recipe.ingredients))
			continue
		LAZYADDASSOCLIST(index, recipe.base_item, recipe)
	return index

/// Ratwood SScooking.get_recipe(): the recipe of this base whose first step the ingredient fits.
/proc/rogue_food_recipe_for(obj/item/base, obj/item/ingredient)
	for(var/datum/rogue_food_recipe/recipe as anything in GLOB.rogue_food_recipes[base.type])
		if(recipe.step_accepts(1, ingredient))
			return recipe
	return null
