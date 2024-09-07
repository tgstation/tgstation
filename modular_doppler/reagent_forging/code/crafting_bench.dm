/// How many planks of wood are required to complete a weapon?
#define WEAPON_COMPLETION_WOOD_AMOUNT 2

/// The number of hits you are set back when a bad hit is made
#define BAD_HIT_PENALTY 3

/obj/structure/reagent_crafting_bench
	name = "forging workbench"
	desc = "A crafting bench fitted with tools, securing mechanisms, and a steady surface for blacksmithing."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_structures.dmi'
	icon_state = "crafting_bench_empty"

	anchored = TRUE
	density = TRUE
	///whether the crafting is being hammered
	var/in_use = FALSE

	/// What the currently picked recipe is
	var/datum/crafting_bench_recipe/selected_recipe
	/// How many successful hits towards completion of the item have we done
	var/current_hits_to_completion = 0
	/// Is this bench able to complete forging items? Exists to allow non-forging workbenches to exist
	var/finishes_forging_weapons = TRUE
	/// The cooldown from the last hit before we allow another 'good hit' to happen
	COOLDOWN_DECLARE(hit_cooldown)
	/// What recipes are we allowed to choose from?
	var/list/allowed_choices = list(
		/datum/crafting_bench_recipe/plate_helmet,
		/datum/crafting_bench_recipe/plate_vest,
		/datum/crafting_bench_recipe/plate_gloves,
		/datum/crafting_bench_recipe/plate_boots,
		/datum/crafting_bench_recipe/ring,
		// /datum/crafting_bench_recipe/collar,
		/datum/crafting_bench_recipe/handcuffs,
		/datum/crafting_bench_recipe/pavise,
		/datum/crafting_bench_recipe/buckler,
		/datum/crafting_bench_recipe/seed_mesh,
		/datum/crafting_bench_recipe/centrifuge,
		/datum/crafting_bench_recipe/soup_pot,
		/datum/crafting_bench_recipe/bokken,
		/datum/crafting_bench_recipe/bow,
	)
	/// Radial options for recipes in the allowed_choices list, populated by populate_radial_choice_list
	var/list/radial_choice_list = list()
	/// An associative list of names --> recipe path that the radial recipe picker will choose from later
	var/list/recipe_names_to_path = list()

/obj/structure/reagent_crafting_bench/Initialize(mapload)
	. = ..()
	populate_radial_choice_list()

/obj/structure/reagent_crafting_bench/proc/populate_radial_choice_list()
	if(!length(allowed_choices))
		return

	if(length(radial_choice_list) && length(recipe_names_to_path)) // We already have both of these and don't need it, if this is called after these are generated for some reason
		return

	for(var/recipe in allowed_choices)
		var/datum/crafting_bench_recipe/recipe_to_take_from = new recipe()
		var/obj/recipe_resulting_item = recipe_to_take_from.resulting_item
		radial_choice_list[recipe_to_take_from.recipe_name] = image(icon = initial(recipe_resulting_item.icon), icon_state = initial(recipe_resulting_item.icon_state))
		recipe_names_to_path[recipe_to_take_from.recipe_name] = recipe
		qdel(recipe_to_take_from)


/obj/structure/reagent_crafting_bench/examine(mob/user)
	. = ..()

	if(length(contents))
		if(istype(contents[1], /obj/item/forging/complete))
			var/obj/item/forging/complete/contained_forge_item = contents[1]

			. += span_notice("[src] has a <b>[initial(contained_forge_item.name)]</b> sitting on it, awaiting completion. <br>")
			var/obj/item/completion_item = contained_forge_item.spawning_item
			. += span_notice("With <b>[WEAPON_COMPLETION_WOOD_AMOUNT]</b> sheets of <b>wood</b> nearby, and some <b>hammering</b>, it could be completed into a <b>[initial(completion_item.name)]</b>.")
			return // We don't want to show any selected recipes if there's weapon head on the bench

	if(!selected_recipe)
		return

	var/obj/resulting_item = selected_recipe.resulting_item
	. += span_notice("The selected recipe's resulting item is: <b>[initial(resulting_item.name)]</b> <br>")
	. += span_notice("Gather the required materials, listed below, <b>near the bench</b>, then start <b>hammering</b> to complete it! <br>")

	if(!length(selected_recipe.recipe_requirements))
		. += span_boldwarning("Somehow, this recipe has no requirements, report this as this shouldn't happen.")
		return

	for(var/obj/requirement_item as anything in selected_recipe.recipe_requirements)
		if(!selected_recipe.recipe_requirements[requirement_item])
			. += span_boldwarning("[requirement_item] does not have an amount required set, this should not happen, report it.")
			continue

		. += span_notice("<b>[selected_recipe.recipe_requirements[requirement_item]]</b> - [initial(requirement_item.name)]")

	return .

/obj/structure/reagent_crafting_bench/update_appearance(updates)
	. = ..()
	cut_overlays()

	if(!length(contents))
		return

	var/image/overlayed_item = image(icon = contents[1].icon, icon_state = contents[1].icon_state)
	add_overlay(overlayed_item)

/obj/structure/reagent_crafting_bench/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(in_use)
		balloon_alert(user, "already in use")
		return

	update_appearance()

	if(length(contents))
		var/obj/item/contained_item = contents[1]
		user.put_in_hands(contained_item)
		balloon_alert(user, "[contained_item] retrieved")
		update_appearance()
		return

	if(selected_recipe)
		clear_recipe()
		balloon_alert_to_viewers("recipe cleared")
		update_appearance()
		return

	var/chosen_recipe = show_radial_menu(user, src, radial_choice_list, radius = 38, require_near = TRUE, tooltips = TRUE)

	if(!chosen_recipe)
		balloon_alert(user, "no recipe choice")
		return

	var/datum/crafting_bench_recipe/recipe_to_use = recipe_names_to_path[chosen_recipe]
	selected_recipe = new recipe_to_use

	balloon_alert(user, "recipe chosen")
	update_appearance()

/// Clears the current recipe and sets hits to completion to zero
/obj/structure/reagent_crafting_bench/proc/clear_recipe()
	QDEL_NULL(selected_recipe)
	current_hits_to_completion = 0

/obj/structure/reagent_crafting_bench/attackby(obj/item/attacking_item, mob/user, params)
	if(in_use)
		balloon_alert(user, "already in use")
		return

	if(istype(attacking_item, /obj/item/forging/complete))
		if(length(contents))
			balloon_alert(user, "already full")
			return TRUE

		attacking_item.forceMove(src)
		balloon_alert_to_viewers("placed [attacking_item]")
		update_appearance()
		return TRUE

	return ..()

/obj/structure/reagent_crafting_bench/wrench_act(mob/living/user, obj/item/tool)
	if(in_use)
		balloon_alert(user, "it's currently in use!")
		return

	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return

	deconstruct(disassembled = TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_crafting_bench/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)

/obj/structure/reagent_crafting_bench/hammer_act(mob/living/user, obj/item/tool)
	if(in_use)
		balloon_alert(user, "already in use")
		return ITEM_INTERACT_SUCCESS

	if(length(contents))
		if(!istype(contents[1], /obj/item/forging/complete))
			balloon_alert(user, "invalid item")
			return ITEM_INTERACT_SUCCESS

		var/obj/item/forging/complete/weapon_to_finish = contents[1]

		if(!weapon_to_finish.spawning_item)
			balloon_alert(user, "[weapon_to_finish] cannot be completed")
			return ITEM_INTERACT_SUCCESS

		var/list/wood_required_for_weapons = list(
			/obj/item/stack/sheet/mineral/wood = WEAPON_COMPLETION_WOOD_AMOUNT,
		)

		if(!can_we_craft_this(wood_required_for_weapons))
			balloon_alert(user, "not enough wood")
			return ITEM_INTERACT_SUCCESS

		var/list/things_to_use = can_we_craft_this(wood_required_for_weapons, TRUE)
		var/obj/thing_just_made = create_thing_from_requirements(things_to_use, user = user, skill_to_grant = /datum/skill/smithing, skill_amount = 30, completing_a_weapon = TRUE)

		if(!thing_just_made)
			message_admins("[src] just tried to finish a weapon but somehow created nothing! This is not working as intended!")
			return ITEM_INTERACT_SUCCESS

		playsound(src, 'modular_doppler/reagent_forging/sound/forge.ogg', 50, TRUE)

		balloon_alert_to_viewers("[thing_just_made] created")
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(!selected_recipe)
		balloon_alert(user, "no recipe selected")
		return ITEM_INTERACT_SUCCESS

	if(!can_we_craft_this(selected_recipe.recipe_requirements))
		balloon_alert(user, "missing ingredients")
		return ITEM_INTERACT_SUCCESS

	in_use = TRUE
	do_hammer(user, selected_recipe, current_hits_to_completion)
	in_use = FALSE
	var/list/things_to_use = can_we_craft_this(selected_recipe.recipe_requirements, TRUE)
	create_thing_from_requirements(things_to_use, selected_recipe, user, selected_recipe.relevant_skill, selected_recipe.relevant_skill_reward)
	return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_crafting_bench/proc/do_hammer(mob/living/user, datum/crafting_bench_recipe/selected_recipe, current_hits_to_completion)
	while(current_hits_to_completion < selected_recipe.required_good_hits)
		var/skill_modifier = user.mind.get_skill_modifier(selected_recipe.relevant_skill, SKILL_SPEED_MODIFIER) * 1 SECONDS

		if(!do_after(user, skill_modifier, src))
			balloon_alert(user, "stopped hammering")
			in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		if(!can_we_craft_this(selected_recipe.recipe_requirements))
			balloon_alert(user, "missing ingredients")
			in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		playsound(src, 'modular_doppler/reagent_forging/sound/forge.ogg', 50, TRUE)
		current_hits_to_completion++
		user.mind.adjust_experience(selected_recipe.relevant_skill, selected_recipe.relevant_skill_reward / 15)

/// Takes the given list of item requirements and checks the surroundings for them, returns TRUE unless return_ingredients_list is set, in which case a list of all the items to use is returned
/obj/structure/reagent_crafting_bench/proc/can_we_craft_this(list/required_items, return_ingredients_list = FALSE)
	if(!length(required_items))
		message_admins("[src] just tried to check for ingredients nearby without having a list of items to check for!")
		return FALSE

	var/list/surrounding_items = list()
	var/list/requirement_items = list()

	for(var/obj/item/potential_requirement in get_environment())
		surrounding_items += potential_requirement

	for(var/obj/item/requirement_path as anything in required_items)
		var/required_amount = required_items[requirement_path]

		for(var/obj/item/nearby_item as anything in surrounding_items)
			if(!istype(nearby_item, requirement_path))
				continue

			if(isstack(nearby_item)) // If the item is a stack, check if that stack has enough material in it to fill out the amount
				var/obj/item/stack/nearby_stack = nearby_item
				if(required_amount > 0)
					requirement_items += nearby_item
				required_amount -= nearby_stack.amount
			else // Otherwise, we still exist and should subtract one from the required number of items
				if(required_amount > 0)
					requirement_items += nearby_item
				required_amount -= 1

		if(required_amount > 0)
			return FALSE

	if(return_ingredients_list)
		return requirement_items
	else
		return TRUE

/// Passes the list of found ingredients + the recipe to use_or_delete_recipe_requirements, then spawns the given recipe's result
/obj/structure/reagent_crafting_bench/proc/create_thing_from_requirements(list/things_to_use, datum/crafting_bench_recipe/recipe_to_follow, mob/living/user, datum/skill/skill_to_grant, skill_amount, completing_a_weapon)

	if(!recipe_to_follow && !completing_a_weapon)
		message_admins("[src] just tried to complete a recipe without having a recipe, and without it being the completion of a forging weapon!")
		return FALSE

	if(completing_a_weapon && (!length(contents) || !istype(contents[1], /obj/item/forging/complete)))
		message_admins("[src] just tried to complete a forge weapon without there being a weapon head inside it to complete!")
		return FALSE

	if(!length(things_to_use))
		message_admins("[src] just tried to craft something from requirements, but was not given a list of requirements!")
		return FALSE

	if(completing_a_weapon)
		recipe_to_follow = new /datum/crafting_bench_recipe/weapon_completion_recipe

	var/materials_to_transfer = list()
	var/list/temporary_materials_list = use_or_delete_recipe_requirements(things_to_use, recipe_to_follow)
	for(var/material as anything in temporary_materials_list)
		materials_to_transfer[material] += temporary_materials_list[material]

	var/obj/newly_created_thing

	if(completing_a_weapon)
		var/obj/item/forging/complete/completed_forge_item = contents[1]
		newly_created_thing = new completed_forge_item.spawning_item(src)
		if(completed_forge_item.custom_materials) // We need to add the weapon head's materials to the completed item, too
			for(var/custom_material in completed_forge_item.custom_materials)
				materials_to_transfer[custom_material] += completed_forge_item.custom_materials[custom_material]
		qdel(completed_forge_item) // And then we also need to 'use' the item

	else
		newly_created_thing = new recipe_to_follow.resulting_item(src)

	if(!newly_created_thing)
		message_admins("[src] just failed to create something while crafting!")
		return FALSE

	if(recipe_to_follow.transfers_materials)
		newly_created_thing.set_custom_materials(materials_to_transfer, multiplier = 1)

	user.mind.adjust_experience(skill_to_grant, skill_amount)

	clear_recipe()
	update_appearance()
	return newly_created_thing

/// Takes the given list, things_to_use, compares it to recipe_to_follow's requirements, then either uses items from a stack, or deletes them otherwise. Returns custom material of forge items in the end.
/obj/structure/reagent_crafting_bench/proc/use_or_delete_recipe_requirements(list/things_to_use, datum/crafting_bench_recipe/recipe_to_follow)
	var/list/materials_to_transfer = list()

	for(var/obj/requirement_item as anything in things_to_use)
		if(isstack(requirement_item))
			var/stack_type
			for(var/recipe_thing_to_reference as anything in recipe_to_follow.recipe_requirements)
				if(!istype(requirement_item, recipe_thing_to_reference))
					continue
				stack_type = recipe_thing_to_reference
				break

			var/obj/item/stack/requirement_stack = requirement_item

			if(requirement_stack.amount < recipe_to_follow.recipe_requirements[stack_type])
				recipe_to_follow.recipe_requirements[stack_type] -= requirement_stack.amount
				requirement_stack.use(requirement_stack.amount)
				continue

			requirement_stack.use(recipe_to_follow.recipe_requirements[stack_type])

		else if(istype(requirement_item, /obj/item/forging/complete))
			if(!requirement_item.custom_materials || !recipe_to_follow.transfers_materials)
				qdel(requirement_item)
				continue

			for(var/custom_material as anything in requirement_item.custom_materials)
				materials_to_transfer += custom_material
			qdel(requirement_item)

		else
			qdel(requirement_item)

	return materials_to_transfer

/// Gets movable atoms within one tile of range of the crafting bench
/obj/structure/reagent_crafting_bench/proc/get_environment()
	. = list()

	if(!get_turf(src))
		return

	for(var/atom/movable/found_movable_atom in range(1, src))
		if((found_movable_atom.flags_1 & HOLOGRAM_1))
			continue
		. += found_movable_atom
	return .

#undef WEAPON_COMPLETION_WOOD_AMOUNT
