/datum/interaction_point
	var/name = "interaction point"

	/// The turf this interaction point represents.
	var/turf/interaction_turf
	/// Should we check our filters while interacting with this point?
	var/should_use_filters = FALSE
	/// How should this point be interacted with?
	var/interaction_mode = INTERACT_DROP
	/// How should the monkey worker (if there is one) interact with the target point?
	var/worker_interaction
	/// How far should the manipulator throw the object?
	var/throw_range = 1
	/// Which items are supposed to be picked up from `interaction_turf` if this is a pickup point
	/// or looked for in the `interaction_turf` if this is a dropoff point.
	var/list/atom_filters = list()
	/// If this is a dropoff point, influences which interaction endpoints are preferred over which
	/// by the manipulator.
	var/list/interaction_priorities = list()
	/// Should the manipulator put items on this point if there are already such items on the turf?
	var/overflow_status = POINT_OVERFLOW_ALLOWED
	/// Which object category should the filters be looking out for.
	var/filtering_mode = TAKE_ITEMS
	/// Whether the worker will use combat mode while interacting with this point.
	var/worker_combat_mode = FALSE
	/// Whether the worker will simulate RMB instead of LMB on interaction.
	var/worker_use_rmb = FALSE
	/// List of types that can be picked up from this point
	var/list/type_filters = list(
		/obj/item,
		/obj/structure/closet,
	)

/datum/interaction_point/New(turf/new_turf, list/new_filters, new_should_use_filters, new_interaction_mode, new_allowed_types, new_overflow_status)
	if(!new_turf)
		stack_trace("New manipulator interaction point created with no valid turf references passed.")
		qdel(src)
		return

	if(isclosedturf(new_turf))
		qdel(src)
		return

	interaction_turf = new_turf

	if(length(new_filters))
		atom_filters = new_filters

	if(new_should_use_filters)
		should_use_filters = new_should_use_filters

	if(new_interaction_mode)
		interaction_mode = new_interaction_mode

	if(new_allowed_types)
		type_filters = new_allowed_types

	if(new_overflow_status)
		overflow_status = new_overflow_status

	interaction_priorities = fill_priority_list()

/// Finds the type priority of the interaction point.
/datum/interaction_point/proc/find_type_priority()
	for(var/datum/manipulator_priority/take_type in interaction_priorities)
		if(take_type.what_type == /turf)
			return interaction_turf

		for(var/type_in_priority in interaction_turf.contents)
			if(!istype(type_in_priority, take_type.what_type))
				continue

			if(isliving(type_in_priority))
				var/mob/living/living_target = type_in_priority
				if(living_target.stat == DEAD)
					continue

			return type_in_priority

/// Checks if the interaction point is available - if it has items that can be interacted with.
/datum/interaction_point/proc/is_available(transfer_type, atom/movable/target)
	if(!is_valid())
		return FALSE

	// All atoms on the turf that can be interacted with.
	var/list/atoms_on_the_turf = list()
	if(interaction_turf)
		for(var/atom/movable/movable_atom in interaction_turf.contents)
			atoms_on_the_turf += movable_atom

	// For pickup points, we want points that have atoms to pick up
	if(transfer_type == TRANSFER_TYPE_PICKUP)

		if(!length(atoms_on_the_turf))
			return FALSE // nothing to pick up

		if(should_use_filters)
			// If the atom filters are required, we need to check if any atom on the turf fits the filters.
			for(var/atom/movable/movable_atom in atoms_on_the_turf)
				if(check_filters_for_atom(movable_atom))
					return TRUE
			return FALSE

		// If the atom filters are skipped, then we just check if ANY match the filtering mode (objects/items/etc)
		for(var/atom/movable/movable_atom in atoms_on_the_turf)
			if(check_filters_for_atom(movable_atom))
				return TRUE

		// No suitable atoms to pick up - the pickup point is unavailable.
		return FALSE

	if(transfer_type == TRANSFER_TYPE_DROPOFF)
		// If filters are enabled, the held item itself must match them for any overflow mode
		if(!check_filters_for_atom(target) && should_use_filters)
			return FALSE

		switch(overflow_status)
			if(POINT_OVERFLOW_ALLOWED)
				// If we don't care if there are already things on this turf, then we just check for filters
				// Hence if the atom filters are skipped, the point is available for dropoff
				if(!should_use_filters)
					return TRUE
				// If filters are enabled and the target matched them above, it's available
				return TRUE

			if(POINT_OVERFLOW_FILTERS)
				// We need to check if there are already items matching the filters on the turf
				for(var/atom/movable/movable_atom in atoms_on_the_turf)
					if(check_filters_for_atom(movable_atom))
						return FALSE // the item on the turf was in the filters, hence the turf is considered overflowed

				return TRUE

			if(POINT_OVERFLOW_HELD)
				// We need to check if any of the items on the turf match the item we're holding
				for(var/atom/movable/movable_atom in atoms_on_the_turf)
					if(istype(movable_atom, target?.type))
						return FALSE // one of the items on the turf was the same as the one we're holding

				return TRUE

			if(POINT_OVERFLOW_FORBIDDEN)
				// We need to check if there are already ANY items on the turf
				var/list/items_on_the_turf = list()
				for(var/obj/item/each_item as anything in atoms_on_the_turf)
					items_on_the_turf += each_item

				if(length(items_on_the_turf))
					return FALSE

				return TRUE

	// No interaction is possible - the interaction point is unavailable.
	return FALSE

/// Checks if the interaction point is valid.
/datum/interaction_point/proc/is_valid()
	if(!interaction_turf)
		return FALSE

	if(isclosedturf(interaction_turf))
		return FALSE
	return TRUE

/// Checks if the passed movable `atom` fits the filters.
/datum/interaction_point/proc/check_filters_for_atom(atom/movable/target)
	if(!target || target.anchored || HAS_TRAIT(target, TRAIT_NODROP))
		return FALSE

	switch(filtering_mode)
		if(TAKE_CLOSETS)
			return iscloset(target)

		if(TAKE_HUMANS)
			return ishuman(target)

		if(TAKE_ITEMS)
			if(!should_use_filters)
				return(isitem(target))

			for(var/filter_path in atom_filters)
				if(istype(target, filter_path))
					return TRUE
			return FALSE

	return FALSE

/// Fills the interaction endpoint priority list for the current interaction mode.
/datum/interaction_point/proc/fill_priority_list()
	var/list/priorities_to_set = list()
	var/priority_number = 1

	switch(interaction_mode)
		if(INTERACT_DROP)
			priorities_to_set = list(
				new /datum/manipulator_priority/for_drop/in_storage,
				new /datum/manipulator_priority/for_drop/on_floor,
			)
		if(INTERACT_USE)
			priorities_to_set = list(
				new /datum/manipulator_priority/for_use/on_living,
				new /datum/manipulator_priority/for_use/on_structure,
				new /datum/manipulator_priority/for_use/on_machinery,
				new /datum/manipulator_priority/for_use/on_items,
			)

	for(var/datum/manipulator_priority/priority in priorities_to_set)
		priority.number = priority_number++

	return length(priorities_to_set) ? priorities_to_set : list()

/// Updates priority of a specific setting and adjusts other priorities accordingly
/datum/interaction_point/proc/update_priority(datum/manipulator_priority/target_priority, new_priority)
	if(!target_priority || !(target_priority in interaction_priorities))
		return FALSE

	var/old_priority = target_priority.number
	target_priority.number = new_priority

	// adjusting other priorities to avoid conflicts
	for(var/datum/manipulator_priority/other_priority in interaction_priorities)
		if(other_priority == target_priority)
			continue
		if(other_priority.number == new_priority)
			other_priority.number = old_priority
			break

	return TRUE

/// Gets the current priority list sorted by priority number
/datum/interaction_point/proc/get_sorted_priorities()
	var/list/sorted = interaction_priorities.Copy()
	sortTim(sorted, GLOBAL_PROC_REF(cmp_manipulator_priority))
	return sorted

/proc/cmp_manipulator_priority(datum/manipulator_priority/a, datum/manipulator_priority/b)
	return a.number - b.number

/datum/interaction_point/Destroy()
	interaction_turf = null
	return ..()
