/obj/machinery/stove
	name = "stove"
	desc = "You'd think this would be more useful in the kitchen."
	icon = 'icons/obj/machines/kitchenmachines.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	pass_flags_self = PASSMACHINE|PASSTABLE|LETPASSTHROW // It's roughly the height of a table.
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/griddle
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF

	var/obj/item/soup_pot

/obj/machinery/stove/process(delta_time)
	soup_pot?.reagents.expose_temperature(10 * delta_time, 0.25)

/obj/machinery/griddle/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	on = !on
	if(on)
		begin_processing()
	else
		end_processing()
	return TRUE

/obj/machinery/stove/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/reagent_containers/cup/soup_pot))
		if(user.transferItemToLoc(attacking_item, src))
			add_soup_pot(attacking_item, user)
		return TRUE

	return ..()

/obj/machinery/stove/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == soup_pot)
		remove_soup_pot()

/obj/machinery/stove/proc/add_soup_pot(obj/item/reagent_containers/cup/soup_pot/pot, mob/user)
	vis_contents += pot

	pot.flags_1 |= IS_ONTOP_1
	pot.vis_flags |= VIS_INHERIT_PLANE

	soup_pot = pot

/obj/machinery/stove/proc/remove_soup_pot()
	soup_pot.flags_1 &= ~IS_ONTOP_1
	soup_pot.vis_flags &= ~VIS_INHERIT_PLANE
	vis_contents -= soup_pot
	soup_pot = null

/obj/item/reagent_containers/cup/soup_pot
	name = "soup pot"
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "bowl"
	volume = 200
	possible_transfer_amounts = list(20, 50, 100, 200)
	reagent_flags = OPENCONTAINER
	custom_materials = list(/datum/material/iron = 5000)
	w_class = WEIGHT_CLASS_BULKY

	var/max_ingredients = 24
	/// A list of all the ingredients we have added
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
	SIGNAL_HANDLER

	if(!isnull(held_item) && can_add_ingredient(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Add Ingredient"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/reagent_containers/cup/soup_pot/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(added_ingredients, gone)

/obj/item/reagent_containers/cup/soup_pot/attackby_secondary(obj/item/weapon, mob/user, params)
	if(!can_add_ingredient(weapon))
		return SECONDARY_ATTACK_CALL_NORMAL

	if(!user.transferItemToLoc(attacking_item, src))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	balloon_alert(user, "ingredient added")
	LAZYADD(added_ingredients, ingredient)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/reagent_containers/cup/soup_pot/proc/can_add_ingredient(obj/item/ingredient)
	// Let default reagent handling take this
	if(ingredient.is_open_container())
		return FALSE
	// To big for the pot
	if(attacking_item.w_class >= WEIGHT_CLASS_BULKY)
		return FALSE
	// Too many ingredients
	if(length(added_ingredients) <= max_ingredients)
		return FALSE
	return TRUE

/datum/component/soup_holder/proc/on_reagents_cleared(datum/source, datum/reagent/changed)
	SIGNAL_HANDLER

	dump_ingredients()

/datum/component/soup_holder/proc/dump_ingredients(atom/loc_override)
	for(var/obj/item/ingredient as anything in added_ingredients)
		ingredient.forceMove(loc_override || drop_location())
