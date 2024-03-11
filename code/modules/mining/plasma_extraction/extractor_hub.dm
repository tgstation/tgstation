/**
 * Base plasma extraction machine
 */
/obj/structure/plasma_extraction_hub
	name = "plasma extraction hub"
	desc = "The hub to a connection of pipes. If there aren't any, then get building!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE

/**
 * Base plasma extraction machine part
 * All parts that don't have a pipe, use this.
 */
/obj/structure/plasma_extraction_hub/part
	var/obj/structure/plasma_extraction_hub/part/pipe/main_machine

/obj/structure/plasma_extraction_hub/part/proc/on_update_icon(obj/machinery/gravity_generator/source, updates, updated)
	SIGNAL_HANDLER
	return update_appearance(updates)

/**
 * Plasma extraction machine pipe
 * There's 3 of these on each plasma extraction machine, one of which is the owner of the rest.
 */
/obj/structure/plasma_extraction_hub/part/pipe
	name = "starting pipe location"
	var/obj/item/pipe_dispenser/pipe_placing
	var/mob/living/pipe_placer

	/// A weakref to the mob we're currently targeting with the lockon component.
	var/datum/weakref/current_target_weakref
	/// A ref to our lockon component, which is created and destroyed on activation and deactivation.
	var/datum/component/lock_on_cursor/lockon_component

/obj/structure/plasma_extraction_hub/part/pipe/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/pipe_dispenser) || pipe_placer)
		return ..()
	pipe_placing = weapon
	RegisterSignal(pipe_placing, COMSIG_MOVABLE_MOVED, PROC_REF(on_dispenser_move))
	pipe_placer = user
	lockon_component = pipe_placer.AddComponent( \
		/datum/component/lock_on_cursor, \
		lock_cursor_range = 0, \
		target_typecache = typecacheof(list(/turf/open/misc, /turf/open/floor)), \
		lock_amount = 1, \
		on_click_callback = CALLBACK(src, PROC_REF(on_catcher_click)), \
		on_lock = CALLBACK(src, PROC_REF(on_lockon_component)), \
	)

/obj/structure/plasma_extraction_hub/part/pipe/proc/on_lockon_component(list/locked_weakrefs)
	if(!length(locked_weakrefs))
		current_target_weakref = null
		return
	current_target_weakref = locked_weakrefs[1]
	var/atom/real_target = current_target_weakref.resolve()
	if(real_target)
		pipe_placer.face_atom(real_target)

/obj/structure/plasma_extraction_hub/part/pipe/proc/clear_click_catch()
	if(!lockon_component)
		return
	UnregisterSignal(pipe_placing, COMSIG_MOVABLE_MOVED)
	pipe_placing = null
	pipe_placer.clear_fullscreen("pipe_extractor")
	pipe_placer = null
	playsound(src, 'sound/effects/empulse.ogg', 75, TRUE)
	QDEL_NULL(lockon_component)

/obj/structure/plasma_extraction_hub/part/pipe/proc/on_catcher_click(location, control, params, user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(build_pipes), get_turf(location))

/obj/structure/plasma_extraction_hub/part/pipe/proc/build_pipes(turf/starting_location)
	var/list/pipe_locations = get_path_to(src, starting_location, max_distance = 5, diagonal_handling = DIAGONAL_DO_NOTHING)
	for(var/turf/next_location as anything in pipe_locations)
		pipe_locations -= next_location
		if(!do_after(pipe_placer, 2 SECONDS, next_location, extra_checks = CALLBACK(src, PROC_REF(holding_pipe_check))))
			break
		new /obj/structure/disposalpipe/segment(next_location)

	pipe_locations = null
	clear_click_catch()

/obj/structure/plasma_extraction_hub/part/pipe/proc/holding_pipe_check()
	var/obj/item/pipe_dispenser/held_item = pipe_placer.get_active_held_item()
	return (held_item == pipe_placing)

/obj/structure/plasma_extraction_hub/part/pipe/proc/on_dispenser_move(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(clear_click_catch))

/obj/structure/plasma_extraction_hub/part/pipe/east
	dir = EAST

/obj/structure/plasma_extraction_hub/part/pipe/west
	dir = WEST

/**
 * Main plasma extraction machine
 * This 'Owns' all the rest, while also acting like a pipe part in its own right.
 */
/obj/structure/plasma_extraction_hub/part/pipe/main
	///List of all parts connected to the extraction hub.
	var/list/obj/structure/plasma_extraction_hub/hub_parts = list()

/obj/structure/plasma_extraction_hub/part/pipe/main/Initialize(mapload)
	. = ..()
	//the only one that calls setup, as the creator
	setup_parts()

///Copied over from Gravity Generator, this sets up the parts of the plasma extraction hub, and its
///3 pipe starting points.
/obj/structure/plasma_extraction_hub/part/pipe/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = CORNER_BLOCK_OFFSET(our_turf, 3, 3, -1, 0)
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			continue
		var/obj/structure/plasma_extraction_hub/part/new_part
		switch(count)
			//east
			if(4)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe/east(T)
			//west
			if(6)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe/west(T)
			else
				new_part = new/obj/structure/plasma_extraction_hub/part(T)
		hub_parts += new_part
		new_part.main_machine = src
		new_part.update_appearance()
		new_part.RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, TYPE_PROC_REF(/obj/structure/plasma_extraction_hub/part, on_update_icon))

/obj/structure/plasma_extraction_hub/part/pipe/main/Destroy()
	. = ..()
	QDEL_LIST(hub_parts)

/obj/structure/plasma_extraction_hub/part/pipe/main/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	to_chat(user, "Interacted with [src]")
