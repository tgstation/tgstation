/// Atoms that can be microwaved from one type to another.
/datum/element/microwavable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The typepath we default to if we were passed no microwave result
	var/atom/default_typepath = /obj/item/food/badrecipe
	/// Resulting atom typepath on a completed microwave.
	var/atom/result_typepath
	/// Reagents that should be added to the result
	var/list/added_reagents

/datum/element/microwavable/Attach(datum/target, microwave_type, list/reagents)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	result_typepath = microwave_type || default_typepath

	added_reagents = reagents

	RegisterSignal(target, COMSIG_ITEM_MICROWAVE_ACT, PROC_REF(on_microwaved))

	if(!ispath(result_typepath, default_typepath))
		RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

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

	var/efficiency = istype(used_microwave) ? used_microwave.efficiency : 1
	SEND_SIGNAL(result, COMSIG_ITEM_MICROWAVE_COOKED, source, efficiency)
	SEND_SIGNAL(source, COMSIG_ITEM_MICROWAVE_COOKED_FROM, result, efficiency)

	if(IS_EDIBLE(result) && (result_typepath != default_typepath))
		BLACKBOX_LOG_FOOD_MADE(result.type)
		result.reagents.clear_reagents()
		source.reagents?.trans_to(result, source.reagents.total_volume)
		if(added_reagents) // Add any new reagents that should be added
			result.reagents.add_reagent_list(added_reagents)

		if(microwaver && microwaver.mind)
			ADD_TRAIT(result, TRAIT_FOOD_CHEF_MADE, REF(microwaver.mind))

	qdel(source)

	var/recipe_result = COMPONENT_MICROWAVE_SUCCESS
	if(istype(result, default_typepath))
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
