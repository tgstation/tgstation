/datum/manipulator_task
	var/name = "task"

/datum/manipulator_task/proc/can_run(obj/machinery/big_manipulator/manipulator)
	return FALSE

/datum/manipulator_task/proc/run_task(obj/machinery/big_manipulator/manipulator)
	return

/datum/manipulator_task/proc/serialize()
	return list("type" = type)

/datum/manipulator_task/New(...)
	..()
	return

// ===== WAIT =====

/datum/manipulator_task/simple/wait
	name = "wait"
	var/time_seconds = 1

/datum/manipulator_task/simple/wait/can_run(obj/machinery/big_manipulator/manipulator)
	for(var/datum/manipulator_task/cargo/task in manipulator.tasks)
		if(task.can_run(manipulator))
			return TRUE
	return FALSE

/datum/manipulator_task/simple/wait/run_task(obj/machinery/big_manipulator/manipulator)
	manipulator.schedule_next_cycle(time_seconds SECONDS)

/datum/manipulator_task/simple/wait/serialize()
	var/list/data = ..()
	data["time_seconds"] = time_seconds
	return data

/datum/manipulator_task/simple/wait/New(..., serialized_data)
	..()
	if(serialized_data)
		time_seconds = serialized_data["time_seconds"]
	return

// ===== BASE CARGO =====

/datum/manipulator_task/cargo
	var/turf/interaction_turf
	var/offset_dx
	var/offset_dy
	var/should_use_filters = FALSE
	var/list/atom_filters = list()
	var/filtering_mode = TAKE_ITEMS
	var/list/type_filters = list(
		/obj/item,
		/obj/structure/closet,
	)
	var/list/interaction_priorities = list()

/datum/manipulator_task/cargo/New(turf/new_turf, manipulator_tier, serialized_data)
	if(serialized_data)
		var/list/offset = serialized_data["offset"]
		if(islist(offset))
			offset_dx = offset["dx"]
			offset_dy = offset["dy"]
		if(new_turf)
			interaction_turf = new_turf

		should_use_filters = !!serialized_data["should_use_filters"]
		atom_filters = serialized_data["atom_filters"] || list()
		filtering_mode = serialized_data["filtering_mode"]
		type_filters = serialized_data["type_filters"] || list()

		var/list/prios_data = serialized_data["interaction_priorities"]
		if(islist(prios_data))
			interaction_priorities = list()
			for(var/list/prio_data as anything in prios_data)
				if(!islist(prio_data))
					continue
				var/prio_type = prio_data["type"]
				if(!ispath(prio_type, /datum/manipulator_priority))
					continue
				var/datum/manipulator_priority/prio = new prio_type
				prio.active = !!prio_data["active"]
				interaction_priorities += prio

		..()
		return

	if(!new_turf)
		stack_trace("New manipulator task created with no valid turf reference passed.")
		qdel(src)
		return

	if(isclosedturf(new_turf))
		qdel(src)
		return

	interaction_turf = new_turf
	interaction_priorities = fill_priority_list(manipulator_tier)
	..()
	return

/datum/manipulator_task/cargo/proc/fill_priority_list(manipulator_tier)
	return list()

/datum/manipulator_task/cargo/proc/find_type_priority()
	var/atom/movable/best_candidate = null
	var/best_priority_index = INFINITY

	for(var/atom/movable/thing as anything in interaction_turf.contents)
		for(var/i in 1 to length(interaction_priorities))
			if(i >= best_priority_index)
				break

			var/datum/manipulator_priority/prio = interaction_priorities[i]

			if(!prio.active || ispath(prio, /turf))
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

	for(var/i in 1 to length(interaction_priorities))
		if(i >= best_priority_index)
			break
		var/datum/manipulator_priority/prio = interaction_priorities[i]
		if(prio.active && prio.atom_typepath == /turf)
			best_candidate = interaction_turf
			best_priority_index = i
			break

	return best_candidate

/datum/manipulator_task/cargo/proc/move_priority_up_by_index(index)
	if(!index)
		return FALSE
	interaction_priorities.Swap(index, index + 1)
	return TRUE

/datum/manipulator_task/cargo/proc/tick_priority_by_index(index, reset = FALSE)
	var/datum/manipulator_priority/target_priority = interaction_priorities[index + 1]
	if(reset)
		target_priority.active = TRUE
	else
		target_priority.active = !target_priority.active
	return TRUE

/datum/manipulator_task/cargo/proc/is_valid()
	if(!interaction_turf)
		return FALSE
	return !isclosedturf(interaction_turf)

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

/datum/manipulator_task/cargo/serialize()
	var/list/data = ..()
	data["offset"] = list(
		"dx" = offset_dx,
		"dy" = offset_dy,
	)
	data["should_use_filters"] = should_use_filters
	data["atom_filters"] = atom_filters
	data["filtering_mode"] = filtering_mode
	data["type_filters"] = type_filters
	data["interaction_priorities"] = list()
	for(var/datum/manipulator_priority/prio as anything in interaction_priorities)
		data["interaction_priorities"] += list(list(
			"type" = prio.type,
			"active" = prio.active,
		))
	return data


/datum/manipulator_task/cargo/Destroy()
	interaction_turf = null
	QDEL_LIST(interaction_priorities)
	return ..()

// ===== PICKUP =====

/datum/manipulator_task/cargo/pickup
	name = "pickup"
	var/pickup_eagerness = PICKUP_CAN_WAIT

/datum/manipulator_task/cargo/pickup/fill_priority_list(manipulator_tier)
	return list()

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
		for(var/datum/manipulator_task/cargo/dropoff_base/dest in manipulator.tasks)
			if(dest.can_accept(candidate))
				return TRUE
	return FALSE

/datum/manipulator_task/cargo/pickup/run_task(obj/machinery/big_manipulator/manipulator)
	manipulator.rotate_to_point(src, src, PROC_REF(try_pickup))

/datum/manipulator_task/cargo/pickup/proc/try_pickup(obj/machinery/big_manipulator/manipulator)
	var/atom/movable/selected = find_pickup_candidate(manipulator)
	if(!selected)
		manipulator.nothing_ever_happens()
		return

	if(selected.anchored || HAS_TRAIT(selected, TRAIT_NODROP))
		manipulator.nothing_ever_happens()
		return

	if(isitem(selected))
		var/obj/item/selected_item = selected
		if(selected_item.item_flags & (ABSTRACT|DROPDEL))
			manipulator.nothing_ever_happens()
			return

	selected.forceMove(manipulator)
	manipulator.held_object = WEAKREF(selected)
	manipulator.manipulator_arm.update_claw(manipulator.held_object)
	manipulator.schedule_next_cycle()

/datum/manipulator_task/cargo/pickup/serialize()
	var/list/data = ..()
	data["pickup_eagerness"] = pickup_eagerness
	return data

/datum/manipulator_task/cargo/pickup/New(turf/new_turf, manipulator_tier, serialized_data)
	..(new_turf, manipulator_tier, serialized_data)
	if(serialized_data)
		pickup_eagerness = serialized_data["pickup_eagerness"]
	return

/datum/manipulator_task/cargo/pickup/proc/find_pickup_candidate(obj/machinery/big_manipulator/manipulator)
	var/list/candidates = list()

	for(var/atom/movable/candidate as anything in interaction_turf.contents)
		if(candidate.anchored || HAS_TRAIT(candidate, TRAIT_NODROP))
			continue
		if(!check_filters_for_atom(candidate))
			continue
		if(pickup_eagerness == PICKUP_EAGER)
			candidates += candidate
			continue
		for(var/datum/manipulator_task/cargo/dropoff_base/dest in manipulator.tasks)
			if(dest.can_accept(candidate))
				candidates += candidate
				break

	if(!length(candidates))
		return null

	return manipulator.master_tasking.get_next_candidate(candidates)

// ===== BASE DROPOFF =====
// Base type for anything that accepts a `held_object`: drop, throw, use.
// Pickup iterates by this type to find a target point.

/datum/manipulator_task/cargo/dropoff_base
	name = "dropoff"

/datum/manipulator_task/cargo/dropoff_base/proc/can_accept(atom/movable/target)
	if(!is_valid())
		return FALSE
	if(should_use_filters && !check_filters_for_atom(target))
		return FALSE
	return TRUE

/datum/manipulator_task/cargo/dropoff_base/can_run(obj/machinery/big_manipulator/manipulator)
	if(!..())
		return FALSE
	var/atom/movable/target = manipulator.held_object?.resolve()
	if(!target)
		return FALSE
	return can_accept(target)

/datum/manipulator_task/cargo/dropoff_base/run_task(obj/machinery/big_manipulator/manipulator)
	manipulator.rotate_to_point(src, src, PROC_REF(try_dropoff))

/datum/manipulator_task/cargo/dropoff_base/proc/try_dropoff(obj/machinery/big_manipulator/manipulator)
	var/obj/actual_held_object = manipulator.held_object?.resolve()
	if(!actual_held_object || actual_held_object.loc != manipulator)
		manipulator.nothing_ever_happens()
		return FALSE
	do_dropoff(manipulator)
	return TRUE

/datum/manipulator_task/cargo/dropoff_base/serialize()
	var/list/data = ..()
	return data


/datum/manipulator_task/cargo/dropoff_base/proc/do_dropoff(obj/machinery/big_manipulator/manipulator)
	return

// ===== DROP =====

/datum/manipulator_task/cargo/dropoff_base/drop
	name = "drop"
	var/overflow_status = POINT_OVERFLOW_ALLOWED

/datum/manipulator_task/cargo/dropoff_base/drop/fill_priority_list(manipulator_tier)
	var/list/priorities = new /list(2)
	priorities[1] = new /datum/manipulator_priority/drop/in_storage
	priorities[2] = new /datum/manipulator_priority/drop/on_floor
	return priorities

/datum/manipulator_task/cargo/dropoff_base/drop/can_accept(atom/movable/target)
	if(!..())
		return FALSE

	var/list/atoms_on_the_turf = interaction_turf.contents
	switch(overflow_status)
		if(POINT_OVERFLOW_ALLOWED)
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

/datum/manipulator_task/cargo/dropoff_base/drop/serialize()
	var/list/data = ..()
	data["overflow_status"] = overflow_status
	return data

/datum/manipulator_task/cargo/dropoff_base/drop/New(turf/new_turf, manipulator_tier, serialized_data)
	..(new_turf, manipulator_tier, serialized_data)
	if(serialized_data)
		overflow_status = serialized_data["overflow_status"]
	return

/datum/manipulator_task/cargo/dropoff_base/drop/do_dropoff(obj/machinery/big_manipulator/manipulator)
	manipulator.try_drop_thing(src)

// ===== THROW =====

/datum/manipulator_task/cargo/dropoff_base/throw
	name = "throw"
	var/throw_range = 1

/datum/manipulator_task/cargo/dropoff_base/throw/can_accept(atom/movable/target)
	if(!is_valid())
		return FALSE
	if(should_use_filters && !check_filters_for_atom(target))
		return FALSE
	return TRUE

/datum/manipulator_task/cargo/dropoff_base/throw/serialize()
	var/list/data = ..()
	data["throw_range"] = throw_range
	return data

/datum/manipulator_task/cargo/dropoff_base/throw/New(turf/new_turf, manipulator_tier, serialized_data)
	..(new_turf, manipulator_tier, serialized_data)
	if(serialized_data)
		throw_range = serialized_data["throw_range"]
	return

/datum/manipulator_task/cargo/dropoff_base/throw/do_dropoff(obj/machinery/big_manipulator/manipulator)
	manipulator.throw_thing(src)

// ===== USE =====

/datum/manipulator_task/cargo/dropoff_base/use
	name = "use"
	var/worker_interaction = WORKER_NORMAL_USE
	var/use_post_interaction = POST_INTERACTION_DROP_AT_POINT
	var/worker_combat_mode = FALSE
	var/worker_use_rmb = FALSE

/datum/manipulator_task/cargo/dropoff_base/use/fill_priority_list(manipulator_tier)
	var/list/priorities = new /list(manipulator_tier == 4 ? 5 : 4)
	priorities[1] = new /datum/manipulator_priority/interact/with_living
	priorities[2] = new /datum/manipulator_priority/interact/with_structure
	priorities[3] = new /datum/manipulator_priority/interact/with_machinery
	priorities[4] = new /datum/manipulator_priority/interact/with_items
	if(manipulator_tier == 4)
		priorities[5] = new /datum/manipulator_priority/interact/with_vehicles
	return priorities

/datum/manipulator_task/cargo/dropoff_base/use/can_accept(atom/movable/target)
	if(!is_valid())
		return FALSE
	if(should_use_filters && !check_filters_for_atom(target))
		return FALSE
	return TRUE

/datum/manipulator_task/cargo/dropoff_base/use/serialize()
	var/list/data = ..()
	data["worker_interaction"] = worker_interaction
	data["use_post_interaction"] = use_post_interaction
	data["worker_combat_mode"] = worker_combat_mode
	data["worker_use_rmb"] = worker_use_rmb
	return data

/datum/manipulator_task/cargo/dropoff_base/use/New(turf/new_turf, manipulator_tier, serialized_data)
	..(new_turf, manipulator_tier, serialized_data)
	if(serialized_data)
		worker_interaction = serialized_data["worker_interaction"]
		use_post_interaction = serialized_data["use_post_interaction"]
		worker_combat_mode = !!serialized_data["worker_combat_mode"]
		worker_use_rmb = !!serialized_data["worker_use_rmb"]
	return

/datum/manipulator_task/cargo/dropoff_base/use/do_dropoff(obj/machinery/big_manipulator/manipulator)
	manipulator.try_use_thing(src)

// ===== INTERACT (empty hand) =====

/datum/manipulator_task/cargo/interact
	name = "interact"
	var/worker_interaction = WORKER_EMPTY_USE
	var/use_post_interaction = POST_INTERACTION_DROP_AT_POINT
	var/worker_combat_mode = FALSE
	var/worker_use_rmb = FALSE

/datum/manipulator_task/cargo/interact/fill_priority_list(manipulator_tier)
	var/list/priorities = new /list(manipulator_tier == 4 ? 5 : 4)
	priorities[1] = new /datum/manipulator_priority/interact/with_living
	priorities[2] = new /datum/manipulator_priority/interact/with_structure
	priorities[3] = new /datum/manipulator_priority/interact/with_machinery
	priorities[4] = new /datum/manipulator_priority/interact/with_items
	if(manipulator_tier == 4)
		priorities[5] = new /datum/manipulator_priority/interact/with_vehicles
	return priorities

/datum/manipulator_task/cargo/interact/can_run(obj/machinery/big_manipulator/manipulator)
	if(!..())
		return FALSE
	return find_type_priority() != null

/datum/manipulator_task/cargo/interact/run_task(obj/machinery/big_manipulator/manipulator)
	manipulator.rotate_to_point(src, src, PROC_REF(try_interact))

/datum/manipulator_task/cargo/interact/serialize()
	var/list/data = ..()
	data["worker_interaction"] = worker_interaction
	data["use_post_interaction"] = use_post_interaction
	data["worker_combat_mode"] = worker_combat_mode
	data["worker_use_rmb"] = worker_use_rmb
	return data

/datum/manipulator_task/cargo/interact/New(turf/new_turf, manipulator_tier, serialized_data)
	..(new_turf, manipulator_tier, serialized_data)
	if(serialized_data)
		worker_interaction = serialized_data["worker_interaction"]
		use_post_interaction = serialized_data["use_post_interaction"]
		worker_combat_mode = !!serialized_data["worker_combat_mode"]
		worker_use_rmb = !!serialized_data["worker_use_rmb"]
	return

/datum/manipulator_task/cargo/interact/proc/try_interact(obj/machinery/big_manipulator/manipulator)
	var/atom/movable/held = manipulator.held_object?.resolve()
	if(held)
		manipulator.try_use_thing(src)
	else
		manipulator.use_thing_with_empty_hand(src)
