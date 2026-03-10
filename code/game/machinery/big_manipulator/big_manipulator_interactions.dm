/// Runs the next task. Or doesn't.
/obj/machinery/big_manipulator/proc/step_tasks()
	if(!on || IS_STOPPING)
		return
	if(!length(tasks))
		handle_no_work_available()
		return
	var/datum/manipulator_task/next_task = master_tasking.get_next_task(tasks, src)
	if(!next_task)
		handle_no_work_available()
		return
	current_task = next_task
	next_task.run_task(src)

/// Attempts to launch the work cycle. Should only be ran on pressing the "Run" button.
/obj/machinery/big_manipulator/proc/try_kickstart(mob/user)
	if(!on || !anchored || IS_BUSY)
		return FALSE

	if(!use_energy(active_power_usage, force = FALSE))
		on = FALSE
		balloon_alert_to_viewers("not enough power!")
		return FALSE

	next_cycle_scheduled = FALSE
	step_tasks()

/// Safely schedules the next step to prevent overlapping.
/obj/machinery/big_manipulator/proc/schedule_next_cycle(time_seconds = BASE_INTERACTION_TIME)
	if(next_cycle_scheduled || IS_STOPPING)
		return

	if(current_task_state != CURRENT_TASK_IDLE && current_task_state != CURRENT_TASK_NONE)
		return

	next_cycle_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(step_tasks)), time_seconds)

/// Handles the common pattern of waiting and scheduling next cycle when no work can be done.
/obj/machinery/big_manipulator/proc/handle_no_work_available()
	if(IS_STOPPING)
		complete_stopping_task()
		return FALSE

	current_task_state = CURRENT_TASK_IDLE
	current_task = null

	addtimer(CALLBACK(src, PROC_REF(schedule_next_cycle)), CYCLE_SKIP_TIMEOUT)
	return FALSE

/// Rotates the manipulator arm to face the target task's turf.
/obj/machinery/big_manipulator/proc/rotate_to_point(datum/manipulator_task/cargo/target_task, callback_object, callback, type)
	if(IS_STOPPING)
		return

	if(!target_task)
		return FALSE

	var/target_dir = get_dir(get_turf(src), target_task.interaction_turf)
	var/target_angle = dir2angle(target_dir)
	var/current_angle = manipulator_arm.transform.get_angle()
	var/angle_diff = closer_angle_difference(current_angle, target_angle)

	var/num_rotations = round(abs(angle_diff) / 45)
	var/total_rotation_time = num_rotations * BASE_INTERACTION_TIME / speed_multiplier

	start_task_state(type == CURRENT_TASK_MOVING_PICKUP ? CURRENT_TASK_MOVING_PICKUP : CURRENT_TASK_MOVING_DROPOFF, total_rotation_time)

	if(!num_rotations)
		addtimer(CALLBACK(callback_object, callback, target_task), BASE_INTERACTION_TIME)
		return TRUE

	var/rotation_step = 45 * SIGN(angle_diff)
	do_step_rotation(target_task, callback_object, callback, current_angle, target_angle, rotation_step, 0, total_rotation_time)

	return TRUE

/// Does a 45 degree step, animating the claw
/obj/machinery/big_manipulator/proc/do_step_rotation(datum/manipulator_task/cargo/target_task, callback_object, callback, current_angle, target_angle, rotation_step, elapsed_time, total_time)
	if(IS_STOPPING)
		return

	var/angle_diff = closer_angle_difference(current_angle, target_angle)
	if(abs(angle_diff) < abs(rotation_step))
		var/matrix/final_matrix = matrix()
		final_matrix.Turn(target_angle)
		animate(manipulator_arm, transform = final_matrix, time = BASE_INTERACTION_TIME / speed_multiplier)
		addtimer(CALLBACK(callback_object, callback, target_task), BASE_INTERACTION_TIME / speed_multiplier)
		return

	var/next_angle = current_angle + rotation_step
	var/matrix/next_matrix = matrix()
	next_matrix.Turn(next_angle)
	animate(manipulator_arm, transform = next_matrix, time = BASE_INTERACTION_TIME / speed_multiplier)

	elapsed_time += BASE_INTERACTION_TIME / speed_multiplier
	addtimer(CALLBACK(src, PROC_REF(do_step_rotation), target_task, callback_object, callback, next_angle, target_angle, rotation_step, elapsed_time, total_time), BASE_INTERACTION_TIME / speed_multiplier)

/obj/machinery/big_manipulator/proc/try_drop_thing(datum/manipulator_task/cargo/dropoff_base/drop/destination_task)
	var/drop_endpoint = destination_task.find_type_priority()
	var/obj/actual_held_object = held_object?.resolve()

	if(isnull(drop_endpoint))
		return FALSE

	var/atom/drop_target = drop_endpoint
	if(drop_target.atom_storage && actual_held_object && (!drop_target.atom_storage.attempt_insert(actual_held_object, override = TRUE, messages = FALSE)))
		actual_held_object.forceMove(drop_target.drop_location())
		finish_manipulation()
		return TRUE

	actual_held_object?.forceMove(drop_endpoint)
	finish_manipulation()
	return TRUE

/obj/machinery/big_manipulator/proc/try_use_thing(datum/manipulator_task/cargo/interact/destination_task, work_done_at_point = FALSE)
	if(IS_STOPPING)
		return

	var/obj/obj_resolve = held_object?.resolve()
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	var/destination_turf = destination_task.interaction_turf

	if(!obj_resolve || QDELETED(obj_resolve) || obj_resolve.loc != src)
		finish_manipulation()
		return FALSE

	if(!monkey_resolve || !destination_turf)
		finish_manipulation()
		return FALSE

	if(monkey_resolve.loc != src)
		finish_manipulation()
		return FALSE

	var/obj/item/held_item = obj_resolve
	var/atom/type_to_use = destination_task.find_type_priority()

	if(isnull(type_to_use))
		check_for_cycle_end_drop(destination_task, FALSE, work_done_at_point)
		return FALSE

	if(isitem(type_to_use) && !destination_task.check_filters_for_atom(type_to_use))
		check_for_cycle_end_drop(destination_task, FALSE, work_done_at_point)
		return FALSE

	var/original_loc = held_item.loc

	monkey_resolve.put_in_active_hand(held_item)
	if(held_item.GetComponent(/datum/component/two_handed))
		held_item.attack_self(monkey_resolve)

	monkey_resolve.combat_mode = destination_task.worker_combat_mode
	held_item.melee_attack_chain(monkey_resolve, type_to_use, list(RIGHT_CLICK = destination_task.worker_use_rmb ? TRUE : FALSE))
	monkey_resolve.combat_mode = FALSE
	do_attack_animation(destination_turf)
	manipulator_arm.do_attack_animation(destination_turf)

	if(QDELETED(held_item) || !held_item || (held_item.loc != monkey_resolve && held_item.loc != original_loc))
		held_object = null
		manipulator_arm.update_claw(null)
		finish_manipulation()
		return TRUE

	if(held_item.loc == monkey_resolve)
		held_item.forceMove(original_loc)

	check_for_cycle_end_drop(destination_task, TRUE, TRUE)

/obj/machinery/big_manipulator/proc/check_for_cycle_end_drop(datum/manipulator_task/cargo/interact/destination_task, item_used_this_iteration, work_done_at_point = FALSE)
	var/obj/obj_resolve = held_object?.resolve()
	var/turf/drop_turf = destination_task.interaction_turf

	if(!obj_resolve || obj_resolve.loc != src || QDELETED(obj_resolve))
		finish_manipulation()
		return

	if(destination_task.worker_interaction == WORKER_SINGLE_USE && item_used_this_iteration)
		obj_resolve.forceMove(drop_turf)
		obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
		finish_manipulation()
		return

	if(!on)
		finish_manipulation()
		return

	if(item_used_this_iteration)
		addtimer(CALLBACK(src, PROC_REF(try_use_thing), destination_task, TRUE), BASE_INTERACTION_TIME * 2)
		return

	drop_held_after_use(destination_task)

/obj/machinery/big_manipulator/proc/drop_held_after_use(datum/manipulator_task/cargo/interact/destination_task)
	var/obj/obj_resolve = held_object?.resolve()
	var/turf/drop_turf = destination_task.interaction_turf

	switch(destination_task.use_post_interaction)
		if(POST_INTERACTION_DROP_AT_POINT)
			obj_resolve.forceMove(drop_turf)
			obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
			finish_manipulation()

		if(POST_INTERACTION_DROP_AT_MACHINE)
			obj_resolve.forceMove(get_turf(src))
			finish_manipulation()

		if(POST_INTERACTION_DROP_NEXT_FITTING)
			var/datum/manipulator_task/next = master_tasking.get_next_task(tasks, src)
			if(istype(next, /datum/manipulator_task/cargo/dropoff_base))
				rotate_to_point(next, next, TYPE_PROC_REF(/datum/manipulator_task/cargo/dropoff_base, try_dropoff), CURRENT_TASK_MOVING_DROPOFF)
				return
			obj_resolve.forceMove(drop_turf)
			obj_resolve.dir = get_dir(get_turf(obj_resolve), get_turf(src))
			finish_manipulation()

		if(POST_INTERACTION_WAIT)
			schedule_next_cycle()

		else
			schedule_next_cycle()

/obj/machinery/big_manipulator/proc/throw_thing(datum/manipulator_task/cargo/dropoff_base/throw/throw_task)
	var/drop_turf = throw_task.interaction_turf
	var/atom/movable/held_atom = held_object?.resolve()

	held_atom.forceMove(drop_turf)
	do_attack_animation(drop_turf)
	manipulator_arm.do_attack_animation(drop_turf)

	if(isliving(held_atom) && !(obj_flags & EMAGGED))
		held_atom.dir = get_dir(get_turf(held_atom), get_turf(src))
		finish_manipulation()
		return

	held_atom.throw_at(get_edge_target_turf(get_turf(src), get_dir(get_turf(src), get_turf(held_atom))), throw_task.throw_range, 2)
	finish_manipulation()

/obj/machinery/big_manipulator/proc/use_thing_with_empty_hand(datum/manipulator_task/cargo/interact/destination_task)
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	if(isnull(monkey_resolve))
		finish_manipulation()
		return

	var/atom/type_to_use = destination_task.find_type_priority()
	if(isnull(type_to_use))
		check_end_of_use_for_use_with_empty_hand(destination_task, FALSE)
		return

	if(isitem(type_to_use))
		var/obj/item/interact_with_item = type_to_use
		var/resolve_loc = interact_with_item.loc
		monkey_resolve.put_in_active_hand(interact_with_item)
		interact_with_item.attack_self(monkey_resolve)
		interact_with_item.forceMove(resolve_loc)
	else
		monkey_resolve.UnarmedAttack(type_to_use)

	var/turf/dest_turf = destination_task.interaction_turf
	if(dest_turf)
		do_attack_animation(dest_turf)
		manipulator_arm.do_attack_animation(dest_turf)

	check_end_of_use_for_use_with_empty_hand(destination_task, TRUE)

/obj/machinery/big_manipulator/proc/check_end_of_use_for_use_with_empty_hand(datum/manipulator_task/cargo/interact/destination_task, item_was_used = TRUE)
	if(!on || destination_task.worker_interaction != WORKER_EMPTY_USE)
		finish_manipulation()
		return

	if(!item_was_used)
		finish_manipulation()
		return

	addtimer(CALLBACK(src, PROC_REF(use_thing_with_empty_hand), destination_task), BASE_INTERACTION_TIME)

/// Completes the current manipulation action and schedules the next step.
/obj/machinery/big_manipulator/proc/finish_manipulation()
	held_object = null
	manipulator_arm.update_claw(null)
	current_task = null

	end_current_task()

	if(IS_STOPPING)
		complete_stopping_task()
		return

	current_task_state = CURRENT_TASK_IDLE
	schedule_next_cycle()

/// Begins a new task state with the specified type and duration
/obj/machinery/big_manipulator/proc/start_task_state(task_state, duration)
	if(current_task_state == CURRENT_TASK_STOPPING)
		return

	end_current_task()
	current_task_start_time = world.time
	current_task_duration = duration
	current_task_state = task_state
	SStgui.update_uis(src)

/// Ends the current task state
/obj/machinery/big_manipulator/proc/end_current_task()
	current_task_start_time = 0
	current_task_duration = 0
	if(current_task_state == CURRENT_TASK_STOPPING)
		current_task_state = CURRENT_TASK_NONE
	SStgui.update_uis(src)

/// Completes the stopping task and transitions to TASK_NONE
/obj/machinery/big_manipulator/proc/complete_stopping_task()
	on = FALSE
	next_cycle_scheduled = FALSE
	current_task = null
	end_current_task()
	SStgui.update_uis(src)

/// Drop the held atom.
/obj/machinery/big_manipulator/proc/drop_held_atom()
	if(isnull(held_object))
		return
	var/obj/obj_resolve = held_object?.resolve()
	obj_resolve?.forceMove(get_turf(obj_resolve))
	finish_manipulation()
