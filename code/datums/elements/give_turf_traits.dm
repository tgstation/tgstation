///A bespoke element that adds a set of traits to the turf while occupied by at least one attached movabled.
/datum/element/give_turf_traits
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///A list of traits that are added to the turf while occupied.
	var/list/traits
	///The list of occupied turfs: Assoc value is a list of movables with this element that are occupying the turf.
	var/list/occupied_turfs = list()

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

///Removes the trait from the old turf and adds it to the new one.
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
	if(occupied_turfs[location])
		occupied_turfs[location] += source
		return

	occupied_turfs[location] = list(source)
	RegisterSignal(location, COMSIG_TURF_CHANGE, PROC_REF(pre_change_turf))

	var/update_movespeeds = (TRAIT_TURF_IGNORE_SLOWDOWN in traits) && !HAS_TRAIT(location, TRAIT_TURF_IGNORE_SLOWDOWN)
	for(var/trait in traits)
		ADD_TRAIT(location, trait, REF(src))
	if(update_movespeeds)
		for(var/mob/living/living in location)
			living.update_turf_movespeed()

/**
 * Unregisters the turf signals if it's no longer unoccupied and removes it from the list of occupied turfs.
 * Otherwise, it just removes the movable from the assoc value of lists occupying the turf.
 */
/datum/element/give_turf_traits/proc/remove_from_occupied_turfs(turf/location, atom/movable/source)
	LAZYREMOVE(occupied_turfs[location], source)
	if(occupied_turfs[location])
		return

	occupied_turfs -= location
	UnregisterSignal(location, COMSIG_TURF_CHANGE)

	for(var/trait in traits)
		REMOVE_TRAIT(location, trait, REF(src))

	if((TRAIT_TURF_IGNORE_SLOWDOWN in traits) && !HAS_TRAIT(location, TRAIT_TURF_IGNORE_SLOWDOWN))
		for(var/mob/living/living in location)
			living.update_turf_movespeed()

///Signals and components are carried over when the turf is changed, so they've to be readded post-change.
/datum/element/give_turf_traits/proc/pre_change_turf(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, PROC_REF(reoccupy_turf))

/datum/element/give_turf_traits/proc/reoccupy_turf(turf/changed)
	for(var/trait in traits)
		ADD_TRAIT(changed, trait, REF(src))
