/// An element for girders, wall barricades, etc. that makes them use wall construction recipes.
/// Only really meant for recipes where you click on the girder with a stack of materials to make a wall.
/datum/element/uses_girder_wall_recipes

/datum/element/uses_girder_wall_recipes/Attach(datum/target)
	. = ..()
	if (!isstructure(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignals(target, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY), PROC_REF(on_item_interaction))

/datum/element/uses_girder_wall_recipes/Detach(datum/target, ...)
	UnregisterSignal(target, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY))
	return ..()

/datum/element/uses_girder_wall_recipes/proc/on_item_interaction(obj/structure/structure, mob/living/user, obj/item/stack/stack, list/modifiers)
	SIGNAL_HANDLER
	if (!isstack(stack))
		return NONE
	if (!stack.usable_for_construction)
		structure.balloon_alert(user, "unusable material!")
		return ITEM_INTERACT_BLOCKING

	var/datum/girder_wall_recipe/main_recipe = get_main_recipe(structure, stack)

	if (main_recipe)
		INVOKE_ASYNC(src, PROC_REF(attempt_recipe), structure, user, stack, main_recipe, is_material_recipe = FALSE)
		return ITEM_INTERACT_BLOCKING

	if (stack.has_unique_girder)
		structure.balloon_alert(user, "needs a different girder!")
		return ITEM_INTERACT_BLOCKING

	// Plasteel is used for reinforcing girders.
	if (istype(structure, /obj/structure/girder) && istype(stack, /obj/item/stack/sheet/plasteel))
		return NONE

	var/datum/girder_wall_recipe/material_recipe = get_material_recipe(structure, stack)

	if (material_recipe)
		INVOKE_ASYNC(src, PROC_REF(attempt_recipe), structure, user, stack, material_recipe, is_material_recipe = TRUE)
		return ITEM_INTERACT_BLOCKING

/// Returns the main wall recipe of the stack for the structure, if any.
/datum/element/uses_girder_wall_recipes/proc/get_main_recipe(obj/structure/structure, obj/item/stack/stack)
	for (var/datum/girder_wall_recipe/recipe as anything in GLOB.main_girder_wall_recipes)
		if (!istype(stack, recipe.stack_type))
			continue
		if (!istype(structure, recipe.girder_type))
			continue
		if (!check_girder_state(structure, recipe))
			continue
		return recipe

/// Returns the material wall recipe of the stack for the structure, if any.
/datum/element/uses_girder_wall_recipes/proc/get_material_recipe(obj/structure/structure, obj/item/stack/stack)
	for (var/datum/girder_wall_recipe/recipe as anything in GLOB.material_girder_wall_recipes)
		if (!istype(structure, recipe.girder_type))
			continue
		if (!check_girder_state(structure, recipe))
			continue
		return recipe

/// Has the user attempt the wall recipe asynchronously.
/// Assumes that the structure and stack are of valid types for the recipe.
/datum/element/uses_girder_wall_recipes/proc/attempt_recipe_async(obj/structure/structure, mob/living/user, obj/item/stack/stack, datum/girder_wall_recipe/recipe, is_material_recipe)
	INVOKE_ASYNC(src, PROC_REF(attempt_recipe), structure, user, stack, recipe, is_material_recipe)

/// Has the user attempt the wall recipe.
/// Assumes that the structure and stack are of valid types for the recipe.
/datum/element/uses_girder_wall_recipes/proc/attempt_recipe(obj/structure/structure, mob/living/user, obj/item/stack/stack, datum/girder_wall_recipe/recipe, is_material_recipe)
	if (!check_recipe(structure, user, recipe))
		return
	if (!stack.tool_start_check(user, recipe.stack_amount))
		return

	user.visible_message(
		message = span_notice("\The [user] start[user.p_s()] building a wall on \the [structure]."),
		self_message = span_notice("You start building a wall on \the [structure]."),
		blind_message = span_hear("You hear a series of clangs."),
	)

	structure.add_fingerprint(user)
	stack.add_fingerprint(user)

	if (!stack.use_tool(structure, user, recipe.make_delay, recipe.stack_amount, extra_checks = CALLBACK(src, PROC_REF(check_recipe), structure, user, recipe)))
		return

	var/atom/wall
	if (ispath(recipe.wall_type, /turf))
		var/turf/structure_turf = get_turf(structure)
		wall = structure_turf.place_on_top(recipe.wall_type)
	else if (ispath(recipe.wall_type, /obj))
		wall = new recipe.wall_type(structure.drop_location())
	else
		CRASH("Attempted a girder wall recipe with an invalid wall type ([recipe.wall_type])")

	user.visible_message(
		message = span_notice("\The [user] finish[user.p_es()] building \a [wall] on \the [structure]."),
		self_message = span_notice("You finish building \a [wall] on \the [structure]."),
	)

	structure.transfer_fingerprints_to(wall)
	qdel(structure)

	if (is_material_recipe)
		wall.set_custom_materials(stack.mats_per_unit, recipe.stack_amount)

/// Checks if the user can do the wall recipe.
/datum/element/uses_girder_wall_recipes/proc/check_recipe(obj/structure/structure, mob/living/user, datum/girder_wall_recipe/recipe)
	if(iswallturf(structure.loc) || (locate(/obj/structure/falsewall) in structure.loc.contents))
		structure.balloon_alert(user, "wall already present!")
		return FALSE
	if (!ispath(recipe.wall_type, /obj/structure/tram))
		if (!isfloorturf(structure.loc))
			structure.balloon_alert(user, "need floor!")
			return FALSE
	else if (!(locate(/obj/structure/transport/linear/tram) in structure.loc.contents))
		structure.balloon_alert(user, "need tram floor!")
		return FALSE
	if (!check_girder_state(structure, recipe))
		return FALSE
	return TRUE

/// Checks if the girder state of the structure matches the required girder state of the wall recipe.
/datum/element/uses_girder_wall_recipes/proc/check_girder_state(obj/structure/structure, datum/girder_wall_recipe/recipe)
	if (istype(structure, /obj/structure/girder))
		var/obj/structure/girder/girder = structure
		if (girder.state != recipe.girder_state)
			return FALSE
	return TRUE
