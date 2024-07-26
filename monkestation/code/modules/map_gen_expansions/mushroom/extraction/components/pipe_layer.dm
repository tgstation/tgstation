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
		pipe_overlay_appearance = mutable_appearance(icon = 'monkestation/code/modules/map_gen_expansions/icons/plasma_extractor.dmi', icon_state = "pipe", layer = ABOVE_ALL_MOB_LAYER, plane = ABOVE_GAME_PLANE, alpha = 100, offset_spokesman = parent)

/datum/component/pipe_laying/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/component/pipe_laying/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	if(pipe_placing)
		UnregisterSignal(pipe_placing, COMSIG_MOVABLE_MOVED)

/**
 * Called when attacking this with an item
 * If it's a pipe dispenser, we'll set the user and pipe dispenser,
 * and give the lock on component so we can listen in on where they are trying
 * to build.
 */
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

/**
 * Called when the lock on component sets their target to what the cursor is hovering over.
 * We'll get the path to said target from parent, and give them a general idea of where
 * the pipes they are trying to place will be built via an overlay.
 * We'll only give this overlay if it doesn't already have it, and only remove it if it's no longer supposed to,
 * this is to prevent a 'flashing' effect for tiles that already have the overlay but are supposed to keep it.
 */
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
	var/obj/parent_obj = parent
	var/list/pipe_locations = get_path_to(parent, real_target, max_distance = MAX_PIPE_DISTANCE, exclude=get_turf(get_step(parent_obj, REVERSE_DIR(parent_obj.dir))), diagonal_handling = DIAGONAL_REMOVE_ALL)
	var/list/new_turf_list = list()
	for(var/turf/next_location as anything in pipe_locations)
		new_turf_list += pipe_locations
		if(!(next_location in turfs_hovering)) //already has one
			next_location.add_overlay(pipe_overlay_appearance)
	for(var/turf/existing_turfs as anything in turfs_hovering)
		if(!(existing_turfs in new_turf_list))
			existing_turfs.cut_overlay(pipe_overlay_appearance)
	turfs_hovering = new_turf_list

/**
 * Removes all overlays and clears the list of turfs, essentially resetting the component back to default,
 * ready to use again later (if possible).
 */
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

///Called when the user clicks on something, which we just redirect to build pipes.
/datum/component/pipe_laying/proc/on_catcher_click(turf/location, control, params, user)
	SIGNAL_HANDLER

	if(building_pipes)
		return
	INVOKE_ASYNC(src, PROC_REF(build_pipes), location, user)

/**
 * #build_pipes
 *
 * This is in several steps.
 * Basically, we start off by getting the path from parent to the ending location, then we check if said path exists.
 * If the path exists, we'll start manually placing every pipe down like this:
 * - Check if there's a plasma geyser - if so, we'll place a plasma ending pipe there and stop.
 * - Place an extraction pipe down, everything beyond this is purely just for direction handling.
 * - Check if it's the last one in the list, if so then we won't curve, we'll simply take the direction of the previous pipe and copy it.
 * - Otherwise, we'll check if it's the first one in the list, if so then we'll take the direction of the hub and place it.
 * - If it's neither, then we'll check the direction of the next and previous pipe, and place it accordingly, so diagonals work.
 * Once this is all done, we'll check if our starting point has been a pipe, if so then we'll modify it to fit the direction of the pipe we placed down, to fit.
 *
 * Once all pipes are built, we'll give the component to keep this construction chain going to the last pipe built, and delete ourselves.
 * That is, if we haven't placed the last pipe (at a geyser), and actually placed something down (in which case, we do nothing).
 */
/datum/component/pipe_laying/proc/build_pipes(turf/ending_location, mob/user)
	building_pipes = TRUE
	var/obj/parent_obj = parent
	var/list/pipe_locations = get_path_to(parent, ending_location, max_distance = MAX_PIPE_DISTANCE, exclude=get_turf(get_step(parent_obj, REVERSE_DIR(parent_obj.dir))), diagonal_handling = DIAGONAL_REMOVE_ALL)
	var/obj/structure/liquid_plasma_extraction_pipe/last_placed_pipe
	var/should_delete_ourselves = FALSE
	if(length(pipe_locations))
		for(var/turf/next_location as anything in pipe_locations)
			playsound(user, 'sound/machines/click.ogg', 50, TRUE)
			if(!do_after(pipe_placer, 2 SECONDS, next_location, extra_checks = CALLBACK(src, PROC_REF(holding_pipe_check))))
				break
			playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
			var/obj/structure/new_segment
			var/obj/structure/liquid_plasma_geyser/last_spot = locate() in next_location
			var/spot_in_list = pipe_locations.Find(next_location)
			if(last_spot)
				new_segment = new /obj/structure/liquid_plasma_ending(next_location, part_hub)
				part_hub.last_pipe = new_segment
				should_delete_ourselves = TRUE
				last_placed_pipe = null
			else
				new_segment = new /obj/structure/liquid_plasma_extraction_pipe(next_location, part_hub)
				var/direction_to_place
				if(spot_in_list == length(pipe_locations)) //last one copies the last one as it's trailing
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
			if(start_one_tile_ahead && spot_in_list == 1)
				//we are now changing the direction of the first pipe even though it's already been placed.
				//this requires getting the list of all pipes, getting its location, then the pipe placed before IT was placed.
				//If there isn't one, that means this was the first pipe, so we'll get the turf from the hub instead.
				var/obj/structure/liquid_plasma_extraction_pipe/parent_segment = parent
				var/previous_pipe_in_list = parent_segment.connected_hub.connected_pipes.Find(parent_segment)
				var/turf/previous_pipe_location = (previous_pipe_in_list == 1) ? get_turf(parent_segment.connected_hub) : get_turf(parent_segment.connected_hub.connected_pipes[previous_pipe_in_list - 1])
				var/turf/current_turf_location = get_turf(parent)

				var/current_segment = get_dir(previous_pipe_location, next_location)
				var/previous_direction = get_dir(current_turf_location, previous_pipe_location)
				var/direction_changed_into = current_segment
				if(ISDIAGONALDIR(current_segment) && (NSCOMPONENT(previous_direction)))
					direction_changed_into = REVERSE_DIR(direction_changed_into)
				parent_segment.setDir(direction_changed_into)
				parent_segment.update_appearance(UPDATE_OVERLAYS)
			if(last_spot)
				break

	building_pipes = FALSE
	pipe_locations = null
	clear_click_catch()

	if(last_placed_pipe)
		last_placed_pipe.AddComponent(/datum/component/pipe_laying, part_hub, start_one_tile_ahead = TRUE)
	if(should_delete_ourselves)
		qdel(src)

///Checks if the user is still holding the pipe dispenser that they started the task with in the first place.
/datum/component/pipe_laying/proc/holding_pipe_check()
	var/obj/item/pipe_dispenser/held_item = pipe_placer.get_active_held_item()
	return (held_item == pipe_placing)

///Called when the pipe dispenser moves at all, which includes in the inventory and/or being dropped, instantly clearing everything.
///do_after in build_pipes will cancel itself out, but this also works while you're simply in the stage of looking where to place the pipes down.
/datum/component/pipe_laying/proc/on_dispenser_move(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(clear_click_catch))
