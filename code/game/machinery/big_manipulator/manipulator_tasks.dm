/datum/manipulator_task
	var/name = "task"

/// Returns TRUE if this task can be executed right now.
/datum/manipulator_task/proc/can_run(obj/machinery/big_manipulator/manipulator)
	return FALSE

/// Executes the task.
/datum/manipulator_task/proc/run(obj/machinery/big_manipulator/manipulator)
	return

/datum/manipulator_task/simple/wait/can_run(obj/machinery/big_manipulator/manipulator)
	return TRUE

/datum/manipulator_task/simple/wait/run(obj/machinery/big_manipulator/manipulator)
	return

/datum/manipulator_task/simple/signal/can_run(obj/machinery/big_manipulator/manipulator)
	return TRUE

/datum/manipulator_task/simple/signal/run(obj/machinery/big_manipulator/manipulator)
	return

/// Base class for tasks that operate on a turf.
/datum/manipulator_task/cargo
	/// The turf this task operates on.
	var/turf/interaction_turf
	/// Should we check our filters while interacting with this point?
	var/should_use_filters = FALSE
	/// Which items are supposed to be picked up or interacted with.
	var/list/atom_filters = list()
	/// Which object category should the filters be looking out for.
	var/filtering_mode = TAKE_ITEMS
	/// List of types that can be picked up from this point.
	var/list/type_filters = list(
		/obj/item,
		/obj/structure/closet,
	)
	/// Influences which interaction endpoints are preferred.
	var/list/interaction_priorities = list()

/datum/manipulator_task/cargo/New(turf/new_turf, manipulator_tier)
	if(!new_turf)
		stack_trace("New manipulator task created with no valid turf reference passed.")
		qdel(src)
		return

	if(isclosedturf(new_turf))
		qdel(src)
		return

	interaction_turf = new_turf
	interaction_priorities = fill_priority_list(manipulator_tier)

/// Fills the interaction endpoint priority list. Override in subtypes.
/datum/manipulator_task/cargo/proc/fill_priority_list(manipulator_tier)
	return list()

/// Finds the highest-priority atom on the interaction turf.
/datum/manipulator_task/cargo/proc/find_type_priority()
	var/list/turf_contents = interaction_turf.contents

	var/atom/movable/best_candidate = null
	var/best_priority_index = INFINITY

	for(var/atom/movable/thing as anything in turf_contents)
		for(var/i in 1 to length(interaction_priorities))
			if(i >= best_priority_index)
				break

			var/datum/manipulator_priority/prio = interaction_priorities[i]

			if(!prio.active)
				continue

			if(prio.atom_typepath == /turf)
				if(i < best_priority_index)
					best_candidate = interaction_turf
					best_priority_index = i
				continue

			if(!istype(thing, prio.atom_typepath))
				continue

			if(isliving(thing))
				var/mob/living/L = thing
				if(L.stat == DEAD)
					continue

			best_candidate = thing
			best_priority_index = i

			if(best_priority_index == 1)
				return best_candidate
			break

	return best_candidate

/// Moves the priority at the given index 1 step higher.
/datum/manipulator_task/cargo/proc/move_priority_up_by_index(index)
	if(!index)
		return FALSE
	interaction_priorities.Swap(index, index + 1)
	return TRUE

/// Toggles the priority's active param. Sets to TRUE if reset is TRUE.
/datum/manipulator_task/cargo/proc/tick_priority_by_index(index, reset = FALSE)
	var/datum/manipulator_priority/target_priority = interaction_priorities[index + 1]
	if(reset)
		target_priority.active = TRUE
	else
		target_priority.active = !target_priority.active
	return TRUE

/// Checks if the task's turf is valid.
/datum/manipulator_task/cargo/proc/is_valid()
	if(!interaction_turf)
		return FALSE
	return !isclosedturf(interaction_turf)

/// Checks if the passed movable atom fits the filters.
/datum/manipulator_task/cargo/proc/check_filters_for_atom(atom/movable/target)
	if(!target || target.anchored || HAS_TRAIT(target, TRAIT_NODROP))
		return FALSE

	switch(filtering_mode)
		if(TAKE_CLOSETS)
			return iscloset(target)

		if(TAKE_HUMANS)
			return ishuman(target)

		if(TAKE_ITEMS)
			if(!should_use_filters)
				return isitem(target)

			for(var/filter_path in atom_filters)
				if(istype(target, filter_path))
					return TRUE
			return FALSE

	return FALSE

/datum/manipulator_task/cargo/can_run(obj/machinery/big_manipulator/manipulator)
	return is_valid()

/datum/manipulator_task/cargo/run(obj/machinery/big_manipulator/manipulator)
	return

/datum/manipulator_task/cargo/Destroy()
	interaction_turf = null
	QDEL_LIST(interaction_priorities)
	return ..()

// ===== PICKUP =====

/datum/manipulator_task/cargo/pickup
	name = "pickup point"
	/// Whether the manipulator should wait for a valid dropoff before picking up.
	var/pickup_eagerness = PICKUP_CAN_WAIT

/datum/manipulator_task/cargo/pickup/fill_priority_list(manipulator_tier)
	return list() // pickup doesn't use interaction priorities

/datum/manipulator_task/cargo/pickup/can_run(obj/machinery/big_manipulator/manipulator)
	if(!..())
		return FALSE

	if(manipulator.held_object)
		return FALSE

	for(var/atom/movable/candidate as anything in interaction_turf.contents)
		if(!check_filters_for_atom(candidate))
			continue

		if(pickup_eagerness == PICKUP_EAGER)
			return TRUE

		for(var/datum/manipulator_task/cargo/dropoff/dest as anything in manipulator.tasks)
			if(dest.can_accept(candidate))
				return TRUE

	return FALSE

/datum/manipulator_task/cargo/pickup/run(obj/machinery/big_manipulator/manipulator)
	manipulator.rotate_to_point(src, PROC_REF(try_pickup), CURRENT_TASK_MOVING_PICKUP)

/// Called after rotating to the pickup turf.
/datum/manipulator_task/cargo/pickup/proc/try_pickup(obj/machinery/big_manipulator/manipulator)
	var/atom/movable/selected = find_pickup_candidate(manipulator)
	if(!selected)
		manipulator.handle_no_work_available()
		return

	if(selected.anchored || HAS_TRAIT(selected, TRAIT_NODROP))
		manipulator.handle_no_work_available()
		return

	if(isitem(selected))
		var/obj/item/selected_item = selected
		if(selected_item.item_flags & (ABSTRACT|DROPDEL))
			manipulator.handle_no_work_available()
			return

	manipulator.start_task_state(CURRENT_TASK_INTERACTING, 0.2 SECONDS)
	selected.forceMove(manipulator)
	manipulator.held_object = WEAKREF(selected)
	manipulator.manipulator_arm.update_claw(manipulator.held_object)
	manipulator.schedule_next_cycle()

/// Finds a suitable candidate on the turf that has a valid dropoff destination.
/datum/manipulator_task/cargo/pickup/proc/find_pickup_candidate(obj/machinery/big_manipulator/manipulator)
	var/list/candidates = list()

	for(var/atom/movable/candidate as anything in interaction_turf.contents)
		if(candidate.anchored || HAS_TRAIT(candidate, TRAIT_NODROP))
			continue
		if(!check_filters_for_atom(candidate))
			continue
		for(var/datum/manipulator_task/cargo/dropoff/dest as anything in manipulator.tasks)
			if(dest.can_accept(candidate))
				candidates += candidate
				break

	if(!length(candidates))
		return null

	return manipulator.master_tasking.get_next_candidate(candidates)

// ===== DROPOFF =====

/datum/manipulator_task/cargo/dropoff
	name = "dropoff point"
	/// How should this point be interacted with?
	var/interaction_mode = INTERACT_DROP
	/// How far should the manipulator throw the object?
	var/throw_range = 1
	/// Should the manipulator put items on this point if there are already such items on the turf?
	var/overflow_status = POINT_OVERFLOW_ALLOWED
	/// How should the monkey worker interact with this point?
	var/worker_interaction = WORKER_NORMAL_USE
	/// What should the manipulator do when there's nothing to USE the held item on anymore?
	var/use_post_interaction = POST_INTERACTION_DROP_AT_POINT
	/// Whether the worker will use combat mode.
	var/worker_combat_mode = FALSE
	/// Whether the worker will simulate RMB.
	var/worker_use_rmb = FALSE

/datum/manipulator_task/cargo/dropoff/fill_priority_list(manipulator_tier)
	var/list/priorities_to_set = new /list((manipulator_tier == 4 ? 5 : 4))

	switch(interaction_mode)
		if(INTERACT_DROP)
			priorities_to_set[1] = new /datum/manipulator_priority/drop/in_storage
			priorities_to_set[2] = new /datum/manipulator_priority/drop/on_floor

		if(INTERACT_USE)
			priorities_to_set[1] = new /datum/manipulator_priority/interact/with_living
			priorities_to_set[2] = new /datum/manipulator_priority/interact/with_structure
			priorities_to_set[3] = new /datum/manipulator_priority/interact/with_machinery
			priorities_to_set[4] = new /datum/manipulator_priority/interact/with_items

			if(manipulator_tier == 4)
				priorities_to_set[5] = new /datum/manipulator_priority/interact/with_vehicles

	return priorities_to_set

/// Checks if this dropoff task can accept the given atom.
/datum/manipulator_task/cargo/dropoff/proc/can_accept(atom/movable/target)
	if(!is_valid())
		return FALSE

	if(should_use_filters && !check_filters_for_atom(target))
		return FALSE

	if(interaction_mode != INTERACT_DROP)
		return TRUE

	var/list/atoms_on_the_turf = interaction_turf.contents
	switch(overflow_status)
		if(POINT_OVERFLOW_ALLOWED)
			if(!should_use_filters)
				return TRUE

		if(POINT_OVERFLOW_FILTERS)
			for(var/atom/movable/movable_atom as anything in atoms_on_the_turf)
				if(check_filters_for_atom(movable_atom))
					return FALSE

		if(POINT_OVERFLOW_HELD)
			for(var/atom/movable/movable_atom as anything in atoms_on_the_turf)
				if(istype(movable_atom, target?.type))
					return FALSE

		if(POINT_OVERFLOW_FORBIDDEN)
			if(locate(/obj/item) in atoms_on_the_turf)
				return FALSE

	return TRUE

/datum/manipulator_task/cargo/dropoff/can_run(obj/machinery/big_manipulator/manipulator)
	if(!..())
		return FALSE

	var/atom/movable/target = manipulator.held_object?.resolve()
	if(!target)
		return FALSE

	return can_accept(target)

/datum/manipulator_task/cargo/dropoff/run(obj/machinery/big_manipulator/manipulator)
	manipulator.rotate_to_point(src, PROC_REF(try_dropoff), CURRENT_TASK_MOVING_DROPOFF)

/// Called after rotating to the dropoff turf.
/datum/manipulator_task/cargo/dropoff/proc/try_dropoff(obj/machinery/big_manipulator/manipulator)
	var/obj/actual_held_object = manipulator.held_object?.resolve()
	if(!actual_held_object || actual_held_object.loc != manipulator)
		manipulator.handle_no_work_available()
		return FALSE

	manipulator.start_task_state(CURRENT_TASK_INTERACTING, 0.2 SECONDS)

	switch(interaction_mode)
		if(INTERACT_DROP)
			manipulator.try_drop_thing(src)
		if(INTERACT_USE)
			manipulator.try_use_thing(src)
		if(INTERACT_THROW)
			manipulator.throw_thing(src)

	return TRUE

// ===== INTERACT =====

/datum/manipulator_task/cargo/interact
	name = "interaction point"
	/// How should the monkey worker interact with this point?
	var/worker_interaction = WORKER_NORMAL_USE
	/// What should the manipulator do when there's nothing to USE the held item on anymore?
	var/use_post_interaction = POST_INTERACTION_DROP_AT_POINT
	/// Whether the worker will use combat mode.
	var/worker_combat_mode = FALSE
	/// Whether the worker will simulate RMB.
	var/worker_use_rmb = FALSE

/datum/manipulator_task/cargo/interact/fill_priority_list(manipulator_tier)
	var/list/priorities_to_set = new /list((manipulator_tier == 4 ? 5 : 4))

	priorities_to_set[1] = new /datum/manipulator_priority/interact/with_living
	priorities_to_set[2] = new /datum/manipulator_priority/interact/with_structure
	priorities_to_set[3] = new /datum/manipulator_priority/interact/with_machinery
	priorities_to_set[4] = new /datum/manipulator_priority/interact/with_items

	if(manipulator_tier == 4)
		priorities_to_set[5] = new /datum/manipulator_priority/interact/with_vehicles

	return priorities_to_set

/datum/manipulator_task/cargo/interact/can_run(obj/machinery/big_manipulator/manipulator)
	if(!..())
		return FALSE
	return find_type_priority() != null

/datum/manipulator_task/cargo/interact/run(obj/machinery/big_manipulator/manipulator)
	manipulator.rotate_to_point(src, PROC_REF(try_interact), CURRENT_TASK_MOVING_DROPOFF)

/// Called after rotating to the interact turf.
/datum/manipulator_task/cargo/interact/proc/try_interact(obj/machinery/big_manipulator/manipulator)
	manipulator.start_task_state(CURRENT_TASK_INTERACTING, 0.2 SECONDS)

	var/atom/movable/held = manipulator.held_object?.resolve()
	if(held)
		manipulator.try_use_thing(src)
	else
		manipulator.use_thing_with_empty_hand(src)
