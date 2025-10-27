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
	VAR_FINAL/on = FALSE
	/// A reference to the current soup pot overtop
	VAR_FINAL/obj/item/container
	/// Typepath of particles to use for the particle holder.
	VAR_FINAL/particle_type = /particles/smoke/steam/mild
	/// Ref to our looping sound played when cooking
	VAR_FINAL/datum/looping_sound/soup/soup_sound

	/// The color of the flames around the burner.
	var/flame_color = "#006eff"
	/// Container's pixel x when placed on the stove
	var/container_x = 0
	/// Container's pixel y when placed on the stove
	var/container_y = 8
	/// Modifies how much temperature is exposed to the reagents, and in turn modifies how fast the reagents are heated.
	var/heat_coefficient = 0.033

/datum/component/stove/Initialize(container_x = 0, container_y = 8, obj/item/spawn_container)
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE

	src.container_x = container_x
	src.container_y = container_y

	// To allow maploaded pots on top of your stove.
	if(spawn_container)
		spawn_container.forceMove(parent)
		add_container(spawn_container)

	soup_sound = new(parent)

/datum/component/stove/Destroy()
	QDEL_NULL(soup_sound)
	return ..()

/datum/component/stove/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ROBOT_SECONDARY, PROC_REF(on_attack_robot_secondary))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlay_update))
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_deconstructed))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_MACHINERY_REFRESH_PARTS, PROC_REF(on_refresh_parts))

	var/obj/machinery/real_parent = parent
	real_parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/stove/UnregisterFromParent()
	var/obj/machinery/real_parent = parent
	if(!QDELING(parent))
		container.forceMove(real_parent.drop_location())

	if (particle_type)
		real_parent.remove_shared_particles("[particle_type]_stove_[container_x]")

	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_OBJ_DECONSTRUCT,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_EXAMINE,
		COMSIG_MACHINERY_REFRESH_PARTS,
	))

/datum/component/stove/process(seconds_per_tick)
	var/obj/machinery/real_parent = parent
	if(real_parent.machine_stat & NOPOWER)
		turn_off()
		return

	container?.reagents.expose_temperature(SOUP_BURN_TEMP + 80, heat_coefficient)
	real_parent.use_energy(real_parent.active_power_usage)

	var/turf/stove_spot = real_parent.loc
	if(isturf(stove_spot))
		stove_spot.hotspot_expose(SOUP_BURN_TEMP + 80, 100)

/datum/component/stove/proc/turn_on()
	var/obj/machinery/real_parent = parent
	if(real_parent.machine_stat & (BROKEN|NOPOWER))
		return
	START_PROCESSING(SSmachines, src)
	on = TRUE
	real_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/stove/proc/turn_off()
	var/obj/machinery/real_parent = parent
	STOP_PROCESSING(SSmachines, src)
	on = FALSE
	real_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/stove/proc/on_attack_hand_secondary(obj/machinery/source)
	SIGNAL_HANDLER

	toggle_mode()

	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/stove/proc/on_attack_robot_secondary(obj/machinery/source)
	SIGNAL_HANDLER

	toggle_mode()

	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/stove/proc/toggle_mode()
	var/obj/machinery/real_parent = parent
	if(on)
		turn_off()

	else if(real_parent.machine_stat & (BROKEN|NOPOWER))
		real_parent.balloon_alert_to_viewers("no power!")
		return

	else
		turn_on()

	real_parent.balloon_alert_to_viewers("burners [on ? "on" : "off"]")
	playsound(real_parent, 'sound/machines/click.ogg', 30, TRUE)
	playsound(real_parent, on ? 'sound/items/tools/welderactivate.ogg' : 'sound/items/tools/welderdeactivate.ogg', 15, TRUE)

/datum/component/stove/proc/on_attackby(obj/machinery/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(istype(source, /obj/machinery/oven/range) && istype(attacking_item, /obj/item/storage/bag/tray) && container)
		var/obj/machinery/oven/range/range = source
		var/obj/item/reagent_containers/cup/soup_pot/soup_pot = container

		if(!range.open)
			soup_pot.transfer_from_container_to_pot(attacking_item, user)
			return COMPONENT_NO_AFTERATTACK

	if(!attacking_item.is_open_container())
		return
	if(!isnull(container))
		to_chat(user, span_warning("You wouldn't dare try to cook two things on the same stove simultaneously. \
			What if it cross contaminates?"))
		return COMPONENT_NO_AFTERATTACK

	if(user.transferItemToLoc(attacking_item, parent))
		add_container(attacking_item, user)
		to_chat(user, span_notice("You put [attacking_item] onto [parent]."))
	return COMPONENT_NO_AFTERATTACK

/datum/component/stove/proc/on_exited(obj/machinery/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(gone == container)
		remove_container()

/datum/component/stove/proc/on_deconstructed(obj/machinery/source)
	SIGNAL_HANDLER

	container.forceMove(source.drop_location())

/datum/component/stove/proc/on_overlay_update(obj/machinery/source, list/overlays)
	SIGNAL_HANDLER

	update_smoke()

	if(!on)
		return

	var/obj/real_parent = parent

	// Flames around the pot
	var/mutable_appearance/flames = mutable_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_flame", alpha = real_parent.alpha)
	flames.color = flame_color
	overlays += flames
	overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_flame", real_parent, alpha = real_parent.alpha)

	// A green light that shows it's active
	var/mutable_appearance/light = mutable_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_overlay", alpha = real_parent.alpha)
	light.color = "#00ff00"
	overlays += light
	overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_overlay", real_parent, alpha = real_parent.alpha)

/datum/component/stove/proc/on_requesting_context(obj/machinery/source, list/context, obj/item/held_item)
	SIGNAL_HANDLER

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Turn [on ? "off":"on"] burner"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.is_open_container())
		context[SCREENTIP_CONTEXT_LMB] = "Place container"
		return CONTEXTUAL_SCREENTIP_SET

/datum/component/stove/proc/on_examine(obj/machinery/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("You can turn the stovetop burners [on ? "off" : "on"] with <i>right click</i>.")

/datum/component/stove/proc/on_refresh_parts(obj/machinery/source)
	SIGNAL_HANDLER

	var/new_multiplier = 0
	for(var/datum/stock_part/micro_laser/part in source.component_parts)
		new_multiplier += (part.tier * 0.5)

	heat_coefficient = initial(heat_coefficient) * max(round(new_multiplier), 1)

/datum/component/stove/proc/add_container(obj/item/new_container, mob/user)
	var/obj/real_parent = parent
	real_parent.vis_contents += new_container
	ADD_TRAIT(new_container, TRAIT_SKIP_BASIC_REACH_CHECK, REF(src))
	new_container.vis_flags |= VIS_INHERIT_PLANE

	container = new_container
	container.pixel_x = container_x
	container.pixel_y = container_y

	update_smoke_type()
	RegisterSignal(container.reagents, COMSIG_REAGENTS_TEMP_CHANGE, PROC_REF(update_smoke_type))
	real_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/stove/proc/remove_container()
	var/obj/real_parent = parent
	REMOVE_TRAIT(container, TRAIT_SKIP_BASIC_REACH_CHECK, REF(src))
	container.vis_flags &= ~VIS_INHERIT_PLANE
	real_parent.vis_contents -= container

	UnregisterSignal(container.reagents, COMSIG_REAGENTS_TEMP_CHANGE)

	container.pixel_x = container.base_pixel_x
	container.pixel_y = container.base_pixel_y
	container = null

	update_smoke_type()
	real_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/stove/proc/update_smoke_type(datum/source, ...)
	SIGNAL_HANDLER

	var/existing_temp = container?.reagents.chem_temp || 0
	var/old_type = particle_type
	if(existing_temp >= SOUP_BURN_TEMP)
		particle_type = /particles/smoke/steam/bad
	else if(existing_temp >= WATER_BOILING_POINT)
		particle_type = /particles/smoke/steam/mild
	else
		particle_type = null

	update_smoke(old_type)

/datum/component/stove/proc/update_smoke(old_type = null)
	var/obj/obj_parent = parent

	if (old_type)
		obj_parent.remove_shared_particles("[old_type]_stove_[container_x]")

	if(!on || !container?.reagents.total_volume)
		soup_sound?.stop()
		if (!isnull(particle_type))
			obj_parent.remove_shared_particles("[particle_type]_stove_[container_x]")
		return

	soup_sound.start()
	if(isnull(particle_type))
		return
	var/obj/effect/abstract/shared_particle_holder/soup_smoke = obj_parent.add_shared_particles(particle_type, "[particle_type]_stove_[container_x]")
	soup_smoke.particles.position = list(container_x, round(ICON_SIZE_Y * 0.66), 0)
