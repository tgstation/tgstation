/datum/component/stove
	var/on = FALSE
	var/obj/item/soup_pot

/datum/component/stove/Initialize()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/stove/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_icon_state_update))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context))

	var/obj/real_parent = parent
	real_parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/stove/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_PARENT_ATTACKBY,
	))
	soup_pot = null

/datum/component/stove/process(delta_time)
	soup_pot?.reagents.expose_temperature(600, 0.1)

/datum/component/stove/proc/on_attack_hand_secondary(datum/source)
	SIGNAL_HANDLER

	on = !on
	if(on)
		START_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSmachines, src)

	return COMPONENT_NO_AFTERATTACK

/datum/component/stove/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(attacking_item, /obj/item/reagent_containers/cup/soup_pot))
		return

	if(user.transferItemToLoc(attacking_item, parent))
		add_soup_pot(attacking_item, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/stove/proc/on_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(gone == soup_pot)
		remove_soup_pot()

/datum/component/stove/proc/on_icon_state_update(datum/source)
	SIGNAL_HANDLER

	if(!on)
		return

	var/obj/real_parent = parent
	real_parent.icon_state = "[real_parent.base_icon_state]_on"
	return COMSIG_ATOM_NO_UPDATE_ICON_STATE

/datum/component/stove/proc/on_requesting_context(datum/source, list/context, obj/item/held_item)
	SIGNAL_HANDLER

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Turn [on ? "off":"on"] stove"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/reagent_containers/cup/soup_pot))
		context[SCREENTIP_CONTEXT_LMB] = "Set pot"
		return CONTEXTUAL_SCREENTIP_SET

/datum/component/stove/proc/add_soup_pot(obj/item/reagent_containers/cup/soup_pot/pot, mob/user)
	var/obj/real_parent = parent
	real_parent.vis_contents += pot

	pot.flags_1 |= IS_ONTOP_1
	pot.vis_flags |= VIS_INHERIT_PLANE

	soup_pot = pot
	soup_pot.pixel_x = 0
	soup_pot.pixel_y = 8

/datum/component/stove/proc/remove_soup_pot()
	var/obj/real_parent = parent
	soup_pot.flags_1 &= ~IS_ONTOP_1
	soup_pot.vis_flags &= ~VIS_INHERIT_PLANE
	real_parent.vis_contents -= soup_pot
	soup_pot.pixel_x = soup_pot.base_pixel_x
	soup_pot.pixel_y = soup_pot.base_pixel_y
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

	if(!isnull(held_item) && can_add_ingredient(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Add ingredient"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/reagent_containers/cup/soup_pot/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(added_ingredients, gone)

/obj/item/reagent_containers/cup/soup_pot/attackby_secondary(obj/item/weapon, mob/user, params)
	if(!can_add_ingredient(weapon))
		return SECONDARY_ATTACK_CALL_NORMAL

	if(!user.transferItemToLoc(weapon, src))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	balloon_alert(user, "ingredient added")
	LAZYADD(added_ingredients, weapon)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/reagent_containers/cup/soup_pot/proc/can_add_ingredient(obj/item/ingredient)
	// Let default reagent handling take this
	if(ingredient.is_open_container())
		return FALSE
	// To big for the pot
	if(ingredient.w_class >= WEIGHT_CLASS_BULKY)
		return FALSE
	// Too many ingredients
	if(LAZYLEN(added_ingredients) >= max_ingredients)
		return FALSE
	return TRUE

/obj/item/reagent_containers/cup/soup_pot/proc/on_reagents_cleared(datum/source, datum/reagent/changed)
	SIGNAL_HANDLER

	dump_ingredients()

/obj/item/reagent_containers/cup/soup_pot/proc/dump_ingredients(atom/drop_loc = drop_location())
	for(var/obj/item/ingredient as anything in added_ingredients)
		ingredient.forceMove(drop_loc)
