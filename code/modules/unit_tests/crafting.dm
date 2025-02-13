/**
 * Check if a generic atom (because both mobs and the crafter machinery can do it) can potentially craft all recipes,
 * with the exact same types required in the recipe, and also compare the materials of crafted result with one of the same type
 * to ansure they match.
 */
/datum/unit_test/crafting

/datum/unit_test/crafting/Run()
	var/static/list/ignored_recipes = list()

	var/atom/movable/crafter = allocate(__IMPLIED_TYPE__)
	var/turf/turf = crafter.loc
	var/datum/component/personal_crafting/unit_test/craftsman = AddComponent(__IMPLIED_TYPE__)
	var/obj/item/reagent_containers/cup/bottomless_beaker = allocate(__IMPLIED_TYPE__)
	bottomless_beaker.reagents.flags |= NO_REACT
	bottomless_beaker.reagents.maximum_volume = INFINITY
	var/list/tools = list()

	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		for(var/req_path in recipe.reqs) //allocate items and reagents
			var/amount = recipe.reqs[req_path]
			if(ispath(req_path, /datum/reagent))
				if(!bottomless_beaker.reagents.has_reagent(req_path, amount))
					bottomless_beaker.reagents.add_reagent(req_path, amount, added_purity = 1)
			else
				var/atom/located = locate(req_path) in allocated
				if(ispath(req_path, /obj/item/stack))
					var/obj/item/stack/stack = located
					if(QDELETED(located) || (located.type in recipe.blacklist) || stack.amount <= amount)
						new (req_path, turf, /*new_amount =*/ amount, /*merge =*/ FALSE)
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
			if(!bottomless_beaker.reagents.has_reagent(req_path, amount))
				bottomless_beaker.reagents.add_reagent(req_path, amount, added_purity = 1)

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
			continue

/datum/component/personal_crafting/unit_test
	ignored_flags = CRAFT_MUST_BE_LEARNED|CRAFT_ONE_PER_TURF|CRAFT_CHECK_DIRECTION|CRAFT_CHECK_DENSITY|CRAFT_ON_SOLID_GROUND
