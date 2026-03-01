/// Slapcrafting component!
/datum/element/slapcrafting
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/list/slapcraft_recipes = list()

/**
 * Slapcraft element
 *
 * Slap it onto a item to be able to slapcraft with it
 *
 * args:
 * * slapcraft_recipes (required) = The recipe to attempt crafting.
 * Hit it with an ingredient of the recipe to attempt crafting.
 * It will check the area near the user for the rest of the ingredients and tools.
 * *
**/
/datum/element/slapcrafting/Attach(datum/target, slapcraft_recipes = null)
	..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/item/target_item = target

	if((target_item.item_flags & ABSTRACT) || (target_item.item_flags & DROPDEL))
		return //Don't do anything, it just shouldn't be used in crafting.

	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(attempt_slapcraft))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_info))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(get_examine_more_info))
	RegisterSignal(target, COMSIG_TOPIC, PROC_REF(topic_handler))

	src.slapcraft_recipes = slapcraft_recipes

/datum/element/slapcrafting/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXAMINE_MORE))

/datum/element/slapcrafting/proc/attempt_slapcraft(obj/item/parent_item, obj/item/slapper, mob/user)

	if(isnull(slapcraft_recipes))
		CRASH("NULL SLAPCRAFT RECIPES?")

	//mobs that can't craft (ex: borgs) can't slapcraft.
	var/datum/component/personal_crafting/craft_sheet = user.GetComponent(/datum/component/personal_crafting)
	if(!craft_sheet)
		return

	var/list/valid_recipes
	for(var/datum/crafting_recipe/recipe as anything in slapcraft_recipes)
		// Gotta instance it to copy the list over.
		recipe = new recipe()
		var/list/type_ingredient_list = recipe.reqs
		qdel(recipe)
		if(length(type_ingredient_list) == 1) // No ingredients besides itself? We use one of the tools then
			type_ingredient_list = recipe.tool_paths
			// Check the tool behaviours differently as they aren't types
			for(var/behaviour in initial(recipe.tool_behaviors))
				if(slapper.tool_behaviour == behaviour)
					LAZYADD(valid_recipes, recipe)
					break
		if(is_type_in_list(slapper, type_ingredient_list))
			LAZYADD(valid_recipes, recipe)

	if(!valid_recipes)
		return

	// We might use radials so we need to split the proc chain
	INVOKE_ASYNC(src, PROC_REF(slapcraft_async), parent_item, valid_recipes, user, craft_sheet)

/datum/element/slapcrafting/proc/slapcraft_async(obj/parent_item, list/valid_recipes, mob/user, datum/component/personal_crafting/craft_sheet)

	var/list/recipe_choices = list()

	var/list/result_to_recipe = list()

	var/final_recipe = valid_recipes[1]
	var/string_chosen_recipe
	if(length(valid_recipes) > 1)
		for(var/datum/crafting_recipe/recipe as anything in valid_recipes)
			var/atom/recipe_result = initial(recipe.result)
			result_to_recipe[initial(recipe_result.name)] = recipe
			recipe_choices += list("[initial(recipe_result.name)]" = image(icon = initial(recipe_result.icon), icon_state = initial(recipe_result.icon_state)))

		if(!recipe_choices)
			CRASH("No recipe choices despite validating in earlier proc")

		string_chosen_recipe = show_radial_menu(user, parent_item, recipe_choices, require_near = TRUE)
		if(isnull(string_chosen_recipe))
			return // they closed the thing

	if(string_chosen_recipe)
		final_recipe = result_to_recipe[string_chosen_recipe]


	var/datum/crafting_recipe/actual_recipe = final_recipe

	if(istype(actual_recipe, /datum/crafting_recipe/food))
		actual_recipe = locate(final_recipe) in GLOB.cooking_recipes
	else
		actual_recipe = locate(final_recipe) in GLOB.crafting_recipes

	if(!actual_recipe)
		CRASH("Recipe not located in cooking or crafting recipes: [final_recipe]")

	var/atom/final_result = initial(actual_recipe.result)

	to_chat(user, span_notice("You start crafting \a [initial(final_result.name)]..."))

	var/error_string = craft_sheet.construct_item(user, actual_recipe)

	if(istext(error_string))
		to_chat(user, span_warning("Crafting failed[error_string]"))

/// Alerts any examiners to the recipe, if they wish to know more.
/datum/element/slapcrafting/proc/get_examine_info(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/list/string_results = list()
	// This list saves the recipe result names we've already used to cross-check other recipes so we don't have ', a spear, or a spear!' in the desc.
	var/list/already_used_names
	for(var/datum/crafting_recipe/recipe as anything in slapcraft_recipes)
		// Identical name to a previous recipe's result? Skip in description.
		var/atom/result = initial(recipe.result)
		if(locate(initial(result.name)) in already_used_names)
			continue
		already_used_names += initial(result.name)
		string_results += list("\a [initial(result.name)]")

	examine_list["crafting component"] = "You think [source] could be used to make [english_list(string_results)]! Examine again to look at the details..."

/// Alerts any examiners to the details of the recipe.
/datum/element/slapcrafting/proc/get_examine_more_info(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	for(var/datum/crafting_recipe/recipe as anything in slapcraft_recipes)
		var/atom/result = initial(recipe.result)
		examine_list += "<a href='byond://?src=[REF(source)];check_recipe=[REF(recipe)]'>See Recipe For [initial(result.name)]</a>"

/datum/element/slapcrafting/proc/topic_handler(atom/source, user, href_list)
	SIGNAL_HANDLER

	if(!href_list["check_recipe"])
		return

	var/datum/crafting_recipe/cur_recipe = locate(href_list["check_recipe"]) in slapcraft_recipes

	if(isnull(cur_recipe))
		CRASH("null recipe!")

	var/atom/result = initial(cur_recipe.result)

	to_chat(user, span_notice("You could craft \a [initial(result.name)] by applying one of these items to it!"))

	// Gotta instance it to copy the lists over.
	cur_recipe = new cur_recipe()
	var/list/type_ingredient_list = cur_recipe.reqs

	// Final return string.
	var/string_ingredient_list = ""

	// Check the ingredients of the crafting recipe.
	for(var/valid_type in type_ingredient_list)
		// Check if they're datums, specifically reagents.
		var/datum/reagent/reagent_ingredient = valid_type
		if(istype(reagent_ingredient))
			var/amount = initial(cur_recipe.reqs[reagent_ingredient])
			string_ingredient_list += "[amount] unit[amount > 1 ? "s" : ""] of [initial(reagent_ingredient.name)]\n"

		var/atom/ingredient = valid_type
		var/amount = initial(cur_recipe.reqs[ingredient])

		// If we're about to describe the ingredient that the component is based on, lower the described amount by 1 or remove it outright.
		if(source.type == valid_type)
			if(amount > 1)
				amount--
			else
				continue
		string_ingredient_list += "[amount > 1 ? ("[amount]" + " of") : "a"] [initial(ingredient.name)]\n"

	// If we did find ingredients then add them onto the list.
	if(length(string_ingredient_list))
		to_chat(user, span_boldnotice("Extra Ingredients:"))
		to_chat(user, boxed_message(span_notice(string_ingredient_list)))

	var/list/tool_list = ""

	// Paste the required tools.
	for(var/valid_type in cur_recipe.tool_paths)
		var/atom/tool = valid_type
		tool_list += "\a [initial(tool.name)]\n"

	for(var/string in cur_recipe.tool_behaviors)
		tool_list += "\a [string]\n"

	if(length(tool_list))
		to_chat(user, span_boldnotice("Required Tools:"))
		to_chat(user, boxed_message(span_notice(tool_list)))

	qdel(cur_recipe)

