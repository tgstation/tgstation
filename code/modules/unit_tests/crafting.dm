/**
 * Check if a generic atom (because both mobs and the crafter machinery can do it) can potentially craft all recipes,
 * with the exact same types required in the recipe.
 * Then, unless the recipe has the CRAFT_SKIP_MATERIALS_PARITY flag, compare the materials of the
 * crafted result with a spawned instance of the same type to ensure that they match.
 */
/datum/unit_test/crafting
	//The object responsible for using the crafting component
	var/atom/movable/crafter
	//The reagent holder responsible for holding reagents that may be used in a recipe.
	var/obj/item/reagent_containers/cup/bottomless_cup
	///The tools that have been spawned so far, to be reused in other recipes as well.
	var/list/tools = list()

/datum/unit_test/crafting/Run()
	crafter = allocate(__IMPLIED_TYPE__)

	clear_trash()

	var/turf/turf = crafter.loc
	var/old_turf_type = turf.type
	var/datum/component/personal_crafting/unit_test/craft_comp = crafter.AddComponent(__IMPLIED_TYPE__)
	bottomless_cup = allocate_bottomless_cup()

	var/list/all_recipes = GLOB.crafting_recipes + GLOB.cooking_recipes
	for(var/datum/crafting_recipe/recipe as anything in all_recipes)
		if(recipe.non_craftable)
			continue
		//split into a different proc, so if something fails it's both easier to track and doesn't halt the loop.
		process_recipe(craft_comp, recipe)
		if(QDELETED(bottomless_cup) || bottomless_cup.loc != turf) //The cup itself was used in a recipe, rather than its contents.
			bottomless_cup = allocate_bottomless_cup()

	// We have one or two recipes that generate turfs (from stacks, like snow walls), which shouldn't be carried between tests
	if(turf.type != old_turf_type)
		turf.ChangeTurf(old_turf_type)

///Allocate a reagent container with infinite capacity and no reaction to use in crafting
/datum/unit_test/crafting/proc/allocate_bottomless_cup()
	var/obj/item/reagent_containers/cup/bottomless_cup = allocate(__IMPLIED_TYPE__)
	bottomless_cup.reagents.flags |= NO_REACT|DRAINABLE
	bottomless_cup.reagents.maximum_volume = INFINITY
	return bottomless_cup

/datum/unit_test/crafting/proc/process_recipe(datum/component/personal_crafting/unit_test/craft_comp, datum/crafting_recipe/recipe)
	var/turf/turf = crafter.loc
	//Warn if uncreatables were found in the recipe if it fails
	//If it doesn't fail, then it was already handled, maybe through `unit_test_spawn_extras`
	var/list/uncreatables_found

	for(var/spawn_path in recipe.unit_test_spawn_extras)
		var/amount = recipe.unit_test_spawn_extras[spawn_path]
		if(ispath(spawn_path, /obj/item/stack))
			new spawn_path(turf, /*new_amount =*/ amount, /*merge =*/ FALSE)
			continue
		for(var/index in 1 to amount)
			new spawn_path(turf)

	for(var/req_path in recipe.reqs) //spawn items and reagents
		var/amount = recipe.reqs[req_path]

		if(ispath(req_path, /datum/reagent)) //it's a reagent
			if(!bottomless_cup.reagents.has_reagent(req_path, amount))
				bottomless_cup.reagents.add_reagent(req_path, amount + 1, no_react = TRUE)
			continue

		if(req_path in uncreatables)
			LAZYADD(uncreatables_found, req_path)
			continue

		if(ispath(req_path, /obj/item/stack)) //it's a stack
			new req_path(turf, /*new_amount =*/ amount, /*merge =*/ FALSE)
			continue

		//it's any other item
		for(var/iteration in 1 to amount)
			new req_path(turf)

	for(var/req_path in recipe.chem_catalysts) // spawn catalysts
		var/amount = recipe.chem_catalysts[req_path]
		if(!bottomless_cup.reagents.has_reagent(req_path, amount))
			bottomless_cup.reagents.add_reagent(req_path, amount + 1, no_react = TRUE)

	var/list/bulky_objects = list()
	bulky_objects += recipe.structures + recipe.machinery //either structures and machinery could be null
	list_clear_nulls(bulky_objects) //so we clear the list
	for(var/req_path in bulky_objects) //spawn required machinery or structures
		if(req_path in uncreatables)
			LAZYADD(uncreatables_found, req_path)
			continue
		new req_path(turf)

	var/list/needed_tools = list()
	needed_tools += recipe.tool_behaviors + recipe.tool_paths //either tool_behaviors and tool_paths could be null
	list_clear_nulls(needed_tools) //so we clear the list
	///tool instances which have been moved to the crafter loc, which are moved back to nullspace once the recipe is done
	var/list/summoned_tools = list()
	for(var/tooltype in needed_tools)
		var/obj/item/tool = tools[tooltype]
		if(!QDELETED(tool))
			tool.forceMove(turf)
		else
			var/is_behaviour = istext(tooltype)
			var/path_to_use = is_behaviour ? /obj/item : tooltype
			tool = allocate(path_to_use, turf) //we shouldn't delete the tools and allocate and keep them between recipes
			if(is_behaviour)
				tool.tool_behaviour = tooltype
			else if(tooltype in uncreatables)
				LAZYADD(uncreatables_found, tooltype)
				continue
			tools[tooltype] = tool
		summoned_tools |= tool

	var/atom/result = craft_comp.construct_item(crafter, recipe)

	for(var/atom/movable/tool as anything in summoned_tools)
		tool.moveToNullspace()

	if(istext(result) || isnull(result)) //construct_item() returned a text string telling us why it failed.
		TEST_FAIL("[recipe.type] couldn't be crafted during unit test[result || ", result is null for some reason!"]")
		if(uncreatables_found)
			TEST_FAIL("The following objects that shouldn't be instantiated during unit tests were found in [recipe]: [english_list(uncreatables_found)]")
		clear_trash()
		return
	//enforcing materials parity between crafted and spawned for turfs would be more trouble than worth here
	if((recipe.crafting_flags & (CRAFT_NO_MATERIALS|CRAFT_SKIP_MATERIALS_PARITY)) || isturf(result))
		clear_trash()
		return

	var/atom/copycat
	if(isstack(result))
		var/obj/item/stack/stack_result = result
		copycat = new result.type(turf, /*new_amount =*/ stack_result.amount, /*merge =*/ FALSE)
	else
		copycat = new result.type(turf)

	if(!result.compare_materials(copycat))
		var/mats_varname = NAMEOF(result, custom_materials)

		var/warning = "[mats_varname] of [result.type] when crafted compared to only spawned don't match"

		///Added right between the first half of the warning and the second half.
		var/other_info = ""

		var/target_var = mats_varname
		var/list/result_mats = result.custom_materials
		var/list/copycat_mats = copycat.custom_materials
		if(isstack(result))
			var/obj/item/stack/stack_result = result
			var/obj/item/stack/stack_copy = copycat
			target_var = NAMEOF(stack_result, mats_per_unit)
			result_mats = stack_result.mats_per_unit
			copycat_mats = stack_copy.mats_per_unit
			other_info = " (size of resulting stack: [stack_result.amount])"
		var/what_it_should_be = result.transcribe_materials_list(result_mats)
		var/what_it_is = copycat.transcribe_materials_list(copycat_mats)
		//compose a text string containing the syntax and paths to use for editing the custom_materials var
		if(result.custom_materials)
			what_it_should_be += " (you can round a bit for values above 100)"


		///This tells you about other ways to deal with the issue, if you can't just change the materials of the object. For example, if there are two different recipes for it.
		var/add_info = ""

		if(istype(recipe, /datum/crafting_recipe/stack))
			add_info = "add the CRAFT_SKIP_MATERIALS_PARITY crafting flag to its stack_recipe datum"
		else
			add_info = "set the [NAMEOF(recipe, requirements_mats_blacklist)] or [NAMEOF(recipe, removed_mats)] var of [recipe.type], or add the CRAFT_SKIP_MATERIALS_PARITY crafting flag to it"

		TEST_FAIL("[warning]. should be: [target_var] = [what_it_should_be] (current value: [what_it_is])[other_info]. \
			Fix that. Otherwise, [add_info]")

	clear_trash()

///Clear the area around our crafting movable of objects that may mess with the unit test
/datum/unit_test/crafting/proc/clear_trash()
	for(var/atom/movable/trash in (range(1, crafter) - list(crafter, bottomless_cup)))
		qdel(trash)

/datum/component/personal_crafting/unit_test
	ignored_flags = CRAFT_MUST_BE_LEARNED|CRAFT_ONE_PER_TURF|CRAFT_CHECK_DIRECTION|CRAFT_CHECK_DENSITY|CRAFT_ON_SOLID_GROUND|CRAFT_IGNORE_DO_AFTER
