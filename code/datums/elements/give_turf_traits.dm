/// A bespoke element that adds a set of traits to the turf while occupied by at least one attached movabled.
/datum/element/give_turf_traits
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///A list of traits that are added to the turf while occupied.
	var/list/traits
	///List of sources we are using to reapply traits when turf changes
	var/list/trait_sources = list()

/datum/element/give_turf_traits/Attach(atom/movable/target, list/traits)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	src.traits = traits

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(isturf(target.loc))
		add_to_occupied_turfs(target.loc, target)

/datum/element/give_turf_traits/Detach(atom/movable/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	if(isturf(source.loc))
		remove_from_occupied_turfs(source.loc, source)
	return ..()

/// Removes the trait from the old turf and adds it to the new one.
/datum/element/give_turf_traits/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(isturf(old_loc))
		remove_from_occupied_turfs(old_loc, source)

	if(isturf(source.loc))
		add_to_occupied_turfs(source.loc, source)

/**
 * Registers the turf signals if it was previously unoccupied and adds it to the list of occupied turfs.
 * Otherwise, it just adds the movable to the assoc value of lists occupying the turf.
 */
/datum/element/give_turf_traits/proc/add_to_occupied_turfs(turf/location, atom/movable/source)
	var/trait_source = REF(source)
	if(isnull(trait_sources) || isnull(trait_sources[location]))
		RegisterSignal(location, COMSIG_TURF_CHANGE, PROC_REF(pre_change_turf))

	LAZYADDASSOCLIST(trait_sources, location, trait_source)
	var/update_movespeeds = (TRAIT_TURF_IGNORE_SLOWDOWN in traits) && !HAS_TRAIT(location, TRAIT_TURF_IGNORE_SLOWDOWN)
	for(var/trait in traits)
		ADD_TRAIT(location, trait,  trait_source)
	if(update_movespeeds)
		for(var/mob/living/living in location)
			living.update_turf_movespeed()

/**
 * Unregisters the turf signals if it's no longer unoccupied and removes it from the list of occupied turfs.
 * Otherwise, it just removes the movable from the assoc value of lists occupying the turf.
 */
/datum/element/give_turf_traits/proc/remove_from_occupied_turfs(turf/location, atom/movable/source)
	var/trait_source = REF(source)
	LAZYREMOVEASSOC(trait_sources, location, trait_source)
	if(isnull(trait_sources) || isnull(trait_sources[location]))
		UnregisterSignal(location, COMSIG_TURF_CHANGE)

	for(var/trait in traits)
		REMOVE_TRAIT(location, trait, trait_source)

	if((TRAIT_TURF_IGNORE_SLOWDOWN in traits) && !HAS_TRAIT(location, TRAIT_TURF_IGNORE_SLOWDOWN))
		for(var/mob/living/living in location)
			living.update_turf_movespeed()

/// Signals are carried over when the turf is changed, but traits aren't, so they've to be readded post-change.
/datum/element/give_turf_traits/proc/pre_change_turf(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, PROC_REF(reoccupy_turf))

/// Reapply turf traits to the provided turf
/datum/element/give_turf_traits/proc/reoccupy_turf(turf/changed)
	for(var/trait in traits)
		for(var/source in trait_sources[changed])
			ADD_TRAIT(changed, trait, source)
