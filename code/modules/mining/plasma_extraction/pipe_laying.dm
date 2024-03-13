/datum/component/pipe_laying
	///The pipe dispenser we're checking for placing pipes.
	var/obj/item/pipe_dispenser/pipe_placing
	///The user that is placing the pipes, and ahs the lock on component.
	var/mob/living/pipe_placer
	///The extraction part hub that owns the whole pipe layers, including ones we make.
	var/obj/structure/plasma_extraction_hub/part/pipe/part_hub

	///Boolean on whether the pipe needs to start a tile in front of parent when building.
	var/start_one_tile_ahead
	///Boolean on whether pipes are currently being built, to prevent spam and/or other players.
	var/building_pipes

	/// A weakref to the tile currently being targeted by the lockon component.
	var/datum/weakref/current_target_weakref
	/// A ref to our lockon component, which is created and destroyed on activation and deactivation.
	var/datum/component/lock_on_cursor/lockon_component

	///List of all turfs that is currently being hovered over, and has the pipe overlay appearance.
	var/list/turf/turfs_hovering = list()
	///The overlay put in the path of where our cursor is hovering, to tell where pipes will be built.
	var/static/mutable_appearance/pipe_overlay_appearance

/datum/component/pipe_laying/Initialize(
	obj/structure/plasma_extraction_hub/part/pipe/connecting_part_hub,
	start_one_tile_ahead = FALSE
)
	. = ..()
	if(!connecting_part_hub || !istype(connecting_part_hub))
		return COMPONENT_INCOMPATIBLE
	src.part_hub = connecting_part_hub
	src.start_one_tile_ahead = start_one_tile_ahead
	if(!pipe_overlay_appearance)
		pipe_overlay_appearance = mutable_appearance(icon = 'icons/obj/pipes_n_cables/plasma_extractor.dmi', icon_state = "pipe", layer = ABOVE_ALL_MOB_LAYER, plane = ABOVE_GAME_PLANE, alpha = 100, offset_const = src)

/datum/component/pipe_laying/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/component/pipe_laying/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	if(pipe_placing)
		UnregisterSignal(pipe_placing, COMSIG_MOVABLE_MOVED)

/datum/component/pipe_laying/proc/on_attackby(datum/source, obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/pipe_dispenser) || building_pipes)
		return
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
	return COMPONENT_NO_AFTERATTACK

/datum/component/pipe_laying/proc/on_lockon_component(list/locked_weakrefs)
	if(building_pipes)
		return
	if(!length(locked_weakrefs))
		current_target_weakref = null
		return
	current_target_weakref = locked_weakrefs[1]
	var/atom/real_target = current_target_weakref.resolve()
	if(real_target)
		pipe_placer.face_atom(real_target)
	var/list/pipe_locations
	if(start_one_tile_ahead)
		var/obj/parent_obj = parent
		var/turf/next_turf = get_step(parent, parent_obj.dir)
		pipe_locations = get_path_to(next_turf, real_target, max_distance = 4, diagonal_handling = DIAGONAL_REMOVE_ALL) + next_turf
	else
		pipe_locations = get_path_to(parent, real_target, max_distance = 4, diagonal_handling = DIAGONAL_REMOVE_ALL)
	var/list/new_turf_list = list()
	for(var/turf/next_location as anything in pipe_locations)
		new_turf_list += pipe_locations
		if(!(next_location in turfs_hovering)) //already has one
			next_location.add_overlay(pipe_overlay_appearance)
	for(var/turf/existing_turfs as anything in turfs_hovering)
		if(!(existing_turfs in new_turf_list))
			existing_turfs.cut_overlay(pipe_overlay_appearance)
	turfs_hovering = new_turf_list

/datum/component/pipe_laying/proc/clear_click_catch()
	if(!lockon_component)
		return
	for(var/turf/turfs_with_overlay as anything in turfs_hovering)
		turfs_with_overlay.cut_overlay(pipe_overlay_appearance)
	turfs_hovering.Cut()
	UnregisterSignal(pipe_placing, COMSIG_MOVABLE_MOVED)
	pipe_placing = null
	pipe_placer.clear_fullscreen("pipe_extractor")
	pipe_placer = null
	playsound(parent, 'sound/effects/empulse.ogg', 75, TRUE)
	QDEL_NULL(lockon_component)

/datum/component/pipe_laying/proc/on_catcher_click(turf/location, control, params, user)
	SIGNAL_HANDLER

	if(building_pipes)
		return
	INVOKE_ASYNC(src, PROC_REF(build_pipes), location)

/datum/component/pipe_laying/proc/build_pipes(turf/starting_location)
	building_pipes = TRUE
	var/list/pipe_locations
	if(start_one_tile_ahead)
		var/obj/parent_obj = parent
		var/turf/next_turf = get_step(parent, parent_obj.dir)
		pipe_locations = list(next_turf) + get_path_to(next_turf, starting_location, max_distance = 4, diagonal_handling = DIAGONAL_REMOVE_ALL)
	else
		pipe_locations = get_path_to(parent, starting_location, max_distance = 4, diagonal_handling = DIAGONAL_REMOVE_ALL)
	var/obj/structure/liquid_plasma_extraction_pipe/last_placed_pipe
	var/should_delete_ourselves = FALSE
	if(length(pipe_locations))
		for(var/turf/next_location as anything in pipe_locations)
			if(!do_after(pipe_placer, 2 SECONDS, next_location, extra_checks = CALLBACK(src, PROC_REF(holding_pipe_check))))
				break
			var/obj/structure/liquid_plasma_extraction_pipe/new_segment
			var/obj/structure/liquid_plasma_geyser/last_spot = locate() in next_location
			if(last_spot)
				new_segment = new /obj/structure/liquid_plasma_extraction_pipe/ending(next_location, part_hub)
			else
				new_segment = new(next_location, part_hub)
			var/spot_in_list = pipe_locations.Find(next_location)
			var/direction_to_place
			if(spot_in_list == length(pipe_locations) || last_spot) //last one copies the last one as it's trailing
				var/turf/previous_segment
				if(spot_in_list == 1) //in case you're only building one pipe
					previous_segment = get_turf(parent)
				else
					previous_segment = pipe_locations[spot_in_list - 1]
				direction_to_place = get_dir(previous_segment, next_location) //no special diagonal movement cause it can't be diagonal.
			else
				var/turf/previous_segment
				if(spot_in_list == 1) //first one starts from the extraction hub
					previous_segment = get_turf(parent)
				else
					previous_segment = pipe_locations[spot_in_list - 1]
				var/turf/next_segment = pipe_locations[spot_in_list + 1]

				var/next_direction = get_dir(previous_segment, next_segment)
				var/previous_direction = get_dir(next_location, previous_segment)

				direction_to_place = next_direction
				if(ISDIAGONALDIR(next_direction) && (NSCOMPONENT(previous_direction)))
					direction_to_place = REVERSE_DIR(direction_to_place)
			last_placed_pipe = new_segment
			should_delete_ourselves = TRUE
			new_segment.setDir(direction_to_place)
			part_hub.connected_pipes += new_segment
			if(last_spot) // no more building after the ending spot is reached.
				last_placed_pipe = null
				part_hub.last_pipe = new_segment
				break

	building_pipes = FALSE
	pipe_locations = null
	clear_click_catch()

	if(last_placed_pipe)
		last_placed_pipe.AddComponent(/datum/component/pipe_laying, part_hub, start_one_tile_ahead = TRUE)
	if(should_delete_ourselves)
		qdel(src)

/datum/component/pipe_laying/proc/holding_pipe_check()
	var/obj/item/pipe_dispenser/held_item = pipe_placer.get_active_held_item()
	return (held_item == pipe_placing)

/datum/component/pipe_laying/proc/on_dispenser_move(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(clear_click_catch))
