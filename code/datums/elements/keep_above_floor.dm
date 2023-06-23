/**
 * This adds and removes traits to and from the turfs whenever it moves,
 * along with a few other things such as updating turf slowdowns and the such
 * because we cannot have signals or element added to EVERY open turf out
 * there.
 */
/datum/element/keep_above_floor
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/list/traits
	/**
	 * After the last movable with this element leaves a turf, we don't
	 * immediately remove the traits from that turf. Instead we give it
	 * one tick so that whatever moves along with the movable doesn't
	 * get affected.
	 */
	var/list/recently_exited_turfs

/datum/element/keep_above_floor/Attach(atom/movable/target, list/traits)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	src.traits = traits

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(isturf(target.loc))
		add_floor_trait(target.loc, REF(target))

/datum/element/keep_above_floor/Detach(atom/movable/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	remove_floor_trait(source.loc, REF(source))
	return ..()

///Removes the trait from the old turf and adds it to the new one.
/datum/element/keep_above_floor/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(isturf(old_loc))
		for(var/trait in traits)
			if(HAS_TRAIT_FROM_ONLY(target.loc, TRAIT_TURF_EFFECTS_STOPPED, REF(source))
				var/ref_source = REF(source)
				var/timerid = addtimer(CALLBACK(src, PROC_REF(remove_floor_trait), old_loc, ref_source, TRUE), 0 SECONDS, TIMER_STOPPABLE)
				LAZYSET(recently_exited_turfs, old_loc, list(timerid, ref_source))
			else
				remove_floor_traits(old_loc, REF(target))

	if(!isturf(source.loc))
		return

#define POS_TIMER_ID 1
#define POS_TRAIT_SOURCE 2

	var/recently_exited = LAZYACCESS(recently_exited_turfs, source.loc)
	if(recently_exited) //So, we moved on a turf that had been left on the same tick by a movable with this element.
		deltimer(recently_exited[POS_TIMER_ID]) // callback... now!
		//It's a possibility, especially for vehicles that had moved while the driver couldn't and so were moved back.
		if(recently_exited[POS_TRAIT_SOURCE] != REF(source))
			add_floor_trait(target.loc, REF(source)) //Add the trait now to avoid the remove trait signal being sent.
			remove_floor_trait(source.loc, recently_exited[POS_TRAIT_SOURCE], TRUE)
	else
		add_floor_trait(target.loc, REF(source))

#undef POS_TIMER_ID
#undef POS_TRAIT_SOURCE

/datum/element/keep_above_floor/proc/add_floor_traits(turf/location, trait_source)
	var/update_movespeeds = (TRAIT_TURF_NO_SLOWDOWN in traits) && !HAS_TRAIT(location, TRAIT_TURF_NO_SLOWDOWN)
	for(var/trait in traits)
		ADD_TRAIT(location, trait, REF(source))
	if(update_movespeeds)
		return
	for(var/mob/living/living in location)
		living.update_turf_movespeed()

///Removes the trait from the location and removes it from the recently exited turfs if remove_timer is TRUE.
/datum/element/keep_above_floor/proc/remove_floor_traits(turf/location, trait_source, remove_timer = FALSE)
	for(var/trait in traits)
		REMOVE_TRAIT(location, trait, trait_source)
	if(remove_timer)
		LAZYREMOVE(recently_exited_turfs, location)
	if(!HAS_TRAIT(location, TRAIT_TURF_NO_SLOWDOWN))
		for(var/mob/living/living in location)
			living.update_turf_movespeed()
