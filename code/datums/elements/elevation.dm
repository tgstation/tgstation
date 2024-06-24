/**
 * Manages the elevation of the turf the source is on (can be the turf itself)
 * The atom with the highest pixel_shift gets to set the elevation of the turf to that value.
 */
/datum/element/elevation
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	///The amount of pixel_z applied to the mob standing on the turf
	var/pixel_shift

/datum/element/elevation/Attach(datum/target, pixel_shift)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	src.pixel_shift = pixel_shift

	if(ismovable(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

	var/atom/atom_target = target
	if(isturf(atom_target.loc))
		var/turf/turf = atom_target.loc
		if(!HAS_TRAIT(turf, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
			RegisterSignal(turf, COMSIG_TURF_RESET_ELEVATION, PROC_REF(check_elevation))
			RegisterSignal(turf, COMSIG_TURF_CHANGE, PROC_REF(pre_change_turf))
			reset_elevation(turf)
		ADD_TRAIT(turf, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(target))

/datum/element/elevation/Detach(atom/movable/source)
	unregister_turf(source, source.loc)
	return ..()

/datum/element/elevation/proc/reset_elevation(turf/target)
	var/list/current_values[2]
	SEND_SIGNAL(target, COMSIG_TURF_RESET_ELEVATION, current_values)
	var/current_pixel_shift = current_values[ELEVATION_CURRENT_PIXEL_SHIFT]
	var/new_pixel_shift = current_values[ELEVATION_MAX_PIXEL_SHIFT]
	if(new_pixel_shift == current_pixel_shift)
		return
	if(current_pixel_shift)
		target.RemoveElement(/datum/element/elevation_core, current_pixel_shift)
	if(new_pixel_shift)
		target.AddElement(/datum/element/elevation_core, new_pixel_shift)

/datum/element/elevation/proc/check_elevation(turf/source, list/current_values)
	SIGNAL_HANDLER
	current_values[ELEVATION_MAX_PIXEL_SHIFT] = max(current_values[ELEVATION_MAX_PIXEL_SHIFT], pixel_shift)

/datum/element/elevation/proc/on_moved(atom/movable/source, atom/oldloc)
	SIGNAL_HANDLER
	unregister_turf(source, oldloc)
	if(isturf(source.loc))
		if(!HAS_TRAIT(source.loc, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
			RegisterSignal(source.loc, COMSIG_TURF_RESET_ELEVATION, PROC_REF(check_elevation))
			RegisterSignal(source.loc, COMSIG_TURF_CHANGE, PROC_REF(pre_change_turf))
			reset_elevation(source.loc)
		ADD_TRAIT(source.loc, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))

/datum/element/elevation/proc/unregister_turf(atom/movable/source, atom/location)
	if(!isturf(location))
		return
	REMOVE_TRAIT(location, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))
	if(!HAS_TRAIT(location, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
		UnregisterSignal(location, list(COMSIG_TURF_RESET_ELEVATION, COMSIG_TURF_CHANGE))
		reset_elevation(location)

///Changing or destroying the turf detaches the element, also we need to reapply the traits since they don't get passed down.
/datum/element/elevation/proc/pre_change_turf(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	var/list/trait_sources = GET_TRAIT_SOURCES(changed, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift))
	trait_sources = trait_sources.Copy()
	post_change_callbacks += CALLBACK(src, PROC_REF(post_change_turf), trait_sources)

/datum/element/elevation/proc/post_change_turf(list/trait_sources, turf/changed)
	for(var/source in trait_sources)
		ADD_TRAIT(changed, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), source)
	reset_elevation(changed)

#define ELEVATE_TIME 0.2 SECONDS

/**
 * The core element attached to the turf itself. Do not use this directly!
 *
 * Causes mobs walking over a turf with this element to be pixel shifted vertically by the pixel_shift amount.
 * Because of the way it's structured, it should only be added through the elevation element (without the core suffix).
 *
 * To explain: in the case of multiple objects with (different instances of) the element being stacked on one turf somehow,
 * we only want that with the highest pixel shift value to apply it to the turf, so that the mobs standing on top of it all
 * doesn't look like it's floating off the pile.
 */
/datum/element/elevation_core
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	///The amount of pixel_z applied to the mob standing on the turf.
	var/pixel_shift

/datum/element/elevation_core/Attach(datum/target, pixel_shift)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	if(!pixel_shift)
		CRASH("attempted attaching /datum/element/elevation_core with a pixel_shift value of [isnull(pixel_shift) ? "null" : 0]")

	RegisterSignal(target, COMSIG_ATOM_ABSTRACT_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_initialized_on))
	RegisterSignal(target, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(on_exited))
	RegisterSignal(target, COMSIG_TURF_RESET_ELEVATION, PROC_REF(on_reset_elevation))

	src.pixel_shift = pixel_shift

	ADD_TRAIT(target, TRAIT_ELEVATED_TURF, REF(src))

	for(var/mob/living/living in target)
		ADD_TRAIT(living, TRAIT_ON_ELEVATED_SURFACE, REF(src))
		RegisterSignal(living, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_set_buckled))
		RegisterSignal(living, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_add))
		RegisterSignal(living, SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_remove))
		elevate_mob(living)

/datum/element/elevation_core/Detach(datum/source)
	/**
	 * Since the element can be removed outside of Destroy(),
	 * and even then, signals are passed down to the new turf,
	 * it's necessary to clear them here.
	 */
	UnregisterSignal(source, list(
		COMSIG_ATOM_ABSTRACT_ENTERED,
		COMSIG_ATOM_ABSTRACT_EXITED,
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON,
		COMSIG_TURF_RESET_ELEVATION,
	))
	REMOVE_TRAIT(source, TRAIT_ELEVATED_TURF, REF(src))
	for(var/mob/living/living in source)
		if(!HAS_TRAIT_FROM(living, TRAIT_ON_ELEVATED_SURFACE, REF(src)))
			continue
		REMOVE_TRAIT(living, TRAIT_ON_ELEVATED_SURFACE, REF(src))
		elevate_mob(living, -pixel_shift)
		UnregisterSignal(living, list(COMSIG_LIVING_SET_BUCKLED, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION)))
	return ..()

/datum/element/elevation_core/proc/on_entered(turf/source, atom/movable/entered, atom/old_loc)
	SIGNAL_HANDLER
	if((isnull(old_loc) || !HAS_TRAIT_FROM(old_loc, TRAIT_ELEVATED_TURF, REF(src))) && isliving(entered))
		ADD_TRAIT(entered, TRAIT_ON_ELEVATED_SURFACE, REF(src))
		var/elevate_time = isturf(old_loc) && source.Adjacent(old_loc) ? ELEVATE_TIME : 0
		elevate_mob(entered, elevate_time = elevate_time)
		RegisterSignal(entered, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_set_buckled))
		RegisterSignal(entered, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_add))
		RegisterSignal(entered, SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_remove))

/datum/element/elevation_core/proc/on_initialized_on(turf/source, atom/movable/spawned)
	SIGNAL_HANDLER
	if(isliving(spawned))
		elevate_mob(spawned)

/datum/element/elevation_core/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if((isnull(gone.loc) || !HAS_TRAIT_FROM(gone.loc, TRAIT_ELEVATED_TURF, REF(src))) && isliving(gone))
		// Always unregister the signals, we're still leaving even if not affected by elevation.
		UnregisterSignal(gone, list(COMSIG_LIVING_SET_BUCKLED, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION)))
		if(!HAS_TRAIT_FROM(gone, TRAIT_ON_ELEVATED_SURFACE, REF(src)))
			return
		REMOVE_TRAIT(gone, TRAIT_ON_ELEVATED_SURFACE, REF(src))
		var/elevate_time = isturf(gone.loc) && source.Adjacent(gone.loc) ? ELEVATE_TIME : 0
		elevate_mob(gone, -pixel_shift, elevate_time)

/datum/element/elevation_core/proc/elevate_mob(mob/living/target, z_shift = pixel_shift, elevate_time = ELEVATE_TIME, force = FALSE)
	if(HAS_TRAIT(target, TRAIT_IGNORE_ELEVATION) && !force)
		return
	var/buckled_to_vehicle = FALSE
	if(target.buckled)
		if(isvehicle(target.buckled))
			buckled_to_vehicle = TRUE
		else if(!isliving(target.buckled))
			return
	animate(target, pixel_z = z_shift, time = elevate_time, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	if(buckled_to_vehicle)
		animate(target.buckled, pixel_z = z_shift, time = elevate_time, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)

/**
 * If the mob is buckled or unbuckled to/from a vehicle, shift it up/down
 *.
 * Null the pixel shift if the mob is buckled to something different that's not a mob or vehicle
 *
 * The reason is that it's more important for a mob to look like they're actually buckled to a bed
 * or something anchored to the floor than atop of whatever else is on the same turf.
 */
/datum/element/elevation_core/proc/on_set_buckled(mob/living/source, atom/movable/new_buckled)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_IGNORE_ELEVATION))
		return
	if(source.buckled)
		if(isvehicle(source.buckled))
			animate(source.buckled, pixel_z = -pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
		else if(!isliving(source.buckled))
			animate(source, pixel_z = pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	if(!new_buckled)
		return
	if(isvehicle(new_buckled))
		animate(new_buckled, pixel_z = pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	else if(!isliving(new_buckled))
		animate(source, pixel_z = -pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)

/datum/element/elevation_core/proc/on_ignore_elevation_add(mob/living/source, trait)
	SIGNAL_HANDLER
	elevate_mob(source, -pixel_shift, force = TRUE)

/datum/element/elevation_core/proc/on_ignore_elevation_remove(mob/living/source, trait)
	SIGNAL_HANDLER
	elevate_mob(source, pixel_shift)

/datum/element/elevation_core/proc/on_reset_elevation(turf/source, list/current_values)
	SIGNAL_HANDLER
	current_values[ELEVATION_CURRENT_PIXEL_SHIFT] = pixel_shift

#undef ELEVATE_TIME
