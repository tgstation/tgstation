// Interactions moved here to de-clutter the main file

/// Calculates the next interaction point the manipulator should transfer the item to.
/obj/machinery/big_manipulator/proc/find_next_point(tasking_type, transfer_type)
	if(!tasking_type)
		tasking_type = TASKING_PREFER_FIRST

	if(!transfer_type)
		return NONE

	var/list/interaction_points = transfer_type == TRANSFER_TYPE_DROPOFF ? dropoff_points : pickup_points
	if(!length(interaction_points))
		return NONE

	var/roundrobin_history = transfer_type == TRANSFER_TYPE_DROPOFF ? roundrobin_history_dropoff : roundrobin_history_pickup

	switch(tasking_type)
		if(TASKING_PREFER_FIRST)
			for(var/datum/interaction_point/this_point in interaction_points)
				if(this_point.is_available(transfer_type))
					return this_point

			return NONE

		if(TASKING_ROUND_ROBIN)
			var/datum/interaction_point/this_point = interaction_points[roundrobin_history]
			if(this_point.is_available(transfer_type))
				roundrobin_history += 1
				if(roundrobin_history > length(interaction_points))
					roundrobin_history = 1
				return this_point

			var/initial_index = roundrobin_history
			roundrobin_history += 1
			if(roundrobin_history > length(interaction_points))
				roundrobin_history = 1

			while(roundrobin_history != initial_index)
				this_point = interaction_points[roundrobin_history]
				if(this_point.is_available(transfer_type))
					roundrobin_history += 1
					if(roundrobin_history > length(interaction_points))
						roundrobin_history = 1
					return this_point

				roundrobin_history += 1
				if(roundrobin_history > length(interaction_points))
					roundrobin_history = 1
			return NONE

		if(TASKING_STRICT_ROBIN)
			var/datum/interaction_point/this_point = interaction_points[roundrobin_history]
			if(this_point.is_available(transfer_type))
				roundrobin_history += 1
				if(roundrobin_history > length(interaction_points))
					roundrobin_history = 1
				return this_point

			if(status == STATUS_BUSY)
				addtimer(CALLBACK(src, PROC_REF(try_begin_full_cycle)), CYCLE_SKIP_TIMEOUT)
			return NONE

/// Attempts to begin a full work cycle
/obj/machinery/big_manipulator/proc/try_begin_full_cycle()
	if(!on)
		return FALSE

	if(!anchored)
		return FALSE

	if(!use_energy(active_power_usage, force = FALSE))
		on = FALSE
		balloon_alert("not enough power!")
		return FALSE

	cycle_timer_running = FALSE
	try_run_full_cycle()

/// Safely schedules the next cycle attempt
/obj/machinery/big_manipulator/proc/schedule_next_cycle()
	if(cycle_timer_running)
		return
	cycle_timer_running = TRUE
	addtimer(CALLBACK(src, PROC_REF(try_begin_full_cycle)), CYCLE_SKIP_TIMEOUT)

/// Attempts to run a full work cycle
/obj/machinery/big_manipulator/proc/try_run_full_cycle()
	var/datum/interaction_point/origin_point = find_next_point(pickup_tasking, TRANSFER_TYPE_PICKUP)
	if(!origin_point)
		start_task(STATUS_WAITING, CYCLE_SKIP_TIMEOUT)
		schedule_next_cycle()
		return FALSE

	var/turf/origin_turf = origin_point.interaction_turf.resolve()
	var/has_suitable_objects = FALSE
	if(origin_turf)
		for(var/atom/movable/movable_atom in origin_turf.contents)
		if(origin_point.check_filters_for_atom(movable_atom))
			has_suitable_objects = TRUE
			break

	if(!has_suitable_objects)
		start_task(STATUS_WAITING, CYCLE_SKIP_TIMEOUT)
		schedule_next_cycle()
		return FALSE

	rotate_to_point(origin_point, PROC_REF(try_interact_with_origin_point))
	return TRUE

/// Attempts to interact with the origin point (pick up the object)
/obj/machinery/big_manipulator/proc/try_interact_with_origin_point(datum/interaction_point/origin_point, hand_is_empty = FALSE)
	if(!origin_point)
		return FALSE

	var/turf/origin_turf = origin_point.interaction_turf.resolve()
	if(origin_turf)
		for(var/atom/movable/movable_atom in origin_turf.contents)
			if(!origin_point.check_filters_for_atom(movable_atom))
				continue
			if(movable_atom.anchored || HAS_TRAIT(movable_atom, TRAIT_NODROP))
				continue
			var/obj/item/movable_atom_item = movable_atom
			if(movable_atom_item.item_flags & (ABSTRACT|DROPDEL))
				continue
			start_work(movable_atom, hand_is_empty)
			return TRUE

	start_task(STATUS_WAITING, CYCLE_SKIP_TIMEOUT)
	schedule_next_cycle()
	return FALSE

/// Attempts to start a work cycle (pick up the object)
/obj/machinery/big_manipulator/proc/start_work(atom/movable/target, hand_is_empty = FALSE)
	if(!hand_is_empty)
		target.forceMove(src)
		held_object = WEAKREF(target)
		manipulator_arm.update_claw(held_object)

	var/datum/interaction_point/destination_point = find_next_point(dropoff_tasking, TRANSFER_TYPE_DROPOFF) // find the next point

	if(!destination_point)
		SStgui.update_uis(src)
		schedule_next_cycle()
		start_task(STATUS_WAITING, CYCLE_SKIP_TIMEOUT)
		return FALSE

	rotate_to_point(destination_point, PROC_REF(try_interact_with_destination_point))
	return TRUE

/// Attempts to interact with the destination point (drop/use/throw the object)
/obj/machinery/big_manipulator/proc/try_interact_with_destination_point(datum/interaction_point/destination_point, hand_is_empty = FALSE)
	if(!destination_point)
		return FALSE

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
/obj/machinery/big_manipulator/proc/rotate_to_point(datum/interaction_point/target_point, callback)
	if(!target_point)
		return FALSE

	var/target_dir = get_dir(get_turf(src), target_point.interaction_turf.resolve())
	var/target_angle = dir2angle(target_dir)
	var/current_angle = manipulator_arm.transform.get_angle()
	var/angle_diff = closer_angle_difference(current_angle, target_angle)

	var/num_rotations = round(abs(angle_diff) / 45)
	var/total_rotation_time = num_rotations * interaction_delay

	start_task("moving to point", total_rotation_time)

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
		animate(manipulator_arm, transform = final_matrix, time = interaction_delay)
		addtimer(CALLBACK(src, callback, target_point), interaction_delay)
		return

	// Animating a single rotation step

	// YES, this has to be done like that because byond or whatever is stupid and animating a 180+ degree turn
	// fucking fails and squashes the icon vertically (or horizontally, whatever it feels like) instead

	var/next_angle = current_angle + rotation_step
	var/matrix/next_matrix = matrix()
	next_matrix.Turn(next_angle)
	animate(manipulator_arm, transform = next_matrix, time = interaction_delay)

	// Recursively planning the next step (yay recursion :yuppie: call me a madman I LOVE recursion)
	elapsed_time += interaction_delay
	addtimer(CALLBACK(src, PROC_REF(do_step_rotation), target_point, callback, next_angle, target_angle, rotation_step, elapsed_time, total_time), interaction_delay)

/*
  ___         _   _           _   _            ___     _     _
 |   \ ___ __| |_(_)_ _  __ _| |_(_)___ _ _   | _ \___(_)_ _| |_ ___
 | |) / -_|_-<  _| | ' \/ _` |  _| / _ \ ' \  |  _/ _ \ | ' \  _(_-<
 |___/\___/__/\__|_|_||_\__,_|\__|_\___/_||_| |_| \___/_|_||_\__/__/

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
		return TRUE

	actual_held_object.forceMove(drop_endpoint)
	finish_manipulation()
	return TRUE

/// Attempts to use the held object on the atoms of the interaction turf.
///
/// If the interaction turf has an atom that corresponds to the priority settings,
/// it will attempt to use the held item. If it doesn't, it will simply drop the item.
/obj/machinery/big_manipulator/proc/try_use_thing(datum/interaction_point/destination_point, atom/movable/target, hand_is_empty = FALSE)
	var/obj/obj_resolve = held_object?.resolve()
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	var/destination_turf = destination_point.interaction_turf.resolve()

	if(!obj_resolve || !monkey_resolve || !destination_turf) // if something that's supposed to be here is not here anymore
		finish_manipulation()
		return FALSE

	if(!(obj_resolve.loc == src && obj_resolve.loc == monkey_resolve)) // if we don't hold the said item or the monkey isn't buckled
		finish_manipulation()
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
	var/turf/drop_turf = drop_point.interaction_turf.resolve()

	if(drop_point.worker_interaction == WORKER_SINGLE_USE && item_used)
		obj_resolve.forceMove(drop_turf)
		obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
		finish_manipulation()
		return

	if(!on || drop_point.interaction_mode != INTERACT_USE)
		finish_manipulation()
		return

	if(item_used)
		addtimer(CALLBACK(src, PROC_REF(try_use_thing), drop_point), interaction_delay SECONDS)
		return

	finish_manipulation()

/// Throws the held object in the direction of the interaction point.
/obj/machinery/big_manipulator/proc/throw_thing(datum/interaction_point/drop_point, atom/movable/target)
	var/drop_turf = drop_point.interaction_turf.resolve()
	var/throw_range = drop_point.throw_range

	if((!(isitem(target) || isliving(target))) && !(obj_flags & EMAGGED))
		target.forceMove(drop_turf)
		target.dir = get_dir(get_turf(target), get_turf(src))
		finish_manipulation()
		return

	var/obj/object_to_throw = target
	object_to_throw.forceMove(drop_turf)
	object_to_throw.throw_at(get_edge_target_turf(get_turf(src), drop_turf), throw_range, 2)
	do_attack_animation(drop_turf)
	manipulator_arm.do_attack_animation(drop_turf)
	finish_manipulation()

/// Uses the empty hand to interact with objects
/obj/machinery/big_manipulator/proc/use_thing_with_empty_hand(datum/interaction_point/destination_point)
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	if(isnull(monkey_resolve))
		finish_manipulation()
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

	var/turf/dest_turf = destination_point.interaction_turf.resolve()
	if(dest_turf)
		do_attack_animation(dest_turf)
		manipulator_arm.do_attack_animation(dest_turf)
	check_end_of_use_for_use_with_empty_hand(destination_point, TRUE)

/// Checks if we should continue using the empty hand after interaction
/obj/machinery/big_manipulator/proc/check_end_of_use_for_use_with_empty_hand(datum/interaction_point/destination_point, item_was_used = TRUE)
	if(!on || (destination_point.worker_interaction != WORKER_EMPTY_USE && destination_point.interaction_mode == INTERACT_USE))
		finish_manipulation()
		return

	if(!item_was_used)
		finish_manipulation()
		return

	addtimer(CALLBACK(src, PROC_REF(use_thing_with_empty_hand), destination_point), interaction_delay SECONDS)

/// Completes the work cycle and prepares for the next one
/obj/machinery/big_manipulator/proc/end_work()
	end_current_task()
	if(!on)
		return

	schedule_next_cycle()

/// Completes the current manipulation action
/obj/machinery/big_manipulator/proc/finish_manipulation()
	held_object = null
	manipulator_arm.update_claw(null)
	addtimer(CALLBACK(src, PROC_REF(end_work)), interaction_delay SECONDS)
