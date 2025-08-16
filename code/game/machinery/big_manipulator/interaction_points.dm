#define DIAG_INTERACTION_POINT_HUD "interaction_point"

/// A basic interaction point representing an open turf.
/// Contains data about how it should be interacted with, including filters, turf objects enumerating and a couple more things.
/datum/interaction_point
	var/name = "interaction point"

	/// The weakref to the turf this interaction point represents.
	var/datum/weakref/interaction_turf
	/// Should we check our filters while interacting with this point?
	var/filters_status = FILTERS_SKIPPED
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
	/// Should the manipulator overflow this interaction point if there are already atoms on this turf?
	var/should_overflow
	/// Which object category should the filters be looking out for.
	var/filtering_mode = TAKE_ITEMS
	/// List of types that can be picked up from this point
	var/list/type_filters = list(
		/obj/item,
		/obj/structure/closet,
	)

/datum/interaction_point/New(turf/new_turf, list/new_filters, new_filters_status, new_interaction_mode, new_allowed_types)
	if(!new_turf)
		stack_trace("New manipulator interaction point created with no valid turf references passed.")
		qdel(src)
		return

	if(isclosedturf(new_turf))
		qdel(src)
		return

	interaction_turf = WEAKREF(new_turf)

	if(length(new_filters))
		atom_filters = new_filters

	if(new_filters_status)
		filters_status = new_filters_status

	if(new_interaction_mode)
		interaction_mode = new_interaction_mode

	if(new_allowed_types)
		type_filters = new_allowed_types

	interaction_priorities = fill_priority_list()

/// Finds the type priority of the interaction point.
/datum/interaction_point/proc/find_type_priority()
	for(var/datum/manipulator_priority/take_type in interaction_priorities)
		if(take_type.what_type == /turf)
			return interaction_turf.resolve()

		var/turf/resolved_turf = interaction_turf.resolve()

		for(var/type_in_priority in resolved_turf.contents)
			if(!istype(type_in_priority, take_type.what_type))
				continue
			if(isliving(type_in_priority))
				var/mob/living/living_target = type_in_priority
				if(living_target.stat == DEAD)
					continue
			return type_in_priority

/// Checks if the interaction point is available - if it has items that can be interacted with.
/datum/interaction_point/proc/is_available(transfer_type)
	if(!is_valid())
		return FALSE

	// All atoms on the turf that can be interacted with.
	var/list/fitting_atoms = list()
	var/turf/resolved_turf = interaction_turf.resolve()
	if(resolved_turf)
		for(var/atom/movable/movable_atom in resolved_turf.contents)
			fitting_atoms += movable_atom

	// For pickup points, we want points that have items to pick up
	if(transfer_type == TRANSFER_TYPE_PICKUP)
		// If the atom filters are skipped and there are any atoms on the turf, check if they match the filtering mode
		if(filters_status == FILTERS_SKIPPED && length(fitting_atoms))
			for(var/atom/movable/movable_atom in fitting_atoms)
				if(check_filters_for_atom(movable_atom))
					return TRUE
			return FALSE

		// If the atom filters are required, we need to check if any atom on the turf fits the filters.
		for(var/atom/movable/movable_atom in fitting_atoms)
			if(check_filters_for_atom(movable_atom))
				return TRUE

		// No suitable items to pick up - the pickup point is unavailable.
		return FALSE

	// For dropoff points, we want points that are empty or can accept items
	if(transfer_type == TRANSFER_TYPE_DROPOFF)
		// If the atom filters are skipped, the point is always available for dropoff
		if(filters_status == FILTERS_SKIPPED)
			return TRUE

		// If the atom filters are required, we need to check if any atom on the turf fits the filters.
		// For dropoff, we want points that DON'T have items matching our filters
		for(var/atom/movable/movable_atom in fitting_atoms)
			if(check_filters_for_atom(movable_atom))
				return FALSE

		// No conflicting items found - the dropoff point is available.
		return TRUE

	// No interaction is possible - the interaction point is unavailable.
	return FALSE

/// Checks if the interaction point is valid.
/datum/interaction_point/proc/is_valid()
	var/turf/resolved_turf = interaction_turf?.resolve()
	if(!resolved_turf)
		return FALSE

	if(isclosedturf(resolved_turf))
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
			if(filters_status == FILTERS_REQUIRED)
				return target in atom_filters
			return isitem(target)

	return FALSE

/// Fills the interaction endpoint priority list for the current interaction mode.
/datum/interaction_point/proc/fill_priority_list()
	var/list/priorities_to_set = list()
	var/priority_number = 1

	switch(interaction_mode)
		if(INTERACT_DROP)
			priorities_to_set = list(
				new /datum/manipulator_priority/for_drop/on_floor(),
				new /datum/manipulator_priority/for_drop/in_storage()
				)
		if(INTERACT_USE)
			priorities_to_set = list(
				new /datum/manipulator_priority/for_use/on_living(),
				new /datum/manipulator_priority/for_use/on_structure(),
				new /datum/manipulator_priority/for_use/on_machinery(),
				new /datum/manipulator_priority/for_use/on_items()
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
