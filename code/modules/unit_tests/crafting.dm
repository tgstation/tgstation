/**
 * The accepted discrepancy between the amount of material between an item when crafted and the same item when spawned
 * so we don't have to be obnoxious about small portion of mats being lost for items that are processed in multiple other
 * results (eg. a slab of meat being cut in three cutlets, and each cutlet can be used to craft different things)
 * right now it's around 3 points per 100 units of a material.
 */
#define ACCEPTABLE_MATERIAL_DEVIATION 0.033

/**
 * Check if a generic atom (because both mobs and the crafter machinery can do it) can potentially craft all recipes,
 * with the exact same types required in the recipe, and also compare the materials of crafted result with one of the same type
 * to ansure they match if the recipe has the CRAFT_ENFORCE_MATERIALS_PARITY flag.
 */
/datum/unit_test/crafting

/datum/unit_test/crafting/Run()
	var/atom/movable/crafter = allocate(__IMPLIED_TYPE__)

	///Clear the area around our crafting movable of objects that may mess with the unit test
	for(var/atom/movable/trash in (range(1, crafter) - crafter))
		qdel(trash)

	var/turf/turf = crafter.loc
	var/old_turf_type = turf.type
	var/datum/component/personal_crafting/unit_test/craft_comp = crafter.AddComponent(__IMPLIED_TYPE__)
	var/obj/item/reagent_containers/cup/bottomless_cup = allocate_bottomless_cup()

	var/list/tools = list()

	var/list/all_recipes = GLOB.crafting_recipes + GLOB.cooking_recipes
	for(var/datum/crafting_recipe/recipe as anything in all_recipes)
		if(recipe.non_craftable)
			continue
		//split into a different proc, so if something fails it's both easier to track and doesn't halt the loop.
		process_recipe(crafter, craft_comp, recipe, bottomless_cup, tools)
		if(QDELETED(bottomless_cup) || bottomless_cup.loc != turf) //The cup itself was used in a recipe, rather than its contents.
			bottomless_cup = allocate_bottomless_cup()

	// We have one or two recipes that generate turf (from stacks, like snow walls), which shouldn't be carried between tests
	if(turf.type != old_turf_type)
		turf.ChangeTurf(old_turf_type)

///Allocate a reagent container with infinite capacity and no reaction to use in crafting
/datum/unit_test/crafting/proc/allocate_bottomless_cup()
	var/obj/item/reagent_containers/cup/bottomless_cup = allocate(__IMPLIED_TYPE__)
	bottomless_cup.reagents.flags |= NO_REACT|DRAINABLE
	bottomless_cup.reagents.maximum_volume = INFINITY
	return bottomless_cup

/datum/unit_test/crafting/proc/process_recipe(
	atom/crafter,
	datum/component/personal_crafting/unit_test/craft_comp,
	datum/crafting_recipe/recipe,
	obj/item/reagent_containers/bottomless_cup,
	list/tools
)
	var/turf/turf = crafter.loc
	//Components that have to be deleted later so they don't mess up with other recipes
	var/list/spawned_components = list()
	//Warn if uncreatables were found in the recipe if it fails
	//If it doesn't fail, then it was already handled, maybe through `unit_test_spawn_extras`
	var/list/uncreatables_found

	for(var/spawn_path in recipe.unit_test_spawn_extras)
		var/amount = recipe.unit_test_spawn_extras[spawn_path]
		if(ispath(spawn_path, /obj/item/stack))
			spawned_components += new spawn_path(turf, /*new_amount =*/ amount, /*merge =*/ FALSE)
			continue
		for(var/index in 1 to amount)
			spawned_components += new spawn_path(turf)

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
			spawned_components += new req_path(turf, /*new_amount =*/ amount, /*merge =*/ FALSE)
			continue

		//it's any other item
		for(var/iteration in 1 to amount)
			spawned_components += new req_path(turf)

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
		spawned_components += new req_path(turf)

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
			TEST_FAIL("The following objects that shouldn't initialize during unit tests were found in [recipe]: [english_list(uncreatables_found)]")
		delete_components(spawned_components)
		return
	//enforcing materials parity between crafted and spawned for turfs would be more trouble than worth right now
	if(isturf(result))
		delete_components(spawned_components)
		return

	spawned_components += result

	if(!(recipe.crafting_flags & CRAFT_ENFORCE_MATERIALS_PARITY))
		delete_components(spawned_components)
		return

	var/atom/copycat = new result.type(turf)
	spawned_components += copycat

	// SSmaterials caches the combinations so we don't have to run more complex checks
	if(result.custom_materials == copycat.custom_materials)
		delete_components(spawned_components)
		return
	var/comparison_failed = TRUE
	if(length(result.custom_materials) == length(copycat.custom_materials))
		comparison_failed = FALSE
		for(var/mat in result.custom_materials)
			var/enemy_amount = copycat.custom_materials[mat]
			if(!enemy_amount) //break the loop early, we cannot perform a division by zero anyway
				comparison_failed = TRUE
				break
			var/ratio_difference = abs((result.custom_materials[mat] / enemy_amount) - 1)
			if(ratio_difference > ACCEPTABLE_MATERIAL_DEVIATION)
				comparison_failed = TRUE
	if(comparison_failed)
		var/warning = "custom_materials of [result.type] when crafted and spawned don't match"
		var/what_it_should_be = "null"
		//compose a text string containing the syntax and paths to use for editing the custom_materials var
		if(result.custom_materials)
			what_it_should_be = "\[list("
			var/index = 1
			var/mats_len = length(result.custom_materials)
			for(var/datum/material/mat as anything in result.custom_materials)
				what_it_should_be += "[mat.type] = [result.custom_materials[mat]]"
				if(index < mats_len)
					what_it_should_be += ", "
				index++
			what_it_should_be += ")\] (you can round values a bit)"
		TEST_FAIL("[warning]. custom_materials should be [what_it_should_be]. \
			Otherwise set the requirements_mats_blacklist variable for [recipe] \
			or remove the CRAFT_ENFORCE_MATERIALS_PARITY crafting flag from it")

	delete_components(spawned_components)

/**
 * Clear the area of the components that have been spawned as either the requirements of a recipe or its result
 * so they don't mess up with recipes that come after it.
 */
/datum/unit_test/crafting/proc/delete_components(list/comps)
	for(var/atom/movable/used as anything in comps)
		if(!QDELETED(used))
			qdel(used)

/datum/component/personal_crafting/unit_test
	ignored_flags = CRAFT_MUST_BE_LEARNED|CRAFT_ONE_PER_TURF|CRAFT_CHECK_DIRECTION|CRAFT_CHECK_DENSITY|CRAFT_ON_SOLID_GROUND|CRAFT_IGNORE_DO_AFTER

#undef ACCEPTABLE_MATERIAL_DEVIATION
