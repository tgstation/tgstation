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
	var/obj/item/container

	var/container_x = 0
	var/container_y = 8

/datum/component/stove/Initialize(container_x = 0, container_y = 8)
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE

	src.container_x = container_x
	src.container_y = container_y

/datum/component/stove/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlay_update))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context))

	var/obj/machinery/real_parent = parent
	real_parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/stove/UnregisterFromParent()
	var/obj/machinery/real_parent = parent
	container.forceMove(real_parent.drop_location())

	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_PARENT_ATTACKBY,
	))

/datum/component/stove/process(delta_time)
	var/obj/machinery/real_parent = parent
	if(real_parent.machine_stat & NOPOWER)
		turn_off()
		return

	container?.reagents.expose_temperature(600, 0.1)
	real_parent.use_power(real_parent.active_power_usage)

/datum/component/stove/proc/turn_on()
	START_PROCESSING(SSmachines, src)
	on = TRUE

/datum/component/stove/proc/turn_off()
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

	if(!attacking_item.is_open_container())
		return

	if(user.transferItemToLoc(attacking_item, parent))
		add_container(attacking_item, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/stove/proc/on_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(gone == container)
		remove_container()

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
		context[SCREENTIP_CONTEXT_RMB] = "Turn [on ? "off":"on"] burner"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.is_open_container())
		context[SCREENTIP_CONTEXT_LMB] = "Place container"
		return CONTEXTUAL_SCREENTIP_SET

/datum/component/stove/proc/add_container(obj/item/new_container, mob/user)
	var/obj/real_parent = parent
	real_parent.vis_contents += new_container

	new_container.flags_1 |= IS_ONTOP_1
	new_container.vis_flags |= VIS_INHERIT_PLANE

	container = new_container
	container.pixel_x = container_x
	container.pixel_y = container_y

/datum/component/stove/proc/remove_container()
	var/obj/real_parent = parent
	container.flags_1 &= ~IS_ONTOP_1
	container.vis_flags &= ~VIS_INHERIT_PLANE
	real_parent.vis_contents -= container
	container.pixel_x = container.base_pixel_x
	container.pixel_y = container.base_pixel_y
	container = null
