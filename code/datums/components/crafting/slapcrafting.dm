/// Slapcrafting component!
/datum/component/slapcrafting
	var/list/slapcraft_recipes = list()

/**
 * Slapcraft component
 *
 * Slap it onto a item to be able to slapcraft with it
 *
 * args:
 * * item_to_slap_with (required) = When the item is slapped by this, it will attempt the slapcraft
 * * slapcraft_recipe (required) = The recipe to attempt crafting. It will check the area near the user for the rest of the ingredients.
 * *
**/
/datum/component/slapcrafting/Initialize(
		slapcraft_recipes = null,
	)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attempt_slapcraft))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(get_examine_info))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(get_examine_more_info))

	src.slapcraft_recipes = slapcraft_recipes

/datum/component/slapcrafting/Destroy(force, silent)
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXAMINE_MORE))
	return ..()

/datum/component/slapcrafting/proc/attempt_slapcraft(obj/item/parent_item, obj/item/slapper, mob/user)

	if(isnull(slapcraft_recipes))
		CRASH("NULL SLAPCRAFT RECIPES?")

	var/list/valid_recipes
	for(var/datum/crafting_recipe/recipe in slapcraft_recipes)
		// For our purposes, they're the same thing in the end
		var/list/type_ingredient_list = initial(recipe.parts) + initial(recipe.reqs)
		if(is_type_in_list(slapper, type_ingredient_list))
			LAZYADD(valid_recipes, recipe)

	if(!valid_recipes)
		return

	// We might use radials so we need to split the proc chain
	INVOKE_ASYNC(src, PROC_REF(slapcraft_async), valid_recipes, user)

/datum/component/slapcrafting/proc/slapcraft_async(list/valid_recipes, mob/user)

	var/list/recipe_choices

	var/final_recipe = valid_recipes[1]
	if(valid_recipes > 1)
		for(var/datum/crafting_recipe/recipe as anything in valid_recipes)
			var/atom/recipe_result = initial(recipe.result)
			var/image/option_image = image(icon = initial(recipe_result.icon), icon_state = initial(recipe_result.icon_state))
			recipe_choices += list(recipe_result = option_image)

		if(!recipe_choices)
			CRASH("No recipe choices despite validating in earlier proc")

		final_recipe = show_radial_menu(user, parent, recipe_choices, require_near = TRUE)

	var/datum/component/personal_crafting/craft_sheet = user.GetComponent(/datum/component/personal_crafting)
	if(!craft_sheet)
		CRASH("No craft sheet on user ??")

	var/actual_recipe

	if(istype(actual_recipe, /datum/crafting_recipe/food))
		actual_recipe = locate(slapcraft_recipe) in GLOB.cooking_recipes
	else
		actual_recipe = locate(slapcraft_recipe) in GLOB.crafting_recipes

	craft_sheet.construct_item(user, actual_recipe)

/// Alerts any examiners to the recipe, if they wish to know more.
/datum/component/slapcrafting/proc/get_examine_info(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/string_results
	for(var/datum/crafting_recipe/recipe as anything in slapcraft_recipes)
		var/atom/result = initial(recipe.result)
		string_results += isnull(result) ? "a [initial(result.name)]" : ", or a [initial(result.name)]"

	examine_list += span_notice("You think [parent] could be used to make [string_results]! Examine again to look at the details...")

/// Alerts any examiners to the details of the recipe.
/datum/component/slapcrafting/proc/get_examine_more_info(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/atom/result = initial(slapcraft_recipe.result)

	for(var/datum/crafting_recipe/recipe as anything in slapcraft_recipes)
		var/atom/result = initial(recipe.result)
		examine_list += "<a href='?src=[REF(src)];check_recipe=[recipe]'>See Recipe For [initial(result.name)]</a>"

/datum/element/weapon_description/proc/topic_handler(atom/source, user, href_list)
	SIGNAL_HANDLER

	if(href_list["check_recipe"])
		switch(href_list["member_action"])
			if("remove")
				remove_member(user,ckey,team)
		to_chat(user, span_notice(examine_block("[build_label_text(source)]")))

	examine_list += span_notice("You could craft a [initial(result.name)] by applying a [item_to_slap_with] to it!")

	// For our purposes, they're the same thing in the end
	var/list/type_ingredient_list = initial(slapcraft_recipe.parts)
	type_ingredient_list += initial(slapcraft_recipe.reqs)

	// Final return string list!
	var/list/string_ingredient_list

	for(var/valid_type in type_ingredient_list)
		if(isdatum(valid_type))
			var/datum/reagent/reagent_ingredient = valid_type
			if(!istype(reagent_ingredient))
				stack_trace("Ingredient is datum but not reagent? [reagent_ingredient]")
			var/amount = initial(slapcraft_recipe.parts[reagent_ingredient])
			string_ingredient_list += "[amount] unit[amount > 1 ? "s" : ""] of [initial(reagent_ingredient.name)]"

		var/atom/ingredient = valid_type
		if(!istype(ingredient, item_to_slap_with)) // redundant
			var/amount = initial(slapcraft_recipe.parts[ingredient])
			string_ingredient_list += "[amount > 1 ? (amount + "of") : "a"] [initial(ingredient.name)]"

	if(length(string_ingredient_list))
		examine_list += span_boldnotice("Additional Ingredients:")
		examine_list += span_notice(string_ingredient_list)

	var/tool_list = ""

	for(var/valid_type in initial(slapcraft_recipe.tool_paths))
		var/atom/tool = valid_type
		tool_list += "\a [initial(tool.name)]"

	for(var/string in initial(slapcraft_recipe.tool_behaviors))
		tool_list += "\a [string]"

	if(length(tool_list))
		examine_list += span_boldnotice("Required Tools:")
		examine_list += span_notice(tool_list)
