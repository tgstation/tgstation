//list key declarations used in check_contents(), get_surroundings() and check_tools()
#define CONTENTS_INSTANCES "instances"
#define CONTENTS_MACHINERY "machinery"
#define CONTENTS_STRUCTURES "structures"
#define CONTENTS_REQS_COUNT "reqs_count"
#define CONTENTS_TOOL_BEHAVIOUR "tool_behaviour"
#define CONTENTS_POSSIBLE_TOOLS "tool_instances"

/// The portion of time spent crafting that recipe dependant on the speed of the tools
#define RECIPE_DYNAMIC_TIME_COEFF 0.85

/datum/component/personal_crafting
	/// Custom screen_loc for our element
	var/screen_loc_override

/datum/component/personal_crafting/Initialize(screen_loc_override)
	src.screen_loc_override = screen_loc_override
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(create_mob_button))

/datum/component/personal_crafting/proc/create_mob_button(mob/user, client/user_client)
	SIGNAL_HANDLER

	var/datum/hud/hud = user.hud_used
	var/atom/movable/screen/craft/craft_ui = new()
	craft_ui.icon = hud.ui_style
	if (screen_loc_override)
		craft_ui.screen_loc = screen_loc_override
	hud.static_inventory += craft_ui
	user_client.screen += craft_ui
	RegisterSignal(craft_ui, COMSIG_SCREEN_ELEMENT_CLICK, PROC_REF(component_ui_interact))

#define COOKING TRUE
#define CRAFTING FALSE

/datum/component/personal_crafting
	var/busy
	var/mode = CRAFTING
	var/display_craftable_only = FALSE
	var/display_compact = FALSE
	var/forced_mode = FALSE
	/// crafting flags we ignore when considering a recipe
	var/ignored_flags = NONE

/* This is what procs do:
	get_environment - gets a list of things accessable for crafting by user
	get_surroundings - takes a list of things and makes a list of key-types to values-amounts of said type in the list
	check_contents - takes a recipe and a key-type list and checks if said recipe can be done with available stuff
	check_tools - takes recipe, a key-type list, and a user and checks if there are enough tools to do the stuff, checks bugs one level deep
	construct_item - takes a recipe and a user, call all the checking procs, calls do_after, checks all the things again, calls del_reqs, creates result, calls CheckParts of said result with argument being list returned by deel_reqs
	get_used_reqs - takes recipe, a user and a list (for mats), loops over the recipes reqs var and tries to find everything in the list make by get_environment and returns a list of the components to be used
*/

/**
 * Check that the contents of the recipe meet the requirements.
 *
 * user: The /mob that initated the crafting.
 * recipe: The /datum/crafting_recipe being attempted.
 * contents: List of items to search for the recipe's reqs.
 */
/datum/component/personal_crafting/proc/check_contents(atom/a, datum/crafting_recipe/recipe, list/contents)
	var/list/item_instances = contents[CONTENTS_INSTANCES]
	var/list/machines = contents[CONTENTS_MACHINERY]
	var/list/structures = contents[CONTENTS_STRUCTURES]
	contents = contents[CONTENTS_REQS_COUNT]


	var/list/requirements_list = list()

	// Process all requirements
	for(var/requirement_path in recipe.reqs)
		// Check we have the appropriate amount available in the contents list
		var/needed_amount = recipe.reqs[requirement_path]
		for(var/content_item_path in contents)
			// Right path and not blacklisted
			if(!ispath(content_item_path, requirement_path) || recipe.blacklist.Find(content_item_path))
				continue

			needed_amount -= contents[content_item_path]
			if(needed_amount <= 0)
				break

		if(needed_amount > 0)
			return FALSE

		// Store the instances of what we will use for recipe.check_requirements() for requirement_path
		var/list/instances_list = list()
		for(var/instance_path in item_instances)
			if(ispath(instance_path, requirement_path))
				instances_list += item_instances[instance_path]

		requirements_list[requirement_path] = instances_list

	for(var/requirement_path in recipe.chem_catalysts)
		if(contents[requirement_path] < recipe.chem_catalysts[requirement_path])
			return FALSE

	var/mech_found = FALSE
	for(var/machinery_path in recipe.machinery)
		mech_found = FALSE
		for(var/obj/machinery/machine as anything in machines)
			if(ispath(machine, machinery_path))// We only need one machine per key, unlike items
				mech_found = TRUE
				break
		if(!mech_found)
			return FALSE

	var/found = FALSE
	for(var/structure_path in recipe.structures)
		found = FALSE
		for(var/obj/structure/structure as anything in structures)
			if(ispath(structure, structure_path))// We only need one structure per key, unlike items
				found = TRUE
				break
		if(!found)
			return FALSE

	//Skip extra requirements when unit testing, like, underwater basket weaving? Get the hell out of here
	return PERFORM_ALL_TESTS(crafting) || recipe.check_requirements(a, requirements_list)

/datum/component/personal_crafting/proc/get_environment(atom/a, list/blacklist = null, radius_range = 1)
	. = list()

	if(!isturf(a.loc))
		return

	for(var/atom/movable/AM in range(radius_range, a))
		if((AM.flags_1 & HOLOGRAM_1) || (blacklist && (AM.type in blacklist)))
			continue
		if(isitem(AM))
			var/obj/item/item = AM
			if(item.item_flags & ABSTRACT) //let's not tempt fate, shall we?
				continue
		. += AM

/datum/component/personal_crafting/proc/get_surroundings(atom/source, list/blacklist=null)
	. = list()
	.[CONTENTS_TOOL_BEHAVIOUR] = list()
	.[CONTENTS_REQS_COUNT] = list()
	.[CONTENTS_INSTANCES] = list()
	.[CONTENTS_MACHINERY] = list()
	.[CONTENTS_STRUCTURES] = list()
	for(var/obj/object in get_environment(source, blacklist))
		if(isitem(object))
			var/obj/item/item = object
			LAZYADDASSOCLIST(.[CONTENTS_INSTANCES], item.type, item)
			if(isstack(item))
				var/obj/item/stack/stack = item
				.[CONTENTS_REQS_COUNT][item.type] += stack.amount
			else
				.[CONTENTS_REQS_COUNT][item.type] += 1
				if(is_reagent_container(item) && item.is_drainable() && length(item.reagents.reagent_list)) //some container that has some reagents inside it that can be drained
					var/obj/item/reagent_containers/container = item
					for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
						.[CONTENTS_REQS_COUNT][reagent.type] += reagent.volume
			if(item.tool_behaviour)
				var/current_tool_speed = .[CONTENTS_TOOL_BEHAVIOUR][item.tool_behaviour]
				if(current_tool_speed < item.toolspeed)
					.[CONTENTS_TOOL_BEHAVIOUR][item.tool_behaviour] = item.toolspeed
		else if (ismachinery(object))
			LAZYADDASSOCLIST(.[CONTENTS_MACHINERY], object.type, object)
		else if (isstructure(object))
			LAZYADDASSOCLIST(.[CONTENTS_STRUCTURES], object.type, object)

	var/list/within_source = list()
	for(var/obj/item/item in source.contents)
		within_source += item
		if(item.atom_storage)
			within_source += item.contents

	for(var/obj/item/item as anything in within_source)
		if(!item.tool_behaviour)
			continue
		var/current_tool_speed = .[CONTENTS_TOOL_BEHAVIOUR][item.tool_behaviour]
		if(current_tool_speed < item.toolspeed)
			.[CONTENTS_TOOL_BEHAVIOUR][item.tool_behaviour] = item.toolspeed

	var/list/instances = .[CONTENTS_INSTANCES]
	for(var/item_type in instances)
		.[CONTENTS_POSSIBLE_TOOLS] += instances[item_type]
	.[CONTENTS_POSSIBLE_TOOLS] += within_source

/// Returns a boolean on whether the tool requirements of the input recipe are satisfied by the input source and surroundings.
/datum/component/personal_crafting/proc/check_tools(atom/source, datum/crafting_recipe/recipe, list/surroundings, final_check = FALSE)
	if(!length(recipe.tool_behaviors) && !length(recipe.tool_paths))
		return TRUE

	for(var/required_quality in recipe.tool_behaviors)
		if(!(required_quality in surroundings[CONTENTS_TOOL_BEHAVIOUR]))
			return FALSE

	var/list/possible_tool_instances = surroundings[CONTENTS_POSSIBLE_TOOLS]
	for(var/required_path in recipe.tool_paths)
		if(!(locate(required_path) in possible_tool_instances))
			return FALSE

	return recipe.check_tools(source, possible_tool_instances, final_check)

/datum/component/personal_crafting/proc/construct_item(atom/crafter, datum/crafting_recipe/recipe)
	if(!crafter)
		return ", unknown error!" // This should never happen, but in the event that it does...

	if(!recipe)
		return ", invalid recipe!" // This can happen, I can't really explain why, but it can. Better safe than sorry.

	var/list/contents = get_surroundings(crafter, recipe.blacklist)
	var/fail_message = perform_all_checks(crafter, recipe, contents, check_tools_last = ignored_flags & CRAFT_IGNORE_DO_AFTER)
	if(fail_message)
		return fail_message

	//If we're a mob we'll try a do_after; non mobs will instead instantly construct the item
	if(!(ignored_flags & CRAFT_IGNORE_DO_AFTER))
		var/recipe_time = recipe.time
		var/tools_used = length(recipe.tool_behaviors) + length(recipe.tool_paths)

		// If there's any, the speed of the tools used to craft the recipe influence the time spent crafting it
		if(tools_used > 0)
			//get the portion of time that's affected by tool speed at all and subtract it from the full recipe time
			var/dynamic_recipe_time = recipe.time * RECIPE_DYNAMIC_TIME_COEFF
			recipe_time -= dynamic_recipe_time
			//Then divide it by the number of tools used in the recipe, and recalculate it.
			dynamic_recipe_time /= tools_used

			var/list/possible_tool_instances = contents[CONTENTS_POSSIBLE_TOOLS]
			for(var/tool in recipe.tool_paths)
				var/best_speed = 10 //failsafe-ish
				for(var/obj/item/item as anything in possible_tool_instances)
					if(!istype(item, tool) || best_speed < item.toolspeed)
						continue
					best_speed = item.toolspeed
				recipe_time += dynamic_recipe_time * best_speed

			var/found_behaviors = contents[CONTENTS_TOOL_BEHAVIOUR]
			for(var/behavior in recipe.tool_behaviors)
				recipe_time += dynamic_recipe_time * found_behaviors[behavior]

		if(!do_after(crafter, round(recipe_time, 0.1 SECONDS), target = crafter))
			return "."
		contents = get_surroundings(crafter, recipe.blacklist)
		fail_message = perform_all_checks(crafter, recipe, contents, check_tools_last = TRUE)
		if(fail_message)
			return fail_message

	//used to gather the material composition of the utilized requirements to transfer to the result
	var/list/total_materials = list()
	var/list/stuff_to_use = get_used_reqs(recipe, crafter, total_materials)
	var/atom/result
	var/turf/craft_turf = get_turf(crafter.loc)
	var/set_materials = TRUE
	if(ispath(recipe.result, /turf))
		result = craft_turf.place_on_top(recipe.result)
	else if(ispath(recipe.result, /obj/item/stack))
		//we don't merge the stack right away but try to put it in the hand of the crafter
		result = new recipe.result(craft_turf, recipe.result_amount || 1, /*merge =*/FALSE)
		set_materials = FALSE //stacks are bit too complex for it for now, but you're free to change that.
	else
		result = new recipe.result(craft_turf)
		if(result.atom_storage && recipe.delete_contents)
			for(var/obj/item/thing in result)
				qdel(thing)
	result.setDir(crafter.dir)
	var/datum/reagents/holder = locate() in stuff_to_use
	if(holder) //transfer reagents from ingredients to result
		if(!ispath(recipe.result, /obj/item/reagent_containers) && result.reagents)
			if(recipe.crafting_flags & CRAFT_CLEARS_REAGENTS)
				result.reagents.clear_reagents()
			if(recipe.crafting_flags & CRAFT_TRANSFERS_REAGENTS)
				holder.trans_to(result.reagents, holder.total_volume, no_react = TRUE)
		stuff_to_use -= holder //This is the only non-movable in our list, we need to remove it.
		qdel(holder)
	result.on_craft_completion(stuff_to_use, recipe, crafter)
	if(set_materials)
		result.set_custom_materials(total_materials)
	for(var/atom/movable/component as anything in stuff_to_use) //delete anything that wasn't stored inside the object
		if(component.loc != result || isturf(result))
			qdel(component)
	if(!PERFORM_ALL_TESTS(crafting))
		SSblackbox.record_feedback("tally", "object_crafted", 1, result.type)
	return result //Send the item back to whatever called this proc so it can handle whatever it wants to do with the new item

///This proc performs all the necessary conditional control statement to ensure that the object is allowed to be crafted by the crafter.
/datum/component/personal_crafting/proc/perform_all_checks(atom/crafter, datum/crafting_recipe/recipe, list/contents, check_tools_last = FALSE)
	if(!check_contents(crafter, recipe, contents))
		return ", missing component."

	var/turf/dest_turf = get_turf(crafter)

	// Mobs call perform_all_checks() twice since they don't have the CRAFT_IGNORE_DO_AFTER flag,
	// one before the do_after() and another after that. While other entities may have that flag and therefore only call the proc once.
	// Check_tools() meanwhile has a final_check arg which, if true, may perform some statements that can
	// modify some of the tools, like expending charges from a crayon or spraycan, which may make it unable
	// to meet some criterias afterward, so it's important to call that, last by the end of the final perform_all_checks().
	// For any non-final perform_all_checks() call, just keep check_tools() here because it's
	// the most imporant feedback after "missing component".
	if(!check_tools_last && !check_tools(crafter, recipe, contents, FALSE))
		return ", missing tool."

	var/considered_flags = recipe.crafting_flags & ~(ignored_flags)

	if((considered_flags & CRAFT_ONE_PER_TURF) && (locate(recipe.result) in dest_turf))
		return ", already one here!"

	if(considered_flags & CRAFT_CHECK_DIRECTION)
		if(!valid_build_direction(dest_turf, crafter.dir, is_fulltile = (considered_flags & CRAFT_IS_FULLTILE)))
			return ", won't fit here!"

	if(considered_flags & CRAFT_ON_SOLID_GROUND)
		if(isclosedturf(dest_turf))
			return ", cannot be made on a wall!"

		if(is_type_in_typecache(dest_turf, GLOB.turfs_without_ground))
			if(!locate(/obj/structure/thermoplastic) in dest_turf) // for tram construction
				return ", must be made on solid ground!"

	if(considered_flags & CRAFT_CHECK_DENSITY)
		for(var/obj/object in dest_turf)
			if(object.density && !(object.obj_flags & IGNORE_DENSITY) || object.obj_flags & BLOCKS_CONSTRUCTION)
				return ", something is in the way!"

	if(recipe.placement_checks & STACK_CHECK_CARDINALS)
		var/turf/nearby_turf
		for(var/direction in GLOB.cardinals)
			nearby_turf = get_step(dest_turf, direction)
			if(locate(recipe.result) in nearby_turf)
				to_chat(crafter, span_warning("\The [recipe.name] must not be built directly adjacent to another!"))
				return ", can't be adjacent to another!"

	if(recipe.placement_checks & STACK_CHECK_ADJACENT)
		if(locate(recipe.result) in range(1, dest_turf))
			return ", can't be near another!"

	if(recipe.placement_checks & STACK_CHECK_TRAM_FORBIDDEN)
		if(locate(/obj/structure/transport/linear/tram) in dest_turf || locate(/obj/structure/thermoplastic) in dest_turf)
			return ", can't be on tram!"

	if(recipe.placement_checks & STACK_CHECK_TRAM_EXCLUSIVE)
		if(!locate(/obj/structure/transport/linear/tram) in dest_turf)
			return ", must be made on a tram!"

	if(check_tools_last && !check_tools(crafter, recipe, contents, TRUE))
		return ", missing tool."

/**
 * get_used_reqs works like this:
 * Loop over reqs var of the recipe
 * Set var amt to the value current cycle req is pointing to, its amount of type we need to delete
 * Get var/surroundings list of things accessable to crafting by get_environment()
 * Check the type of the current cycle req
 * * If its reagent then do a while loop, inside it try to locate() reagent containers, inside such containers try to locate needed reagent, if there isn't remove thing from surroundings
 * * * Transfer a quantity (The required amount of the contained quantity, whichever is lower) of the reagent to the temporary reagents holder
 *
 * * If it's a stack, create a tally stack and then transfer an amount of the stack to the stack until it reaches the required amount.
 *
 * * If it's anything else just locate() it in the list in a while loop, for each find reduce the amt var by 1 and put the found stuff in return list
 *
 * For stacks and items, the material composition is also tallied in total_materials, to be transferred to the result after that is spawned.
 *
 * get_used_reqs returns the list of used required object the result will receive as argument of atom/CheckParts()
 * If one or some of the object types is in the 'parts' list of the recipe, they will be stored inside the contents of the result
 * The rest will instead be deleted by atom/CheckParts()
**/

/datum/component/personal_crafting/proc/get_used_reqs(datum/crafting_recipe/recipe, atom/atom, list/total_materials = list())
	var/list/return_list = list()

	var/datum/reagents/holder
	var/list/requirements = list()
	if(recipe.reqs)
		requirements += recipe.reqs
	if(recipe.machinery)
		requirements += recipe.machinery
	if(recipe.structures)
		requirements += recipe.structures

	for(var/path_key in requirements)
		var/list/surroundings
		var/amount = recipe.reqs?[path_key] || recipe.machinery?[path_key] || recipe.structures?[path_key]
		if(!amount)//since machinery & structures can have 0 aka CRAFTING_MACHINERY_USE - i.e. use it, don't consume it!
			continue
		surroundings = get_environment(atom, recipe.blacklist)
		surroundings -= return_list
		if(ispath(path_key, /datum/reagent))
			if(!holder)
				holder = new(INFINITY, NO_REACT) //an infinite volume holder than can store reagents without reacting
				return_list += holder
			while(amount > 0)
				var/obj/item/reagent_containers/container = locate() in surroundings
				if(isnull(container)) //This would only happen if the previous checks for contents and tools were flawed.
					stack_trace("couldn't fulfill the required amount for [path_key]. Dangit")
				if(QDELING(container)) //it's deleting...
					surroundings -= container
					continue
				var/reagent_volume = container.reagents.get_reagent_amount(path_key)
				if(reagent_volume)
					container.reagents.trans_to(holder, min(amount, reagent_volume), target_id = path_key, no_react = TRUE)
					amount -= reagent_volume
				surroundings -= container
				container.update_appearance(UPDATE_ICON)
		else if(ispath(path_key, /obj/item/stack))
			var/obj/item/stack/tally_stack
			while(amount > 0)
				var/obj/item/stack/origin_stack = locate(path_key) in surroundings
				if(isnull(origin_stack)) //This would only happen if the previous checks for contents and tools were flawed.
					stack_trace("couldn't fulfill the required amount for [path_key]. Dangit")
				if(QDELING(origin_stack))
					continue
				var/amount_to_give = min(origin_stack.amount, amount)
				if(!tally_stack)
					tally_stack = origin_stack.split_stack(amount = amount_to_give)
					return_list += tally_stack
				else
					origin_stack.merge(tally_stack, amount_to_give)
				amount -= amount_to_give
				surroundings -= origin_stack
			if(!(path_key in recipe.requirements_mats_blacklist))
				for(var/material in tally_stack.custom_materials)
					total_materials[material] += tally_stack.custom_materials[material]
		else
			while(amount > 0)
				var/atom/movable/item = locate(path_key) in surroundings
				if(isnull(item)) //This would only happen if the previous checks for contents and tools were flawed.
					stack_trace("couldn't fulfill the required amount for [path_key]. Dangit")
				if(QDELING(item))
					continue
				return_list += item
				surroundings -= item
				amount--
				if(!(path_key in recipe.requirements_mats_blacklist))
					for(var/material in item.custom_materials)
						total_materials[material] += item.custom_materials[material]

	return return_list

/datum/component/personal_crafting/proc/is_recipe_available(datum/crafting_recipe/recipe, mob/user)
	if((recipe.crafting_flags & CRAFT_MUST_BE_LEARNED) && !(recipe.type in user?.mind?.learned_recipes)) //User doesn't actually know how to make this.
		return FALSE
	if (recipe.category == CAT_CULT && !IS_CULTIST(user)) // Skip blood cult recipes if not cultist
		return FALSE
	return TRUE

/datum/component/personal_crafting/proc/component_ui_interact(atom/movable/screen/craft/image, location, control, params, user)
	SIGNAL_HANDLER

	if(user == parent)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/personal_crafting/ui_state(mob/user)
	return GLOB.not_incapacitated_turf_state

//For the UI related things we're going to assume the user is a mob rather than typesetting it to an atom as the UI isn't generated if the parent is an atom
/datum/component/personal_crafting/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersonalCrafting", "Crafting")
		ui.open()

/datum/component/personal_crafting/ui_data(mob/user)
	var/list/data = list()
	data["busy"] = busy
	data["mode"] = mode
	data["display_craftable_only"] = display_craftable_only
	data["display_compact"] = display_compact

	var/list/surroundings = get_surroundings(user)
	var/list/craftability = list()
	for(var/datum/crafting_recipe/recipe as anything in (mode ? GLOB.cooking_recipes : GLOB.crafting_recipes))
		if(!is_recipe_available(recipe, user))
			continue
		if(check_contents(user, recipe, surroundings) && check_tools(user, recipe, surroundings))
			craftability["[REF(recipe)]"] = TRUE

	data["craftability"] = craftability
	return data

/datum/component/personal_crafting/ui_static_data(mob/user)
	var/list/data = list()
	var/list/material_occurences = list()

	data["forced_mode"] = forced_mode
	data["recipes"] = list()
	data["categories"] = list()
	data["foodtypes"] = FOOD_FLAGS

	if(user.has_dna())
		var/mob/living/carbon/carbon = user
		data["diet"] = carbon.dna.species.get_species_diet()

	for(var/datum/crafting_recipe/recipe as anything in (mode ? GLOB.cooking_recipes : GLOB.crafting_recipes))
		if(!is_recipe_available(recipe, user))
			continue

		if(recipe.category)
			data["categories"] |= recipe.category

		// Materials
		for(var/req in recipe.reqs)
			material_occurences[req] += 1
		for(var/req in recipe.chem_catalysts)
			material_occurences[req] += 1

		data["recipes"] += list(build_crafting_data(recipe))

	var/list/atoms = mode ? GLOB.cooking_recipes_atoms : GLOB.crafting_recipes_atoms

	// Prepare atom data

	//load sprite sheets and select the correct one based on the mode
	var/static/list/sprite_sheets
	if(isnull(sprite_sheets))
		sprite_sheets = ui_assets()
	var/datum/asset/spritesheet_batched/sheet = sprite_sheets[mode ? 2 : 1]

	data["icon_data"] = list()
	for(var/atom/atom as anything in atoms)
		var/atom_id = atoms.Find(atom)

		data["atom_data"] += list(list(
			"name" = initial(atom.name),
			"is_reagent" = ispath(atom, /datum/reagent/),
		))

		var/icon_size = sheet.icon_size_id("a[atom_id]")
		if(!endswith(icon_size, "32x32"))
			data["icon_data"]["[atom_id]"] = "[icon_size] a[atom_id]"

	// Prepare materials data
	for(var/atom/atom as anything in material_occurences)
		if(material_occurences[atom] == 1)
			continue // Don't include materials that appear only once
		var/id = atoms.Find(atom)
		data["material_occurences"] += list(list(
				"atom_id" = "[id]",
				"occurences" = material_occurences[atom]
			))

	return data

/datum/component/personal_crafting/proc/make_action(datum/crafting_recipe/recipe, mob/user)
	var/atom/result = construct_item(user, recipe)
	if(istext(result)) //We failed to make an item and got a fail message
		to_chat(user, span_warning("Construction failed[result]"))
		return FALSE
	if(ismob(user) && isitem(result)) //In case the user is actually possessing a non mob like a machine
		user.put_in_hands(result)
	else if(ismovable(result) && !istype(result, /obj/effect/spawner))
		var/atom/movable/movable = result
		movable.forceMove(user.drop_location())
	to_chat(user, span_notice("[recipe.name] crafted."))
	user.investigate_log("crafted [recipe]", INVESTIGATE_CRAFTING)
	return TRUE


/datum/component/personal_crafting/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("make", "make_mass")
			var/mob/user = usr
			var/datum/crafting_recipe/crafting_recipe = locate(params["recipe"]) in (mode ? GLOB.cooking_recipes : GLOB.crafting_recipes)
			busy = TRUE
			ui_interact(user)
			if(action == "make_mass")
				var/crafted_items = 0
				while(make_action(crafting_recipe, user))
					crafted_items++
				if(crafted_items)
					to_chat(user, span_notice("You made [crafted_items] item\s."))
			else
				make_action(crafting_recipe, user)
			busy = FALSE
		if("toggle_recipes")
			display_craftable_only = !display_craftable_only
			. = TRUE
		if("toggle_compact")
			display_compact = !display_compact
			. = TRUE
		if("toggle_mode")
			if(forced_mode)
				return
			mode = !mode
			var/mob/user = usr
			update_static_data(user)
			. = TRUE

/datum/component/personal_crafting/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/crafting),
		get_asset_datum(/datum/asset/spritesheet_batched/crafting/cooking),
	)

/datum/component/personal_crafting/proc/build_crafting_data(datum/crafting_recipe/recipe)
	var/list/data = list()
	var/list/atoms = mode ? GLOB.cooking_recipes_atoms : GLOB.crafting_recipes_atoms

	data["ref"] = "[REF(recipe)]"
	var/atom/atom = recipe.result

	data["id"] = atoms.Find(atom)

	var/recipe_data = recipe.crafting_ui_data()
	for(var/new_data in recipe_data)
		data[new_data] = recipe_data[new_data]

	// Category
	data["category"] = recipe.category

	// Name, Description
	data["name"] = recipe.name

	if(ispath(recipe.result, /datum/reagent))
		var/datum/reagent/reagent = recipe.result
		if(recipe.result_amount > 1)
			data["name"] = "[data["name"]] [recipe.result_amount]u"
		data["desc"] = recipe.desc || initial(reagent.description)

	else if(ispath(recipe.result, /obj/item/pipe))
		var/obj/item/pipe/pipe_obj = recipe.result
		var/obj/pipe_real = initial(pipe_obj.pipe_type)
		data["desc"] = recipe.desc || initial(pipe_real.desc)

	else
		if(ispath(recipe.result, /obj/item/stack) && recipe.result_amount > 1)
			data["name"] = "[data["name"]] [recipe.result_amount]x"
		data["desc"] = recipe.desc || initial(atom.desc)

	if(ispath(recipe.result, /obj/item/food))
		var/obj/item/food/food = recipe.result
		data["has_food_effect"] = !!food.crafted_food_buff

	// Crafting
	if(recipe.non_craftable)
		data["non_craftable"] = recipe.non_craftable
	data["mass_craftable"] = recipe.mass_craftable
	if(recipe.steps)
		data["steps"] = recipe.steps

	// Tools
	if(recipe.tool_behaviors)
		data["tool_behaviors"] = recipe.tool_behaviors
	if(recipe.tool_paths)
		data["tool_paths"] = list()
		for(var/req_atom in recipe.tool_paths)
			data["tool_paths"] += atoms.Find(req_atom)

	// Machinery
	if(recipe.machinery)
		data["machinery"] = list()
		for(var/req_atom in recipe.machinery)
			data["machinery"] += atoms.Find(req_atom)

	// Structures
	if(recipe.structures)
		data["structures"] = list()
		for(var/req_atom in recipe.structures)
			data["structures"] += atoms.Find(req_atom)

	// Ingredients / Materials
	if(recipe.reqs.len)
		data["reqs"] = list()
		for(var/req_atom in recipe.reqs)
			var/id = atoms.Find(req_atom)
			data["reqs"]["[id]"] = recipe.reqs[req_atom]

	// Catalysts
	if(recipe.chem_catalysts.len)
		data["chem_catalysts"] = list()
		for(var/req_atom in recipe.chem_catalysts)
			var/id = atoms.Find(req_atom)
			data["chem_catalysts"]["[id]"] = recipe.chem_catalysts[req_atom]

	// Reaction data
	if(ispath(recipe.reaction))
		data["is_reaction"] = TRUE
		// May be called before chemical reactions list is setup
		var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list[recipe.reaction] || new recipe.reaction()
		if(istype(reaction))
			if(!data["steps"])
				data["steps"] = list()
			if(reaction.required_container)
				var/id = atoms.Find(reaction.required_container)
				data["reqs"]["[id]"] = 1
				data["steps"] += "Add all ingredients into \a [initial(reaction.required_container.name)]"
			else if(length(recipe.reqs) > 1 || length(reaction.required_catalysts))
				data["steps"] += "Mix all ingredients together"
			if(reaction.required_temp > T20C)
				data["steps"] += "Heat up to [reaction.required_temp]K"
		else
			stack_trace("Invalid reaction found in recipe code! ([recipe.reaction])")
	else if(!isnull(recipe.reaction))
		stack_trace("Invalid reaction found in recipe code! ([recipe.reaction])")

	return data

#undef COOKING
#undef CRAFTING

//Mind helpers

/// proc that teaches user a non-standard crafting recipe
/datum/mind/proc/teach_crafting_recipe(recipe)
	if(!learned_recipes)
		learned_recipes = list()
	learned_recipes |= recipe

/// proc that makes user forget a specific crafting recipe
/datum/mind/proc/forget_crafting_recipe(recipe)
	learned_recipes -= recipe

/datum/mind/proc/has_crafting_recipe(mob/user, potential_recipe)
	if(!learned_recipes)
		return FALSE
	if(!ispath(potential_recipe, /datum/crafting_recipe))
		CRASH("Non-crafting recipe passed to has_crafting_recipe")
	for(var/recipe in user.mind.learned_recipes)
		if(recipe == potential_recipe)
			return TRUE
	return FALSE

/datum/component/personal_crafting/machine
	ignored_flags = CRAFT_CHECK_DENSITY|CRAFT_IGNORE_DO_AFTER

/datum/component/personal_crafting/machine/get_environment(atom/crafter, list/blacklist = null, radius_range = 1)
	. = list()
	var/turf/crafter_loc = get_turf(crafter)
	for(var/atom/movable/content as anything in crafter_loc.contents)
		if((content.flags_1 & HOLOGRAM_1) || (blacklist && (content.type in blacklist)))
			continue
		if(isitem(content))
			var/obj/item/item = content
			if(item.item_flags & ABSTRACT) //let's not tempt fate, shall we?
				continue
		. += content

/datum/component/personal_crafting/machine/check_tools(atom/source, datum/crafting_recipe/recipe, list/surroundings, final_check = FALSE)
	return TRUE

#undef CONTENTS_INSTANCES
#undef CONTENTS_MACHINERY
#undef CONTENTS_STRUCTURES
#undef CONTENTS_REQS_COUNT
#undef CONTENTS_TOOL_BEHAVIOUR
#undef RECIPE_DYNAMIC_TIME_COEFF
#undef CONTENTS_POSSIBLE_TOOLS
