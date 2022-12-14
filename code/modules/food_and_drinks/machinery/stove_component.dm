/**
 * # Stove Component
 *
 * Makes the attached object a stove
 *
 * Pots can be put on the stove to make soup, and attack-handing it will start processing
 * where it will heat up the pot's reagents inside
 */
/datum/component/stove
	/// Whether we're currently cooking
	var/on = FALSE
	/// A reference to the current soup pot overtop
	var/obj/item/soup_pot

/datum/component/stove/Initialize()
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/stove/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlay_update))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context))

	var/obj/real_parent = parent
	real_parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/stove/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_PARENT_ATTACKBY,
	))
	soup_pot = null

/datum/component/stove/process(delta_time)
	var/obj/item/machinery/real_parent = parent
	if(real_parent.machine_stat & NOPOWER)
		turn_off()
		return

	soup_pot?.reagents.expose_temperature(600, 0.1)
	real_parent.use_power(real_parent.active_power_usage)

/datum/component/stove/proc/turn_on()
	var/obj/item/machinery/real_parent = parent
	START_PROCESSING(SSmachines, src)
	on = TRUE

/datum/component/stove/proc/turn_off()
	var/obj/item/machinery/real_parent = parent
	STOP_PROCESSING(SSmachines, src)
	on = FALSE

/datum/component/stove/proc/on_attack_hand_secondary(datum/source)
	SIGNAL_HANDLER

	if(on)
		turn_off()
	else
		turn_on()

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

/datum/component/stove/proc/on_overlay_update(datum/source, list/overlays)
	SIGNAL_HANDLER

	if(!on)
		return

	var/obj/real_parent = parent
	overlays += mutable_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_overlay", real_parent, alpha = real_parent.alpha)
	overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_lightmask", real_parent, alpha = real_parent.alpha)

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
