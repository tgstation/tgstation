/*
  _____        _   _             _  _ _    _
 |_   _|_ _ __| |_(_)_ _  __ _  | || (_)__| |_ ___ _ _ _  _
   | |/ _` (_-< / / | ' \/ _` | | __ | (_-<  _/ _ \ '_| || |
   |_|\__,_/__/_\_\_|_||_\__, | |_||_|_/__/\__\___/_|  \_, |
                         |___/                         |__/
*/

/// Builds an ordered list of interaction points based on tasking strategy
/obj/machinery/big_manipulator/proc/build_ordered_points(list/points, tasking_type, roundrobin_history)
	if(!length(points))
		return list()

	switch(tasking_type)
		if(TASKING_PREFER_FIRST)
			return points.Copy()

		if(TASKING_ROUND_ROBIN, TASKING_STRICT_ROBIN)
			return build_round_robin_order(points, roundrobin_history)

	return points.Copy()

/// Builds round-robin ordered list starting from the given index
/obj/machinery/big_manipulator/proc/build_round_robin_order(list/points, start_index)
	var/list/ordered = list()
	var/safe_index = clamp(start_index, 1, length(points))

	for(var/i = safe_index, i <= length(points), i++)
		ordered += points[i]

	for(var/i = 1, i < safe_index, i++)
		ordered += points[i]

	return ordered

/// Updates round-robin history for the given point and tasking type
/obj/machinery/big_manipulator/proc/update_roundrobin_history(datum/interaction_point/used_point, list/points, tasking_type, roundrobin_history)
	if(tasking_type != TASKING_ROUND_ROBIN)
		return

	var/found_index = points.Find(used_point)
	if(found_index)
		roundrobin_history = found_index + 1
		if(roundrobin_history > length(points))
			roundrobin_history = 1
		return roundrobin_history

	return roundrobin_history


/*
  ___ _    _               ___     _     _
 | _ (_)__| |___  _ _ __  | _ \___(_)_ _| |_ ___
 |  _/ / _| / / || | '_ \ |  _/ _ \ | ' \  _(_-<
 |_| |_\__|_\_\\_,_| .__/ |_| \___/_|_||_\__/__/
                   |_|
*/

/// Finds a suitable pickup candidate that can be delivered to available dropoff points
/obj/machinery/big_manipulator/proc/find_pickup_candidate_for_pickup_point(datum/interaction_point/pickup_point)
	if(!pickup_point?.interaction_turf)
		return null

	var/turf/pickup_turf = pickup_point.interaction_turf
	if(!length(dropoff_points))
		return null

	// Build ordered list of dropoff points according to current tasking
	var/list/ordered_destinations = build_ordered_points(dropoff_points, dropoff_tasking, roundrobin_history_dropoff)

	// For each destination in order, try to find a pickup item that it can accept (if it can)
	for(var/datum/interaction_point/dest_point in ordered_destinations)
		if(!dest_point?.is_valid())
			continue

		var/atom/movable/candidate = find_compatible_candidate(pickup_turf, dest_point)
		if(candidate)
			// Update round-robin history if needed
			roundrobin_history_dropoff = update_roundrobin_history(dest_point, dropoff_points, dropoff_tasking, roundrobin_history_dropoff)
			return candidate

	return null

/// Finds a compatible candidate on the pickup turf for the given destination point
/obj/machinery/big_manipulator/proc/find_compatible_candidate(turf/pickup_turf, datum/interaction_point/dest_point)
	for(var/atom/movable/candidate in pickup_turf.contents)
		if(candidate.anchored || HAS_TRAIT(candidate, TRAIT_NODROP))
			continue

		if(!dest_point.check_filters_for_atom(candidate))
			continue

		if(dest_point.is_available(TRANSFER_TYPE_DROPOFF, candidate))
			return candidate

	return null

/// Checks if a point is available for the given transfer type
/obj/machinery/big_manipulator/proc/is_point_available(datum/interaction_point/point, transfer_type, atom/movable/target)
	if(transfer_type == TRANSFER_TYPE_DROPOFF)
		return point.is_available(transfer_type, target)
	else
		return !!find_pickup_candidate_for_pickup_point(point)

/// Updates the appropriate round-robin history based on transfer type
/obj/machinery/big_manipulator/proc/update_roundrobin_for_transfer(transfer_type, new_index, list/points)
	if(transfer_type == TRANSFER_TYPE_DROPOFF)
		roundrobin_history_dropoff = new_index
	else
		roundrobin_history_pickup = new_index

/// Calculates the next interaction point the manipulator should transfer the item to or pick up it from.
/obj/machinery/big_manipulator/proc/find_next_point(tasking_type, transfer_type)
	if(!tasking_type)
		tasking_type = TASKING_PREFER_FIRST
	if(!transfer_type)
		return NONE

	var/atom/movable/target = held_object?.resolve()
	var/list/interaction_points = transfer_type == TRANSFER_TYPE_DROPOFF ? dropoff_points : pickup_points
	if(!length(interaction_points))
		return NONE

	var/is_dropoff = transfer_type == TRANSFER_TYPE_DROPOFF
	var/roundrobin_history = is_dropoff ? roundrobin_history_dropoff : roundrobin_history_pickup

	switch(tasking_type)
		if(TASKING_PREFER_FIRST)
			return find_first_available_point(interaction_points, transfer_type, target)

		if(TASKING_ROUND_ROBIN)
			return find_round_robin_point(interaction_points, transfer_type, target, roundrobin_history, TRUE)

		if(TASKING_STRICT_ROBIN)
			return find_round_robin_point(interaction_points, transfer_type, target, roundrobin_history, FALSE)

	return NONE

/// Finds the first available point in the list
/obj/machinery/big_manipulator/proc/find_first_available_point(list/points, transfer_type, atom/movable/target)
	for(var/datum/interaction_point/point in points)
		if(is_point_available(point, transfer_type, target))
			return point
	return NONE

/// Finds a point using round-robin logic
/obj/machinery/big_manipulator/proc/find_round_robin_point(list/points, transfer_type, atom/movable/target, roundrobin_history, allow_wrap_around)
	var/list/ordered_points = build_ordered_points(points, TASKING_ROUND_ROBIN, roundrobin_history)

	for(var/datum/interaction_point/point in ordered_points)
		if(is_point_available(point, transfer_type, target))
			var/found_index = points.Find(point)
			if(found_index)
				var/new_index = found_index + 1
				if(new_index > length(points))
					new_index = 1
				update_roundrobin_for_transfer(transfer_type, new_index, points)
			return point

	// For strict robin, don't wrap around if no point is available
	if(!allow_wrap_around)
		schedule_next_cycle()

	return NONE

/// Attempts to launch the work cycle. Should only be ran on pressing the "Run" button.
/obj/machinery/big_manipulator/proc/try_kickstart(mob/user)
	if(!on)
		return FALSE

	if(!anchored)
		return FALSE

	// Check if manipulator is already busy with a task
	if(current_task != CURRENT_TASK_NONE)
		return FALSE

	if(!use_energy(active_power_usage, force = FALSE))
		on = FALSE
		balloon_alert_to_viewers("not enough power!")
		return FALSE

	cycle_timer_running = FALSE
	run_pickup_phase()

/// Safely schedules the next cycle attempt to prevent overlapping.
/obj/machinery/big_manipulator/proc/schedule_next_cycle()
	if(cycle_timer_running)
		return

	// Don't schedule cycles during stopping task
	if(current_task == CURRENT_TASK_STOPPING)
		return

	// Allow scheduling if manipulator is idle, none, or if we have a held object (need to drop it off)
	if(current_task != CURRENT_TASK_IDLE && current_task != CURRENT_TASK_NONE && !held_object)
		return

	cycle_timer_running = TRUE
	if(held_object)
		run_dropoff_phase()
	else
		run_pickup_phase()

/// Handles the common pattern of waiting and scheduling next cycle when no work can be done.
/obj/machinery/big_manipulator/proc/handle_no_work_available()
	// If we're stopping, don't schedule next cycle
	if(current_task == CURRENT_TASK_STOPPING)
		complete_stopping_task()
		return FALSE

	start_task(CURRENT_TASK_IDLE, CYCLE_SKIP_TIMEOUT)
	schedule_next_cycle()
	return FALSE

/// Updates the round robin index for the specified transfer type.
/obj/machinery/big_manipulator/proc/update_roundrobin_index(transfer_type)
	var/list/points = transfer_type == TRANSFER_TYPE_PICKUP ? pickup_points : dropoff_points
	var/current_index = transfer_type == TRANSFER_TYPE_PICKUP ? roundrobin_history_pickup : roundrobin_history_dropoff

	var/new_index = current_index + 1
	if(new_index > length(points))
		new_index = 1

	update_roundrobin_for_transfer(transfer_type, new_index, points)

/// Attempts to run the pickup phase. Selects the next origin point and attempts to pick up an item from it.
/obj/machinery/big_manipulator/proc/run_pickup_phase()
	if(!on)
		return

	cycle_timer_running = FALSE

	var/datum/interaction_point/origin_point = find_next_point(pickup_tasking, TRANSFER_TYPE_PICKUP)
	if(!origin_point) // no origin point - nowhere to begin the cycle from
		return handle_no_work_available()

	var/turf/origin_turf = origin_point.interaction_turf
	if(!origin_turf)
		return

	rotate_to_point(origin_point, PROC_REF(try_interact_with_origin_point), CURRENT_TASK_MOVING_PICKUP)
	return TRUE

/// Attempts to interact with the origin point (pick up the object)
/obj/machinery/big_manipulator/proc/try_interact_with_origin_point(datum/interaction_point/origin_point, hand_is_empty = FALSE)
	// If we're stopping, just finish the task and shut down
	if(current_task == CURRENT_TASK_STOPPING)
		complete_stopping_task()
		return

	start_task(CURRENT_TASK_INTERACTING, 0.2 SECONDS)

	var/turf/origin_turf = origin_point.interaction_turf
	if(!origin_turf)
		return handle_no_work_available()

	var/atom/movable/selected = find_pickup_candidate_for_pickup_point(origin_point) // find a suitable item that matches available destinations
	if(!selected)
		return handle_no_work_available()

	if(selected.anchored || HAS_TRAIT(selected, TRAIT_NODROP))
		return handle_no_work_available()

	var/obj/item/selected_item = selected
	if(selected_item.item_flags & (ABSTRACT|DROPDEL))
		return handle_no_work_available()

	update_roundrobin_index(TRANSFER_TYPE_PICKUP)
	interact_with_origin_point(selected, hand_is_empty)
	return TRUE

/// Attempts to start a work cycle (pick up the object)
/obj/machinery/big_manipulator/proc/interact_with_origin_point(atom/movable/target, hand_is_empty = FALSE)
	if(!hand_is_empty)
		target.forceMove(src)
		held_object = WEAKREF(target)
		manipulator_arm.update_claw(held_object)

	// Schedule the dropoff phase after a successful pickup to avoid overlapping tasks (I hate this)
	if(!hand_is_empty)
		schedule_next_cycle()

/obj/machinery/big_manipulator/proc/run_dropoff_phase()
	// Find the next available destination point that can accept the held item
	var/datum/interaction_point/destination_point = find_next_point(dropoff_tasking, TRANSFER_TYPE_DROPOFF)

	cycle_timer_running = FALSE

	if(!destination_point)
		SStgui.update_uis(src)
		return handle_no_work_available()

	rotate_to_point(destination_point, PROC_REF(try_interact_with_destination_point), CURRENT_TASK_MOVING_DROPOFF)
	return TRUE

/// Attempts to interact with the destination point (drop/use/throw the object)
/obj/machinery/big_manipulator/proc/try_interact_with_destination_point(datum/interaction_point/destination_point, hand_is_empty = FALSE)
	// If we're stopping, just finish the task and shut down
	if(current_task == CURRENT_TASK_STOPPING)
		complete_stopping_task()
		return

	start_task(CURRENT_TASK_INTERACTING, 0.2 SECONDS)

	if(hand_is_empty)
		use_thing_with_empty_hand(destination_point)
		return TRUE

	switch(destination_point.interaction_mode)
		if(INTERACT_DROP)
			try_drop_thing(destination_point)
		if(INTERACT_USE)
			try_use_thing(destination_point)
		if(INTERACT_THROW)
			throw_thing(destination_point)

	return TRUE

/// Rotates the manipulator arm to face the target point.
/obj/machinery/big_manipulator/proc/rotate_to_point(datum/interaction_point/target_point, callback, type)
	if(!target_point)
		return FALSE

	var/target_dir = get_dir(get_turf(src), target_point.interaction_turf)
	var/target_angle = dir2angle(target_dir)
	var/current_angle = manipulator_arm.transform.get_angle()
	var/angle_diff = closer_angle_difference(current_angle, target_angle)

	var/num_rotations = round(abs(angle_diff) / 45)
	var/total_rotation_time = num_rotations * BASE_INTERACTION_TIME / speed_multiplier

	start_task(type == CURRENT_TASK_MOVING_PICKUP ? CURRENT_TASK_MOVING_PICKUP : CURRENT_TASK_MOVING_DROPOFF, total_rotation_time)

	// If the next point is on the same tile, we don't need to rotate at all
	if(num_rotations == 0)
		addtimer(CALLBACK(src, callback, target_point), 0)
		return TRUE

	// Breaking the angle up into 45 degree steps
	var/rotation_step = 45 * SIGN(angle_diff)
	do_step_rotation(target_point, callback, current_angle, target_angle, rotation_step, 0, total_rotation_time)

	return TRUE

/// Does a 45 degree step, animating the claw
/obj/machinery/big_manipulator/proc/do_step_rotation(datum/interaction_point/target_point, callback, current_angle, target_angle, rotation_step, elapsed_time, total_time)
	// Just making sure we're not there already
	var/angle_diff = closer_angle_difference(current_angle, target_angle)
	if(abs(angle_diff) < abs(rotation_step))
		// If this is the last step, doing a precise degree turn
		var/matrix/final_matrix = matrix()
		final_matrix.Turn(target_angle)
		animate(manipulator_arm, transform = final_matrix, time = BASE_INTERACTION_TIME / speed_multiplier)
		addtimer(CALLBACK(src, callback, target_point), BASE_INTERACTION_TIME / speed_multiplier)
		return

	// Animating a single rotation step

	// YES, this has to be done like that because byond or whatever is mother-fucking stupid and `animate`ing a 180+ degree turn
	// fucking fails and instead squashes the icon vertically or horizontally, whichever it feels like this time

	var/next_angle = current_angle + rotation_step
	var/matrix/next_matrix = matrix()
	next_matrix.Turn(next_angle)
	animate(manipulator_arm, transform = next_matrix, time = BASE_INTERACTION_TIME / speed_multiplier)

	// Recursively planning the next step (yay recursion :yuppie: call me a madman I LOVE recursion)
	elapsed_time += BASE_INTERACTION_TIME / speed_multiplier
	addtimer(CALLBACK(src, PROC_REF(do_step_rotation), target_point, callback, next_angle, target_angle, rotation_step, elapsed_time, total_time), BASE_INTERACTION_TIME / speed_multiplier)

/*
  ___                     __  __   ___     _     _
 |   \ _ _ ___ _ __  ___ / _|/ _| | _ \___(_)_ _| |_ ___
 | |) | '_/ _ \ '_ \/ _ \  _|  _| |  _/ _ \ | ' \  _(_-<
 |___/|_| \___/ .__/\___/_| |_|   |_| \___/_|_||_\__/__/
              |_|
*/

/// Moves the item onto the turf.
///
/// If the turf has an atom with fitting `atom_storage` that corresponds to the
/// priority settings, it will attempt to insert the held item.
/obj/machinery/big_manipulator/proc/try_drop_thing(datum/interaction_point/destination_point)
	var/drop_endpoint = destination_point.find_type_priority()
	var/obj/actual_held_object = held_object?.resolve()

	if(isnull(drop_endpoint))
		stack_trace("Interaction point returned no endpoints to transfer the item to.")
		return FALSE

	var/atom/drop_target = drop_endpoint
	if(drop_target.atom_storage && (!drop_target.atom_storage.attempt_insert(actual_held_object, override = TRUE, messages = FALSE)))
		actual_held_object.forceMove(drop_target.drop_location())
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return TRUE

	actual_held_object?.forceMove(drop_endpoint)
	finish_manipulation(TRANSFER_TYPE_DROPOFF)
	return TRUE

/// Attempts to use the held object on the atoms of the interaction turf.
///
/// If the interaction turf has an atom that corresponds to the priority settings,
/// it will attempt to use the held item. If it doesn't, it will simply drop the item.
/obj/machinery/big_manipulator/proc/try_use_thing(datum/interaction_point/destination_point, atom/movable/target, hand_is_empty = FALSE)
	var/obj/obj_resolve = held_object?.resolve()
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	var/destination_turf = destination_point.interaction_turf

	if(!obj_resolve || !monkey_resolve || !destination_turf) // if something that's supposed to be here is not here anymore
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return FALSE

	if(!(obj_resolve.loc == src && monkey_resolve.loc == src)) // if we don't hold the said item or the monkey isn't buckled
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return FALSE

	var/obj/item/held_item = obj_resolve
	var/atom/type_to_use = destination_point.find_type_priority()

	if(isnull(type_to_use))
		check_for_cycle_end_drop(destination_point, FALSE)
		return FALSE

	monkey_resolve.put_in_active_hand(held_item)
	if(held_item.GetComponent(/datum/component/two_handed))
		held_item.attack_self(monkey_resolve)

	held_item.melee_attack_chain(monkey_resolve, type_to_use)
	do_attack_animation(destination_turf)
	manipulator_arm.do_attack_animation(destination_turf)

	check_for_cycle_end_drop(destination_point, TRUE)

/// Checks what should we do with the `held_object` after `USE`-ing it.
/obj/machinery/big_manipulator/proc/check_for_cycle_end_drop(datum/interaction_point/drop_point, item_used = TRUE)
	var/obj/obj_resolve = held_object.resolve()
	var/turf/drop_turf = drop_point.interaction_turf

	if(drop_point.worker_interaction == WORKER_SINGLE_USE && item_used)
		obj_resolve.forceMove(drop_turf)
		obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	if(!on || drop_point.interaction_mode != INTERACT_USE)
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	if(item_used)
		addtimer(CALLBACK(src, PROC_REF(try_use_thing), drop_point), BASE_INTERACTION_TIME)
		return

	finish_manipulation(TRANSFER_TYPE_DROPOFF)

/// Throws the held object in the direction of the interaction point.
/obj/machinery/big_manipulator/proc/throw_thing(datum/interaction_point/drop_point)
	var/drop_turf = drop_point.interaction_turf
	var/throw_range = drop_point.throw_range
	var/atom/movable/held_atom = held_object.resolve()

	if((!(isitem(held_atom) || isliving(held_atom))) && !(obj_flags & EMAGGED))
		held_atom.forceMove(drop_turf)
		held_atom.dir = get_dir(get_turf(held_atom), get_turf(src))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	held_atom.forceMove(drop_turf)
	held_atom.throw_at(get_edge_target_turf(get_turf(src), get_dir(get_turf(held_atom), get_turf(src))), throw_range, 2)
	do_attack_animation(drop_turf)
	manipulator_arm.do_attack_animation(drop_turf)
	finish_manipulation(TRANSFER_TYPE_DROPOFF)

/// Uses the empty hand to interact with objects
/obj/machinery/big_manipulator/proc/use_thing_with_empty_hand(datum/interaction_point/destination_point)
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	if(isnull(monkey_resolve))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	var/atom/type_to_use = destination_point.find_type_priority()
	if(isnull(type_to_use))
		check_end_of_use_for_use_with_empty_hand(destination_point, FALSE)
		return

	// We don't perform an unarmed attack on items because we pick them up duh
	if(isitem(type_to_use))
		var/obj/item/interact_with_item = type_to_use
		var/resolve_loc = interact_with_item.loc
		monkey_resolve.put_in_active_hand(interact_with_item)
		interact_with_item.attack_self(monkey_resolve)
		interact_with_item.forceMove(resolve_loc)
	else
		monkey_resolve.UnarmedAttack(type_to_use)

	var/turf/dest_turf = destination_point.interaction_turf
	if(dest_turf)
		do_attack_animation(dest_turf)
		manipulator_arm.do_attack_animation(dest_turf)
	check_end_of_use_for_use_with_empty_hand(destination_point, TRUE)

/// Checks if we should continue using the empty hand after interaction
/obj/machinery/big_manipulator/proc/check_end_of_use_for_use_with_empty_hand(datum/interaction_point/destination_point, item_was_used = TRUE)
	if(!on || (destination_point.worker_interaction != WORKER_EMPTY_USE && destination_point.interaction_mode == INTERACT_USE))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	if(!item_was_used)
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	addtimer(CALLBACK(src, PROC_REF(use_thing_with_empty_hand), destination_point), BASE_INTERACTION_TIME)

/// Completes the current manipulation action
/obj/machinery/big_manipulator/proc/finish_manipulation(transfer_type = TRANSFER_TYPE_DROPOFF)
	held_object = null
	manipulator_arm.update_claw(null)

	// Update round robin index for dropoff points
	if(transfer_type == TRANSFER_TYPE_DROPOFF)
		update_roundrobin_index(TRANSFER_TYPE_DROPOFF)

	end_current_task()

	if(current_task == CURRENT_TASK_STOPPING)
		complete_stopping_task()
		return

	current_task = CURRENT_TASK_IDLE

	schedule_next_cycle()
