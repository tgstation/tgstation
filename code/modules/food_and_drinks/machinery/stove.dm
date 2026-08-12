/obj/machinery/stove
	name = "stove"
	desc = "You'd think this thing would be more useful in here."
	icon = 'icons/obj/machines/kitchen_stove.dmi'
	icon_state = "stove"
	base_icon_state = "stove"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/stove
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.1
	active_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.8

	// Stove icon is 32x48, we'll use a Range for preview instead
	icon_preview = 'icons/obj/machines/kitchen.dmi'
	icon_state_preview = "range_off"

/obj/machinery/stove/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stove, container_x = -6, container_y = 16)

// Soup pot for cooking soup
// Future addention ideas:
// - Thermostat you can stick in the pot to see in examine the temperature
// - Tasting the pot to learn its exact contents w/o sci goggles (chef skillchip?)
/obj/item/reagent_containers/cup/soup_pot
	name = "soup pot"
	desc = "A tall pot designed to mix and cook all kinds of soup."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "pot"
	base_icon_state = "pot"
	volume = 200
	possible_transfer_amounts = list(20, 50, 100, 200)
	amount_per_transfer_from_this = 50
	initial_reagent_flags = REFILLABLE | DRAINABLE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5)
	w_class = WEIGHT_CLASS_BULKY
	custom_price = PAYCHECK_LOWER * 8
	fill_icon_thresholds = null
	sound_vary = TRUE
	pickup_sound = SFX_POT_PICKUP
	drop_sound = SFX_POT_DROP

	/// Max number of ingredients we can add
	var/max_ingredients = 24
	/// A lazylist of all the ingredients we have added
	var/list/obj/item/added_ingredients

/obj/item/reagent_containers/cup/soup_pot/Initialize(mapload, vol)
	. = ..()
	AddElement(/datum/element/cuffable_item)
	RegisterSignal(src, COMSIG_ATOM_REAGENT_EXAMINE, PROC_REF(reagent_special_examine))

/obj/item/reagent_containers/cup/soup_pot/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Remove ingredient"
		return CONTEXTUAL_SCREENTIP_SET

	else if(can_add_ingredient(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Add ingredient"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/reagent_containers/cup/soup_pot/examine(mob/user)
	. = ..()
	. += span_notice("There's room for <b>[max_ingredients - LAZYLEN(added_ingredients)]</b> more ingredients \
		or <b>[reagents.maximum_volume - reagents.total_volume]</b> more units of reagents in there.")

/**
 * Override standard reagent examine with something a bit more sensible for the soup pot,
 * including the ingredients we have within as well
 */
/obj/item/reagent_containers/cup/soup_pot/proc/reagent_special_examine(datum/source, mob/user, list/examine_list, can_see_insides = FALSE)
	SIGNAL_HANDLER

	examine_list += "Inside, you can see:"

	if(LAZYLEN(added_ingredients) || reagents.total_volume > 0)
		var/list/ingredient_amounts = list()
		for(var/obj/item/ingredient as anything in added_ingredients)
			ingredient_amounts[ingredient.type] += 1

		for(var/obj/item/ingredient_type as anything in ingredient_amounts)
			examine_list += "&bull; [ingredient_amounts[ingredient_type]] [initial(ingredient_type.name)]\s"

		var/unknown_volume = 0
		for(var/datum/reagent/current_reagent as anything in reagents.reagent_list)
			if(can_see_insides \
				|| istype(current_reagent, /datum/reagent/water) \
				|| istype(current_reagent, /datum/reagent/consumable) \
			)
				examine_list += "&bull; [round(current_reagent.volume, 0.01)] units of [current_reagent.name]"
			else
				unknown_volume += current_reagent.volume

		if(unknown_volume > 0)
			examine_list += "&bull; [round(unknown_volume, 0.01)] units of unknown reagents"

		if(reagents.total_volume > 0)
			if(can_see_insides)
				examine_list += span_notice("The contents of [src] have a temperature of [reagents.chem_temp]K.")
			else if(reagents.chem_temp > WATER_BOILING_POINT) // boiling point
				examine_list += span_notice("The contents of [src] are boiling.")

	else
		examine_list += "Nothing."

	if(reagents.is_reacting)
		examine_list += span_warning("It is currently mixing!")

	return STOP_GENERIC_REAGENT_EXAMINE

/obj/item/reagent_containers/cup/soup_pot/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(added_ingredients, gone)

/**
 * Adds items to a soup pot without invoking any procs that call sleep() when using in a component.
 *
 * Args:
 * * transfer_from: The container that's being used to add items to the soup pot. Must not be null.
 * * user: the entity adding ingredients via a container to a soup pot. Must not be null.
 */
/obj/item/reagent_containers/cup/soup_pot/proc/transfer_from_container_to_pot(obj/item/transfer_from, mob/user)
	if(!transfer_from.atom_storage)
		return

	var/obj/item/storage/tray = transfer_from
	var/loaded = 0

	for(var/obj/tray_item in tray.contents)
		if(!can_add_ingredient(tray_item))
			continue
		if(LAZYLEN(added_ingredients) >= max_ingredients)
			balloon_alert(user, "it's full!")
			return TRUE
		if(tray.atom_storage.attempt_remove(tray_item, src))
			loaded++
			LAZYADD(added_ingredients, tray_item)
	if(loaded)
		to_chat(user, span_notice("You insert [loaded] items into \the [src]."))
		update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/reagent_containers/cup/soup_pot/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(item.is_open_container())
		// (assuming they want to pour rather than add the container itself)
		// allow interaction to fall through to reagent container coed
		return NONE
	if(!can_add_ingredient(item))
		return ITEM_INTERACT_BLOCKING

	// Too many ingredients
	if(LAZYLEN(added_ingredients) >= max_ingredients)
		balloon_alert(user, "too many ingredients!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(item, src))
		balloon_alert(user, "can't add that!")
		return ITEM_INTERACT_BLOCKING

	// Ensures that faceatom works correctly, since we can can often be in another atom's loc (a stove)
	var/atom/movable/balloon_loc = ismovable(loc) ? loc : src
	balloon_loc.balloon_alert(user, "ingredient added")
	user.face_atom(balloon_loc)

	LAZYADD(added_ingredients, item)
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/cup/soup_pot/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	return transfer_from_container_to_pot(tool, user)

/obj/item/reagent_containers/cup/soup_pot/attack_hand_secondary(mob/user, list/modifiers)
	if(!LAZYLEN(added_ingredients))
		return SECONDARY_ATTACK_CALL_NORMAL

	var/obj/item/removed = added_ingredients[1]
	removed.forceMove(get_turf(src))
	user.put_in_hands(removed)

	// Ensures that faceatom works correctly, since we can can often be in another atom's loc (a stove)
	var/atom/movable/balloon_loc = ismovable(loc) ? loc : src
	balloon_loc.balloon_alert(user, "ingredient removed")
	user.face_atom(balloon_loc)

	update_appearance(UPDATE_OVERLAYS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/reagent_containers/cup/soup_pot/proc/can_add_ingredient(obj/item/ingredient)
	// Let default reagent handling take this
	if(ingredient.is_open_container())
		return FALSE
	// To big for the pot
	if(ingredient.w_class >= WEIGHT_CLASS_BULKY)
		return FALSE
	if(ingredient.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
		return FALSE
	if(HAS_TRAIT(ingredient, TRAIT_NO_STORAGE_INSERT))
		return FALSE
	return TRUE

/obj/item/reagent_containers/cup/soup_pot/try_splash(mob/user, atom/target)
	. = ..()
	if(!. && LAZYLEN(added_ingredients))
		dump_ingredients()

/obj/item/reagent_containers/cup/soup_pot/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash)
	. = ..()
	if(!. && LAZYLEN(added_ingredients))
		dump_ingredients()

/**
 * Dumps all inside ingredients to a spot
 *
 * * drop_loc - Where to drop the ingredients, defaults to drop loc
 * * x_offset - How much pixel X offset to give every ingredient, if not set will be random
 * * y_offset - How much pixel Y offset to give every ingredient, if not set will be random
 */
/obj/item/reagent_containers/cup/soup_pot/proc/dump_ingredients(atom/drop_loc = drop_location(), x_offset, y_offset)
	for(var/obj/item/ingredient as anything in added_ingredients)
		ingredient.forceMove(drop_loc)
		ingredient.pixel_x += (isnum(x_offset) ? x_offset : rand(-4, 4))
		ingredient.pixel_y += (isnum(y_offset) ? x_offset : rand(-4, 4))
		ingredient.SpinAnimation(loops = 1)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/cup/soup_pot/update_overlays()
	. = ..()
	if(length(added_ingredients) <= 0 && reagents.total_volume <= 0)
		return
	var/mutable_appearance/filled_overlay = mutable_appearance(icon, "[base_icon_state]_filling_overlay")
	var/list/food_reagents = list()
	for(var/obj/item/ingredient as anything in added_ingredients)
		if(isnull(ingredient.reagents))
			continue
		food_reagents |= ingredient.reagents.reagent_list

	filled_overlay.color = mix_color_from_reagents(reagents.reagent_list + food_reagents)
	. += filled_overlay


/obj/item/frying_pan
	name = "frying pan"
	desc = "A nice pan for all your frying needs. Sizzle sizzle."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "frying_pan"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5)
	custom_price = PAYCHECK_LOWER * 8
	sound_vary = TRUE
	pickup_sound = SFX_POT_PICKUP
	drop_sound = SFX_POT_DROP

	force = 13

	///How many things fit on this pan?
	var/max_items = 3
	///The offset from side to side the food items can have on the pan
	var/max_x_offset = 4
	///The max height offset the food can reach on the pan
	var/max_height_offset = 5
	///Offset of where the click is calculated from, due to how food is positioned in their DMIs.
	var/placement_offset = -15
	/// The largest weight class we can carry, inclusive.
	/// IE, if we this is normal, we can carry normal items or smaller.
	var/biggest_w_class = WEIGHT_CLASS_NORMAL

	///Looping sound for the grill
	var/datum/looping_sound/grill/grill_loop

/obj/item/frying_pan/Initialize(mapload)
	. = ..()
	grill_loop = new(src, FALSE)

	ADD_TRAIT(src, TRAIT_ALLOWED_ON_STOVE, INNATE_TRAIT)
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_ON_HEATED_STOVE), SIGNAL_REMOVETRAIT(TRAIT_ON_HEATED_STOVE)), PROC_REF(update_stove_status))

/obj/item/frying_pan/Destroy(force)
	QDEL_NULL(grill_loop)
	return ..()

/obj/item/frying_pan/stove_process(obj/machinery/stove_source, seconds_per_tick, heat_temp, heat_coeff)
	. = ..()
	for(var/obj/item/griddled_item in contents)
		if(SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILL_PROCESS, src, seconds_per_tick) & COMPONENT_HANDLED_GRILLING)
			continue
		griddled_item.fire_act(COOKING_FIRE_ACT_TEMP) //Hot hot hot!

/obj/item/frying_pan/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.w_class > biggest_w_class)
		balloon_alert(user, "too big!")
		return ITEM_INTERACT_BLOCKING
	if(contents.len >= max_items)
		balloon_alert(user, "can't fit!")
		return ITEM_INTERACT_BLOCKING
	//Center the icon where the user clicked.
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src, silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	tool.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -max_x_offset, max_x_offset)
	tool.pixel_y = min(text2num(LAZYACCESS(modifiers, ICON_Y)) + placement_offset, max_height_offset)
	to_chat(user, span_notice("You place [tool] on [src]."))
	add_to_pan(tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/frying_pan/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return .
	if(!iscarbon(target))
		return .
	if(!contents.len)
		return .
	var/obj/item/object_to_eat = contents[1]
	object_to_eat.melee_attack_chain(user, target)
	return TRUE //No normal attack

/obj/item/frying_pan/IsContainedAtomAccessible(atom/contained, atom/movable/user)
	return TRUE

///This proc adds the food to viscontents and makes sure it can deregister if this changes.
/obj/item/frying_pan/proc/add_to_pan(obj/item/item_to_pan, mob/user)
	vis_contents += item_to_pan
	item_to_pan.vis_flags |= VIS_INHERIT_PLANE

	SEND_SIGNAL(item_to_pan, COMSIG_ITEM_GRILL_PLACED, user)
	if(HAS_TRAIT(src, TRAIT_ON_HEATED_STOVE))
		SEND_SIGNAL(item_to_pan, COMSIG_ITEM_GRILL_TURNED_ON)
	RegisterSignal(item_to_pan, COMSIG_ITEM_GRILLED, PROC_REF(grill_completed))

	RegisterSignal(item_to_pan, COMSIG_MOVABLE_MOVED, PROC_REF(item_moved))
	RegisterSignal(item_to_pan, COMSIG_QDELETING, PROC_REF(item_moved))

	// We gotta offset ourselves via pixel_w/z, so we don't end up z fighting with the plane
	item_to_pan.pixel_w = item_to_pan.pixel_x
	item_to_pan.pixel_z = item_to_pan.pixel_y
	item_to_pan.pixel_x = 0
	item_to_pan.pixel_y = 0

	update_appearance()
	// If the incoming item is the same weight class as the pan, bump us up a class
	if(item_to_pan.w_class == w_class)
		update_weight_class(w_class + 1)

	update_grill_audio()

///This proc cleans up any signals on the item when it is removed from a pan, and ensures it has the correct state again.
/obj/item/frying_pan/proc/item_removed_from_pan(obj/item/removed_item)
	removed_item.vis_flags &= ~VIS_INHERIT_PLANE
	vis_contents -= removed_item
	UnregisterSignal(removed_item, list(
		COMSIG_ITEM_GRILL_PLACED,
		COMSIG_ITEM_GRILL_TURNED_ON,
		COMSIG_ITEM_GRILLED,
		COMSIG_MOVABLE_MOVED,
		COMSIG_QDELETING))
	// Reset item offsets
	removed_item.pixel_x = removed_item.pixel_w
	removed_item.pixel_y = removed_item.pixel_z
	removed_item.pixel_w = 0
	removed_item.pixel_z = 0

	// We need to ensure the weight class is accurate now that we've lost something
	// that may or may not have been of equal weight
	var/new_w_class = initial(w_class)
	for(var/obj/item/on_board in src)
		if(on_board.w_class == w_class)
			new_w_class += 1
			break

	update_weight_class(new_w_class)

	update_grill_audio()

///This proc is called by signals that remove the food from the pan.
/obj/item/frying_pan/proc/item_moved(obj/item/moved_item, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	item_removed_from_pan(moved_item)

/obj/item/frying_pan/proc/grill_completed(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	add_to_pan(grilled_result)

/obj/item/frying_pan/proc/update_stove_status(atom/source)
	SIGNAL_HANDLER

	for(var/obj/item/griddled_item in contents)
		if(HAS_TRAIT(src, TRAIT_ON_HEATED_STOVE))
			SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILL_TURNED_ON)
		else
			SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILL_TURNED_OFF)

	update_grill_audio()

/obj/item/frying_pan/proc/update_grill_audio()
	if(HAS_TRAIT(src, TRAIT_ON_HEATED_STOVE) && length(contents))
		grill_loop.start()
	else
		grill_loop.stop()

/obj/item/frying_pan/tall
	name = "small pot"
	desc = "Despite its namesake, its mostly just used for frying."
	icon_state = "small_pot"
	max_items = 5
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2)
	custom_price = PAYCHECK_LOWER * 20
