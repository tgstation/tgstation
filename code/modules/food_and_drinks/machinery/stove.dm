
/obj/item/reagent_containers/cup/soup_pot
	name = "soup pot"
	desc = "A tall soup designed to mix and cook all kinds of soup."
	icon = 'icons/obj/soup_pot.dmi'
	icon_state = "pot"
	base_icon_state = "pot"
	volume = 200
	possible_transfer_amounts = list(20, 50, 100, 200)
	reagent_flags = OPENCONTAINER
	custom_materials = list(/datum/material/iron = 5000)
	w_class = WEIGHT_CLASS_BULKY
	fill_icon_thresholds = null
	/// Max number of ingredients we can add
	var/max_ingredients = 24
	/// A lazylist of all the ingredients we have added
	var/list/obj/item/added_ingredients

/obj/item/reagent_containers/cup/soup_pot/Initialize(mapload, vol)
	. = ..()
	RegisterSignal(reagents, COMSIG_REAGENTS_CLEAR_REAGENTS, PROC_REF(on_reagents_cleared))
	register_context()

/obj/item/reagent_containers/cup/soup_pot/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/user,
)

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Remove ingredient"
		return CONTEXTUAL_SCREENTIP_SET

	else if(can_add_ingredient(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Add ingredient"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/reagent_containers/cup/soup_pot/examine(mob/user)
	. = ..()
	if(LAZYLEN(added_ingredients))
		. += "Inside, you can see:"
		for(var/obj/item/ingredient as anything in added_ingredients)
			. += "[ingredient]" // melbert todo: make these do "three tomatos two apples one carrot" etc
	else
		. += "There's nothing inside."

/obj/item/reagent_containers/cup/soup_pot/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(added_ingredients, gone)

/obj/item/reagent_containers/cup/soup_pot/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(.)
		return

	if(!can_add_ingredient(attacking_item))
		return FALSE

	// Too many ingredients
	if(LAZYLEN(added_ingredients) >= max_ingredients)
		balloon_alert(user, "too many ingredients!")
		return TRUE
	if(!user.transferItemToLoc(attacking_item, src))
		balloon_alert(user, "can't add that!")
		return TRUE

	var/atom/balloon_loc = ismachinery(loc) ? loc : src
	balloon_loc.balloon_alert(user, "ingredient added")
	user.face_atom(balloon_loc)
	LAZYADD(added_ingredients, attacking_item)

	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/reagent_containers/cup/soup_pot/attack_hand_secondary(mob/user, list/modifiers)
	if(!LAZYLEN(added_ingredients))
		return SECONDARY_ATTACK_CALL_NORMAL

	var/obj/item/removed = added_ingredients[1]
	removed.forceMove(get_turf(src))
	user.put_in_hands(removed)
	var/atom/balloon_loc = ismachinery(loc) ? loc : src
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

	return TRUE

/obj/item/reagent_containers/cup/soup_pot/proc/on_reagents_cleared(datum/source, datum/reagent/changed)
	SIGNAL_HANDLER

	dump_ingredients()

/obj/item/reagent_containers/cup/soup_pot/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash)
	. = ..()
	if(.)
		return
	dump_ingredients()

/obj/item/reagent_containers/cup/soup_pot/proc/dump_ingredients(atom/drop_loc = drop_location())
	for(var/obj/item/ingredient as anything in added_ingredients)
		ingredient.forceMove(drop_loc)
		ingredient.SpinAnimation(loops = 1)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/cup/soup_pot/update_overlays()
	. = ..()
	if(length(added_ingredients) <= 0 && reagents.total_volume <= 0)
		return
	var/mutable_appearance/filled_overlay = mutable_appearance(icon, "[base_icon_state]_filling_overlay")
	var/list/food_reagents = list()
	for(var/obj/item/ingredient as anything in added_ingredients)
		food_reagents |= ingredient.reagents.reagent_list

	filled_overlay.color = mix_color_from_reagents(reagents.reagent_list + food_reagents)
	. += filled_overlay

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
	icon_preview = 'icons/obj/machines/kitchenmachines.dmi'
	icon_state_preview = "range_off"

/obj/machinery/stove/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stove, container_x = -6, container_y = 16)
