/// We have no tasks to execute for some reason. Waits for a turf signal to retry.
/obj/machinery/big_manipulator/proc/nothing_ever_happens()
	if(stopping)
		complete_stopping_task()
		return FALSE

	current_task = null
	waiting_for_signal = TRUE
	register_task_turf_signals()

	return FALSE

/// A signal ran or some settings changed; checking if we can run the tasks now.
/obj/machinery/big_manipulator/proc/something_happened()
	next_cycle_scheduled = FALSE
	step_tasks()

/// Runs the next task. Or doesn't.
/obj/machinery/big_manipulator/proc/step_tasks()
	if(!on || stopping)
		return
	next_cycle_scheduled = FALSE
	if(waiting_for_signal)
		unregister_task_turf_signals()
		waiting_for_signal = FALSE
	if(!length(tasks))
		nothing_ever_happens()
		return
	var/datum/manipulator_task/next_task = master_tasking.get_next_task(tasks, src)
	if(!next_task)
		nothing_ever_happens()
		return
	current_task = next_task
	SStgui.update_uis(src)
	next_task.run_task(src)

/// Attempts to launch the work cycle. Should only be ran on pressing the "Run" button.
/obj/machinery/big_manipulator/proc/try_kickstart(mob/user)
	if(!on || !anchored || stopping || current_task != null)
		return FALSE

	if(!use_energy(active_power_usage, force = FALSE))
		on = FALSE
		balloon_alert_to_viewers("not enough power!")
		return FALSE

	next_cycle_scheduled = FALSE
	step_tasks()

/// Safely schedules the next step to prevent overlapping.
/obj/machinery/big_manipulator/proc/schedule_next_cycle(time_seconds = BASE_TASK_DELAY)
	if(next_cycle_scheduled || stopping)
		return

	next_cycle_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(step_tasks)), time_seconds)

/// Rotates the manipulator arm to face the target task's turf.
/obj/machinery/big_manipulator/proc/rotate_to_point(datum/manipulator_task/cargo/target_task, callback_object, callback)
	if(stopping)
		return

	if(!target_task)
		return FALSE

	var/target_dir = get_dir(get_turf(src), target_task.interaction_turf)
	var/target_angle = dir2angle(target_dir)
	var/current_angle = manipulator_arm.transform.get_angle()
	var/angle_diff = closer_angle_difference(current_angle, target_angle)

	var/num_rotations = round(abs(angle_diff) / 45)

	if(!num_rotations)
		var/datum/callback/cb = CALLBACK(callback_object, callback, src)
		cb.Invoke()
		return TRUE

	var/rotation_step = 45 * sign(angle_diff)
	do_step_rotation(target_task, callback_object, callback, current_angle, target_angle, rotation_step)
	return TRUE

/// Does a 45 degree step, animating the claw
/obj/machinery/big_manipulator/proc/do_step_rotation(datum/manipulator_task/cargo/target_task, callback_object, callback, current_angle, target_angle, rotation_step)
	if(stopping)
		return

	var/angle_diff = closer_angle_difference(current_angle, target_angle)
	if(abs(angle_diff) < abs(rotation_step))
		var/matrix/final_matrix = matrix()
		final_matrix.Turn(target_angle)
		animate(manipulator_arm, transform = final_matrix, time = BASE_INTERACTION_TIME / speed_multiplier)
		addtimer(CALLBACK(callback_object, callback, src), BASE_INTERACTION_TIME / speed_multiplier)
		return

	var/next_angle = current_angle + rotation_step
	var/matrix/next_matrix = matrix()
	next_matrix.Turn(next_angle)
	animate(manipulator_arm, transform = next_matrix, time = BASE_INTERACTION_TIME / speed_multiplier)

	addtimer(CALLBACK(src, PROC_REF(do_step_rotation), target_task, callback_object, callback, next_angle, target_angle, rotation_step), BASE_INTERACTION_TIME / speed_multiplier)

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

/obj/machinery/big_manipulator/proc/try_use_thing(datum/manipulator_task/cargo/interact/destination_task)
	if(stopping || use_in_progress)
		return

	use_in_progress = TRUE

	var/obj/obj_resolve = held_object?.resolve()
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	var/destination_turf = destination_task.interaction_turf

	if(!obj_resolve || QDELETED(obj_resolve) || obj_resolve.loc != src)
		use_in_progress = FALSE
		finish_manipulation()
		return

	if(!monkey_resolve || !destination_turf)
		use_in_progress = FALSE
		finish_manipulation()
		return

	if(monkey_resolve.loc != src)
		use_in_progress = FALSE
		finish_manipulation()
		return

	var/obj/item/held_item = obj_resolve
	var/atom/type_to_use = destination_task.find_type_priority(destination_task.skip_anchored, TRUE)

	if(isnull(type_to_use))
		use_in_progress = FALSE
		finish_manipulation()
		return

	if(isitem(type_to_use) && !destination_task.check_filters_for_atom(type_to_use))
		use_in_progress = FALSE
		finish_manipulation()
		return

	if(istype(destination_task, /datum/manipulator_task/cargo/interact) && destination_task.should_use_filters && isitem(type_to_use) && !destination_task.check_filters_for_atom(type_to_use))
		use_in_progress = FALSE
		finish_manipulation()
		return

	var/original_loc = held_item.loc
	var/turf/target_turf = get_turf(type_to_use)

	// Temporarily move monkey adjacent to target for Adjacency() checks
	if(target_turf && get_turf(src) != target_turf)
		var/turf/adjacent_turf = get_step(target_turf, get_dir(target_turf, get_turf(src)))
		if(adjacent_turf && !isclosedturf(adjacent_turf))
			monkey_resolve.forceMove(adjacent_turf)

	monkey_resolve.put_in_active_hand(held_item)
	if(held_item.GetComponent(/datum/component/two_handed))
		held_item.attack_self(monkey_resolve)

	var/old_combat_mode = monkey_resolve.combat_mode
	monkey_resolve.combat_mode = destination_task.worker_combat_mode
	held_item.melee_attack_chain(monkey_resolve, type_to_use, list(RIGHT_CLICK = destination_task.worker_use_rmb ? TRUE : FALSE))
	monkey_resolve.combat_mode = old_combat_mode
	do_attack_animation(destination_turf)
	manipulator_arm.do_attack_animation(destination_turf)

	restore_monkey_tracking(monkey_resolve)

	if(QDELETED(held_item) || !held_item || (held_item.loc != monkey_resolve && held_item.loc != original_loc))
		held_object = null
		manipulator_arm.update_claw(null)
		use_in_progress = FALSE
		finish_manipulation()
		return

	if(held_item.loc == monkey_resolve)
		held_item.forceMove(original_loc)

	use_in_progress = FALSE
	current_task = null
	SStgui.update_uis(src)
	if(stopping)
		complete_stopping_task()
		return
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

	var/atom/type_to_use = destination_task.find_type_priority(destination_task.skip_anchored, TRUE)
	if(isnull(type_to_use))
		finish_manipulation()
		return

	if(destination_task.should_use_filters && isitem(type_to_use) && !destination_task.check_filters_for_atom(type_to_use))
		finish_manipulation()
		return

	// temporarily move monkey adjacent to target for Adjacency() checks
	var/turf/target_turf = get_turf(type_to_use)
	if(target_turf && get_turf(src) != target_turf)
		var/turf/adjacent_turf = get_step(target_turf, get_dir(target_turf, get_turf(src)))
		if(adjacent_turf && !isclosedturf(adjacent_turf))
			monkey_resolve.forceMove(adjacent_turf)

	var/old_combat_mode = monkey_resolve.combat_mode
	monkey_resolve.combat_mode = destination_task.worker_combat_mode
	monkey_resolve.UnarmedAttack(type_to_use, modifiers = list(RIGHT_CLICK = destination_task.worker_use_rmb ? TRUE : FALSE))
	monkey_resolve.combat_mode = old_combat_mode

	var/turf/dest_turf = destination_task.interaction_turf
	if(dest_turf)
		do_attack_animation(dest_turf)
		manipulator_arm.do_attack_animation(dest_turf)

	restore_monkey_tracking(monkey_resolve)

	finish_manipulation()

/// Restores monkey tracking after a temporary move outside src cleared it via Exited.
/obj/machinery/big_manipulator/proc/restore_monkey_tracking(mob/living/carbon/human/species/monkey/monkey)
	if(monkey.loc != src)
		monkey.forceMove(src)
	if(monkey_worker?.resolve())
		return
	monkey_worker = WEAKREF(monkey)
	manipulator_arm.vis_contents += monkey
	monkey.add_offsets(
		type,
		x_add = 32 + manipulator_arm.calculate_item_offset(TRUE, pixels_to_offset = 16),
		y_add = 32 + manipulator_arm.calculate_item_offset(FALSE, pixels_to_offset = 16)
	)

/// Completes the current manipulation action and schedules the next step.
/obj/machinery/big_manipulator/proc/finish_manipulation()
	held_object = null
	manipulator_arm.update_claw(null)
	current_task = null

	SStgui.update_uis(src)

	if(stopping)
		complete_stopping_task()
		return

	schedule_next_cycle()

/// Completes the stopping task and transitions to idle
/obj/machinery/big_manipulator/proc/complete_stopping_task()
	on = FALSE
	stopping = FALSE
	next_cycle_scheduled = FALSE
	current_task = null
	unregister_task_turf_signals()
	waiting_for_signal = FALSE
	SStgui.update_uis(src)

/// Registers enter/exit signals on all unique cargo task turfs.
/obj/machinery/big_manipulator/proc/register_task_turf_signals()
	unregister_task_turf_signals()
	for(var/datum/manipulator_task/cargo/task in tasks)
		if(!task.interaction_turf || (task.interaction_turf in signal_turfs))
			continue
		signal_turfs += task.interaction_turf
		RegisterSignals(task.interaction_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(on_task_turf_changed))

/// Unregisters all previously registered turf signals.
/obj/machinery/big_manipulator/proc/unregister_task_turf_signals()
	for(var/turf/t in signal_turfs)
		UnregisterSignal(t, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	signal_turfs = list()

/// Fires when something enters or leaves a watched task turf.
/obj/machinery/big_manipulator/proc/on_task_turf_changed(datum/source)
	SIGNAL_HANDLER
	if(!on || stopping || !waiting_for_signal)
		return
	something_happened()

/// Drop the held atom.
/obj/machinery/big_manipulator/proc/drop_held_atom()
	if(isnull(held_object))
		return
	var/obj/obj_resolve = held_object?.resolve()
	obj_resolve?.forceMove(get_turf(obj_resolve))
	finish_manipulation()
