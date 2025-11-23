/// Atoms that can be microwaved from one type to another.
/datum/element/microwavable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Resulting atom typepath on a completed microwave.
	var/atom/result_typepath
	/// Reagents that should be added to the result
	var/list/added_reagents
	/// Whether this is a bad recipe or not. It affects some checks.
	var/bad_recipe

/datum/element/microwavable/Attach(obj/item/target, microwave_type, list/reagents, bad_recipe = FALSE)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	if(!microwave_type)
		CRASH("microwavable element attached without a microwave_type arg")

	result_typepath = microwave_type
	added_reagents = reagents
	src.bad_recipe = bad_recipe

	RegisterSignal(target, COMSIG_ITEM_MICROWAVE_ACT, PROC_REF(on_microwaved))

	if(!bad_recipe)
		RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	if(!PERFORM_ALL_TESTS(focus_only/check_materials_when_processed) || bad_recipe || !target.custom_materials || isstack(target))
		return

	var/atom/result = new result_typepath
	if(!target.compare_materials(result))
		var/warning = "custom_materials of [result.type] when microwaved compared to just spawned don't match"
		var/what_it_should_be = target.get_materials_english_list()
		stack_trace("[warning]. custom_materials should be [what_it_should_be].")
	qdel(result)

/datum/element/microwavable/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ITEM_MICROWAVE_ACT, COMSIG_ATOM_EXAMINE))
	return ..()

/**
 * Signal proc for [COMSIG_ITEM_MICROWAVE_ACT].
 * Handles the actual microwaving part.
 */
/datum/element/microwavable/proc/on_microwaved(atom/source, obj/machinery/microwave/used_microwave, mob/microwaver, randomize_pixel_offset)
	SIGNAL_HANDLER

	var/atom/result
	var/turf/result_loc = get_turf(used_microwave || source)
	if(isstack(source))
		var/obj/item/stack/stack_source = source
		result = new result_typepath(result_loc, stack_source.amount)
	else
		result = new result_typepath(result_loc)
		result.set_custom_materials(source.custom_materials)

	var/efficiency = istype(used_microwave) ? used_microwave.efficiency : 1

	if(IS_EDIBLE(result) && !bad_recipe)
		BLACKBOX_LOG_FOOD_MADE(result.type)

		if(istype(source, /obj/item/food) && istype(result, /obj/item/food))
			var/obj/item/food/original_food = source
			var/obj/item/food/microwaved_food = result
			LAZYADD(microwaved_food.intrinsic_food_materials, original_food.intrinsic_food_materials)

		if(microwaver && microwaver.mind)
			ADD_TRAIT(result, TRAIT_FOOD_CHEF_MADE, REF(microwaver.mind))

	//make space and tranfer reagents if it has any, also let any bad result handle removing or converting the transferred reagents on its own terms
	if(result.reagents && source.reagents)
		result.reagents.clear_reagents()
		source.reagents.trans_to(result, source.reagents.total_volume)
		if(added_reagents) // Add any new reagents that should be added
			result.reagents.add_reagent_list(added_reagents)

	SEND_SIGNAL(result, COMSIG_ITEM_MICROWAVE_COOKED, source, efficiency)
	SEND_SIGNAL(source, COMSIG_ITEM_MICROWAVE_COOKED_FROM, result, efficiency)

	qdel(source)

	var/recipe_result = COMPONENT_MICROWAVE_SUCCESS
	if(bad_recipe)
		recipe_result |= COMPONENT_MICROWAVE_BAD_RECIPE

	if(randomize_pixel_offset && isitem(result))
		var/obj/item/result_item = result
		if(!(result_item.item_flags & NO_PIXEL_RANDOM_DROP))
			result_item.pixel_x = result_item.base_pixel_x + rand(-6, 6)
			result_item.pixel_y = result_item.base_pixel_y + rand(-5, 6)

	return recipe_result

/**
 * Signal proc for [COMSIG_ATOM_EXAMINE].
 * Lets examiners know we can be microwaved if we're not the default mess type
 */
/datum/element/microwavable/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(initial(result_typepath.gender) == PLURAL)
		examine_list += span_notice("[source] can be [span_bold("microwaved")] into some [initial(result_typepath.name)].")
	else
		examine_list += span_notice("[source] can be [span_bold("microwaved")] into \a [initial(result_typepath.name)].")
