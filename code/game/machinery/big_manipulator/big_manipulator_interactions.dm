/// Selects which atom to pick up from this point for interaction with available dropoff points based on the dropoff points.
/obj/machinery/big_manipulator/proc/find_pickup_candidate_for_pickup_point(datum/interaction_point/pickup_point)
	if(!pickup_point)
		return null

	var/turf/pickup_turf = pickup_point.interaction_turf
	if(!pickup_turf)
		return null

	var/list/candidates = list()
	for(var/atom/movable/candidate as anything in pickup_turf.contents)
		if(candidate.anchored || HAS_TRAIT(candidate, TRAIT_NODROP) || move_resist > MOVE_FORCE_STRONG)
			continue

		if(!pickup_point.check_filters_for_atom(candidate))
			continue

		for(var/datum/interaction_point/dest_point as anything in dropoff_points)
			if(!dest_point || !dest_point.is_valid())
				continue
			if(!dest_point.check_filters_for_atom(candidate))
				continue
			if(dest_point.is_available(TRANSFER_TYPE_DROPOFF, candidate))
				candidates += candidate
				break

	if(!length(candidates))
		return null

	return pickup_strategy.get_next_candidate(candidates)

/// Calculates the next interaction point the manipulator should transfer the item to or pick up it from.
/obj/machinery/big_manipulator/proc/find_next_point(transfer_type)
	if(!transfer_type)
		return NONE

	var/atom/movable/target = held_object?.resolve()
	if(isnull(target) && transfer_type == TRANSFER_TYPE_DROPOFF)
		return NONE

	var/list/interaction_points = transfer_type == TRANSFER_TYPE_DROPOFF ? dropoff_points : pickup_points
	if(!length(interaction_points))
		return NONE

	var/datum/tasking_strategy/strategy = transfer_type == TRANSFER_TYPE_DROPOFF ? dropoff_strategy : pickup_strategy
	var/datum/callback/availability_callback = transfer_type == TRANSFER_TYPE_DROPOFF ? CALLBACK(src, PROC_REF(check_dropoff_availability)) : CALLBACK(src, PROC_REF(check_pickup_availability))

	return strategy.get_next_available(interaction_points, target, transfer_type, availability_callback)

/// Attempts to launch the work cycle. Should only be ran on pressing the "Run" button.
/obj/machinery/big_manipulator/proc/try_kickstart(mob/user)
	if(!on || !anchored || IS_BUSY)
		return FALSE

	if(!use_energy(active_power_usage, force = FALSE))
		on = FALSE
		balloon_alert_to_viewers("not enough power!")
		return FALSE

	next_cycle_scheduled = FALSE
	run_pickup_phase()

/// Safely schedules the next cycle attempt to prevent overlapping.
/obj/machinery/big_manipulator/proc/schedule_next_cycle()
	if(next_cycle_scheduled || IS_STOPPING)
		return

	// Allow scheduling if manipulator is idle, none, or if we have a held object (need to drop it off)
	if(current_task != CURRENT_TASK_IDLE && current_task != CURRENT_TASK_NONE && !held_object)
		return

	next_cycle_scheduled = TRUE
	if(held_object)
		run_dropoff_phase()
	else
		run_pickup_phase()

/// Handles the common pattern of waiting and scheduling next cycle when no work can be done.
/obj/machinery/big_manipulator/proc/handle_no_work_available()
	// If we're stopping, don't schedule next cycle
	if(IS_STOPPING)
		complete_stopping_task()
		return FALSE

	current_task = CURRENT_TASK_IDLE

	addtimer(CALLBACK(src, PROC_REF(schedule_next_cycle)), CYCLE_SKIP_TIMEOUT)
	return FALSE

/obj/machinery/big_manipulator/proc/check_pickup_availability(datum/interaction_point/point, atom/movable/target, transfer_type)
	if(!point)
		return FALSE

	var/turf/pickup_turf = point.interaction_turf
	if(!pickup_turf)
		return FALSE

	for(var/atom/movable/candidate as anything in pickup_turf.contents)
		if(!candidate.anchored && !HAS_TRAIT(candidate, TRAIT_NODROP))
			return TRUE

	return FALSE

/obj/machinery/big_manipulator/proc/check_dropoff_availability(datum/interaction_point/point, atom/movable/target, transfer_type)
	return point.is_available(transfer_type, target)

/// Attempts to run the pickup phase. Selects the next origin point and attempts to pick up an item from it.
/obj/machinery/big_manipulator/proc/run_pickup_phase()
	if(!on || IS_STOPPING)
		return

	next_cycle_scheduled = FALSE

	var/datum/interaction_point/origin_point = find_next_point(TRANSFER_TYPE_PICKUP)

	if(!origin_point)
		return handle_no_work_available()

	rotate_to_point(origin_point, PROC_REF(try_interact_with_origin_point), CURRENT_TASK_MOVING_PICKUP)
	return TRUE

/// Attempts to interact with the origin point (pick up the object)
/obj/machinery/big_manipulator/proc/try_interact_with_origin_point(datum/interaction_point/origin_point, hand_is_empty = FALSE)
	// If we're stopping, just finish the task and shut down
	if(IS_STOPPING)
		complete_stopping_task()
		return

	if(!origin_point.interaction_turf)
		return handle_no_work_available()

	var/atom/movable/selected = find_pickup_candidate_for_pickup_point(origin_point) // find a suitable item that matches available destinations
	if(!selected)
		return handle_no_work_available()

	if(selected.anchored || HAS_TRAIT(selected, TRAIT_NODROP))
		return handle_no_work_available()

	if(isitem(selected))
		var/obj/item/selected_item = selected
		if(selected_item.item_flags & (ABSTRACT|DROPDEL))
			return handle_no_work_available()

	start_task(CURRENT_TASK_INTERACTING, 0.2 SECONDS)
	interact_with_origin_point(selected, hand_is_empty)
	return TRUE

/// Attempts to start a work cycle (pick up the object)
/obj/machinery/big_manipulator/proc/interact_with_origin_point(atom/movable/target, hand_is_empty = FALSE)
	if(!hand_is_empty)
		target.forceMove(src)
		held_object = WEAKREF(target)
		manipulator_arm.update_claw(held_object)

	// Schedule the dropoff phase after a successful pickup to avoid overlapping tasks
	if(!hand_is_empty)
		schedule_next_cycle()

/obj/machinery/big_manipulator/proc/run_dropoff_phase()
	// Find the next available destination point that can accept the held item
	var/datum/interaction_point/destination_point = find_next_point(TRANSFER_TYPE_DROPOFF)

	next_cycle_scheduled = FALSE

	if(!destination_point)
		return handle_no_work_available()

	rotate_to_point(destination_point, PROC_REF(try_interact_with_destination_point), CURRENT_TASK_MOVING_DROPOFF)
	return TRUE

/// Attempts to interact with the destination point (drop/use/throw the object)
/obj/machinery/big_manipulator/proc/try_interact_with_destination_point(datum/interaction_point/destination_point, hand_is_empty = FALSE)
	// If we're stopping, just finish the task and shut down
	if(IS_STOPPING)
		complete_stopping_task()
		return FALSE

	start_task(CURRENT_TASK_INTERACTING, 0.2 SECONDS)

	if(hand_is_empty)
		use_thing_with_empty_hand(destination_point)
		return TRUE

	var/obj/actual_held_object = held_object?.resolve()
	if(actual_held_object.loc != src)
		handle_no_work_available()
		return FALSE

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
	if(IS_STOPPING)
		return

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
	if(!num_rotations)
		addtimer(CALLBACK(src, callback, target_point), BASE_INTERACTION_TIME)
		return TRUE

	// Breaking the angle up into 45 degree steps
	var/rotation_step = 45 * SIGN(angle_diff)
	do_step_rotation(target_point, callback, current_angle, target_angle, rotation_step, 0, total_rotation_time)

	return TRUE

/// Does a 45 degree step, animating the claw
/obj/machinery/big_manipulator/proc/do_step_rotation(datum/interaction_point/target_point, callback, current_angle, target_angle, rotation_step, elapsed_time, total_time)
	if(IS_STOPPING)
		return

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

	// YES, this has to be done like that because byond or whatever is stupid and `animate`ing a 180+ degree turn
	// fucking fails and squashes the icon vertically (or horizontally, whichever it feels like) instead

	var/next_angle = current_angle + rotation_step
	var/matrix/next_matrix = matrix()
	next_matrix.Turn(next_angle)
	animate(manipulator_arm, transform = next_matrix, time = BASE_INTERACTION_TIME / speed_multiplier)

	// Recursively planning the next step (yay recursion :yuppie: call me a madman I LOVE recursion)
	elapsed_time += BASE_INTERACTION_TIME / speed_multiplier
	addtimer(CALLBACK(src, PROC_REF(do_step_rotation), target_point, callback, next_angle, target_angle, rotation_step, elapsed_time, total_time), BASE_INTERACTION_TIME / speed_multiplier)

/// Moves the item onto the turf.
///
/// If the turf has an atom with fitting `atom_storage` that corresponds to the
/// priority settings, it will attempt to insert the held item.
/obj/machinery/big_manipulator/proc/try_drop_thing(datum/interaction_point/destination_point)
	var/drop_endpoint = destination_point.find_type_priority()
	var/obj/actual_held_object = held_object?.resolve()

	if(isnull(drop_endpoint))
		return FALSE

	var/atom/drop_target = drop_endpoint
	if(drop_target.atom_storage && actual_held_object && (!drop_target.atom_storage.attempt_insert(actual_held_object, override = TRUE, messages = FALSE)))
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
/obj/machinery/big_manipulator/proc/try_use_thing(datum/interaction_point/destination_point, work_done_at_point = FALSE)
	if(IS_STOPPING)
		return

	var/obj/obj_resolve = held_object?.resolve()
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	var/destination_turf = destination_point.interaction_turf

	if(!obj_resolve || QDELETED(obj_resolve) || obj_resolve.loc != src)
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return FALSE

	if(!monkey_resolve || !destination_turf)
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return FALSE

	if(!(monkey_resolve.loc == src))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return FALSE

	var/obj/item/held_item = obj_resolve
	var/atom/type_to_use = destination_point.find_type_priority()

	if(isnull(type_to_use))
		check_for_cycle_end_drop(destination_point, FALSE, work_done_at_point)
		return FALSE

	if(isitem(type_to_use) && !destination_point.check_filters_for_atom(type_to_use))
		check_for_cycle_end_drop(destination_point, FALSE, work_done_at_point)
		return FALSE

	var/original_loc = held_item.loc

	monkey_resolve.put_in_active_hand(held_item)
	if(held_item.GetComponent(/datum/component/two_handed))
		held_item.attack_self(monkey_resolve)

	var/use_rmb = destination_point.worker_use_rmb
	var/use_combat = destination_point.worker_combat_mode

	monkey_resolve.combat_mode = use_combat
	held_item.melee_attack_chain(monkey_resolve, type_to_use, list(RIGHT_CLICK = use_rmb ? TRUE : FALSE))
	monkey_resolve.combat_mode = FALSE
	do_attack_animation(destination_turf)
	manipulator_arm.do_attack_animation(destination_turf)

	// if we destroyed the item while using it OR something else uncanny happened to it and it's GONE
	if(QDELETED(held_item) || !held_item || (held_item.loc != monkey_resolve && held_item.loc != original_loc))
		held_object = null
		manipulator_arm.update_claw(null)
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return TRUE

	if(held_item.loc == monkey_resolve)
		held_item.forceMove(original_loc)

	check_for_cycle_end_drop(destination_point, TRUE, TRUE)

/// Checks what should we do with the `held_object` after `USE`-ing it.
/obj/machinery/big_manipulator/proc/check_for_cycle_end_drop(datum/interaction_point/drop_point, item_used_this_iteration, work_done_at_point = FALSE)
	var/obj/obj_resolve = held_object?.resolve()
	var/turf/drop_turf = drop_point.interaction_turf

	if(!obj_resolve || obj_resolve.loc != src || QDELETED(obj_resolve))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	if(drop_point.worker_interaction == WORKER_SINGLE_USE && item_used_this_iteration)
		obj_resolve.forceMove(drop_turf)
		obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	if(!on || drop_point.interaction_mode != INTERACT_USE)
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	if(item_used_this_iteration)
		addtimer(CALLBACK(src, PROC_REF(try_use_thing), drop_point, TRUE), BASE_INTERACTION_TIME * 2)
		return

	switch(drop_point.use_post_interaction)
		if(POST_INTERACTION_DROP_AT_POINT)
			obj_resolve.forceMove(drop_turf)
			obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
			finish_manipulation(TRANSFER_TYPE_DROPOFF)
			return

		if(POST_INTERACTION_DROP_AT_MACHINE)
			obj_resolve.forceMove(get_turf(src))
			finish_manipulation(TRANSFER_TYPE_DROPOFF)
			return

		if(POST_INTERACTION_DROP_NEXT_FITTING)
			var/datum/interaction_point/next = find_next_point(TRANSFER_TYPE_DROPOFF)
			if(next)
				rotate_to_point(next, PROC_REF(try_interact_with_destination_point), CURRENT_TASK_MOVING_DROPOFF)
				return
			obj_resolve.forceMove(drop_turf)
			obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
			finish_manipulation(TRANSFER_TYPE_DROPOFF)
			return

		if(POST_INTERACTION_WAIT)
			schedule_next_cycle()
			return

	schedule_next_cycle()

/// Throws the held object in the direction of the interaction point.
/obj/machinery/big_manipulator/proc/throw_thing(datum/interaction_point/drop_point)
	var/drop_turf = drop_point.interaction_turf
	var/item_throw_range = drop_point.throw_range
	var/atom/movable/held_atom = held_object?.resolve()

	held_atom.forceMove(drop_turf)
	do_attack_animation(drop_turf)
	manipulator_arm.do_attack_animation(drop_turf)

	if(((isliving(held_atom))) && !(obj_flags & EMAGGED))
		held_atom.dir = get_dir(get_turf(held_atom), get_turf(src))
		finish_manipulation(TRANSFER_TYPE_DROPOFF)
		return

	held_atom.throw_at(get_edge_target_turf(get_turf(src), get_dir(get_turf(src), get_turf(held_atom))), item_throw_range, 2)
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

	end_current_task()

	if(IS_STOPPING)
		complete_stopping_task()
		return

	current_task = CURRENT_TASK_IDLE

	schedule_next_cycle()
