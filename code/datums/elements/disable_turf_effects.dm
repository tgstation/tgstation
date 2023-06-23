/**
 * A bespoke element that adds a set of traits to the turf
 * when occupied by at least one attached movabled and
 * removes it the tick after the turf is unoccupied.
 * This way movables with this element attached can safely transport movables
 * on top of them without leaving them exposed to the effects of the turf.
 */
/datum/element/disable_turf_effects
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/list/traits
	var/list/occupied_turfs = list()
	var/list/turfs_to_remove_traits_from

/datum/element/disable_turf_effects/Attach(atom/movable/target, list/traits)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	src.traits = traits

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(isturf(target.loc))
		add_to_occupied_turfs(target.loc, target)

/datum/element/disable_turf_effects/Detach(atom/movable/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	if(isturf(source.loc))
		remove_from_occupied_turfs(source.loc, source)
	return ..()

///Removes the trait from the old turf and adds it to the new one.
/datum/element/disable_turf_effects/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(isturf(old_loc))

		remove_from_occupied_turfs(old_loc, source)

	if(!isturf(source.loc))
		return

	add_to_occupied_turfs(target.loc, source)

/datum/element/disable_turf_effects/proc/add_to_occupied_turfs(turf/location, atom/movable/source)
	if(occupied_turfs[location])
		occupied_turfs[location] += source
		return

	occupied_turfs[location] = list(source)

	var/update_movespeeds = (TRAIT_TURF_NO_SLOWDOWN in traits) && !HAS_TRAIT(location, TRAIT_TURF_NO_SLOWDOWN)
	for(var/trait in traits)
		ADD_TRAIT(location, trait, REF(src))
	if(update_movespeeds)
		return
	for(var/mob/living/living in location)
		living.update_turf_movespeed()

	if(removal_timer)
		LAZYREMOVE(turfs_to_remove_traits_from, location)
		if(!turfs_to_remove_traits_from)
			deltimer(removal_timer)

/datum/element/disable_turf_effects/proc/remove_from_occupied_turfs(turf/location, atom/movable/source)
	LAZYREMOVE(occupied_turfs[location], source)
	if(!occupied_turfs[location])
		if(!removal_timer)
			removal_timer = addtimer(CALLBACK(src, PROC_REF(clear_unoccupied_turfs)), 0 SECONDS, TIMER_STOPPABLE)
		LAZYADD(turfs_to_remove_traits_from, location)

///Removes the trait from the location and removes it from the recently exited turfs if remove_timer is TRUE.
/datum/element/disable_turf_effects/proc/clear_unoccupied_turfs()
	for(var/turf/target_turf in turfs_to_remove_traits_from)
	for(var/trait in traits)
		REMOVE_TRAIT(target_turf, trait, REF(src))

	if((TRAIT_TURF_NO_SLOWDOWN in traits) && !HAS_TRAIT(location, TRAIT_TURF_NO_SLOWDOWN))
		for(var/mob/living/living in location)
			living.update_turf_movespeed()

	turfs_to_remove_traits_from = null
