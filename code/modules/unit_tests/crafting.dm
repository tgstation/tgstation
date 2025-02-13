/**
 * Check if a generic atom (because both mobs and the crafter machinery can do it) can potentially craft all recipes,
 * with the exact same types required in the recipe, and also compare the materials of crafted result with one of the same type
 * to ansure they match.
 */
/datum/unit_test/crafting

/datum/unit_test/crafting/Run()
	var/static/list/blacklisted_recipes = list()

	var/atom/movable/crafter = allocate(__IMPLIED_TYPE__)
	var/turf/turf = crafter.loc
	var/old_turf_type = turf.type
	var/datum/component/personal_crafting/unit_test/craftsman = AddComponent(__IMPLIED_TYPE__)
	var/obj/item/reagent_containers/cup/crafting_blacklist/bottomless_cup = allocate(__IMPLIED_TYPE__)
	bottomless_cup.reagents.flags |= NO_REACT
	bottomless_cup.reagents.maximum_volume = INFINITY
	var/list/tools = list()

	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		if(recipe.type in blacklisted_recipes)
			continue
		//split into a different proc, so if something fails it's both easier to track and doesn't halt the loop.
		process_recipe(crafter, recipe, bottomless_cup, tools)

	// We have one or two recipes that generate turf (likely from stacks, like snow walls), which shouldn't be carried between tests
	if(turf.type != old_turf_type)
		turf.ChangeTurf(old_turf_type)

/datum/unit_test/crafting/proc/process_recipe(atom/crafter, datum/crafting_recipe/recipe, obj/item/reagent_containers/bottomless_cup, list/tools)
	for(var/req_path in recipe.reqs) //allocate items and reagents
		var/amount = recipe.reqs[req_path]
		if(ispath(req_path, /datum/reagent))
			if(!bottomless_cup.reagents.has_reagent(req_path, amount))
				bottomless_cup.reagents.add_reagent(req_path, amount, added_purity = 1)
		else
			var/atom/located = locate(req_path) in allocated
			if(ispath(req_path, /obj/item/stack))
				var/obj/item/stack/stack = located
				if(QDELETED(located) || (located.type in recipe.blacklist) || stack.amount <= amount)
					new req_path(turf, /*new_amount =*/ amount, /*merge =*/ FALSE)
			else
				var/list/matches = turf.get_all_contents_type(req_path)
				for(var/atom/match as anything in matches)
					if(match in recipe.blacklist)
						matches -= match
				var/to_spawn = amount - length(matches)
				for(var/iteration in 1 to to_spawn)
					allocate(req_path)

	for(var/req_path in recipe.chem_catalysts) // allocate catalysts
		var/amount = recipe.chem_catalysts[req_path]
		if(!bottomless_cup.reagents.has_reagent(req_path, amount))
			bottomless_cup.reagents.add_reagent(req_path, amount, added_purity = 1)

	for(var/req_path in recipe.structures + recipe.machinery) //allocate required machinery or structures
		var/atom/located = locate(req_path) in allocated
		if(QDELETED(located))
			allocate(req_path)

	for(var/tooltype in (recipe.tool_behaviors + recipe.tool_paths))
		var/atom/tool = tools[tooltype]
		if(!QDELETED(tool))
			continue
		var/is_behaviour = !ispath(tooltype)
		var/obj/item/new_tool = allocate(is_behaviour ? /obj/item : tooltype)
		if(is_behaviour)
			new_tool.tool_behaviour = tooltype
		tools[tooltype] = new_tool

	var/atom/result = craftsman.construct_item(crafter, recipe)
	if(istext(result)) //construct_item() returned a text string telling us why it failed.
		TEST_FAIL("[recipe.type] couldn't be crafted during crafting unit test[result].")
		return
	if(isturf(result)) //enforcing materials parity between crafted and spawned for turfs would be more trouble than worth right now
		return

	var/atom/copycat = allocate(result.type)
	if(result.custom_materials != copycat.custom_materials) // SSmaterials caches the combinations so we don't have to run more complex checks.
		var/warning = "custom_materials of [result.type] when crafted and spawned don't match."
		var/what_it_should_be = "null"
		if(result.custom_materials) //compose a text string containing the syntax and paths to use for editing the custom_materials var
			what_it_should_be = "list("
			var/index = 1
			var/mats_len = length(result.custom_materials)
			for(var/datum/material/mat as anything in result.custom_materials)
				what_it_should_be += "[mat.type] = [result.custom_materials[mat]]"
				if(index < mats_len)
					what_it_should_be += ", "
				index++
			what_it_should_be += ")"
		TEST_FAIL("[warning] Set custom_materials to \[[what_it_should_be]\] or blacklist [recipe.type] in the unit test")

///Unit test only path, blacklisted from all recipes
/obj/item/reagent_containers/cup/crafting_blacklist

/datum/crafting_recipe/New()
	LAZYADD(blacklist, /obj/item/reagent_containers/cup/crafting_blacklist)
	return ..()

/datum/component/personal_crafting/unit_test
	ignored_flags = CRAFT_MUST_BE_LEARNED|CRAFT_ONE_PER_TURF|CRAFT_CHECK_DIRECTION|CRAFT_CHECK_DENSITY|CRAFT_ON_SOLID_GROUND
