/**
 * Manages the elevation of the turf the source is on
 * The atom with the highest pixel_shift gets to set the elevation of the turf to that value.
 */
/datum/element/elevation
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	///The amount of pixel_z applied to the mob standing on the turf
	var/pixel_shift

/datum/element/elevation/Attach(datum/target, pixel_shift)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_ELEVATING_OBJECT, ref(src))

	src.pixel_shift = pixel_shift

	RegisterSignal(target, COMSIG_ATOM_ENTERING, PROC_REF(on_source_entering))
	RegisterSignal(target, COMSIG_ATOM_EXITING, PROC_REF(on_source_exiting))

	var/atom/atom_target = target
	register_turf(atom_target, atom_target.loc)

/datum/element/elevation/Detach(atom/movable/source)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERING, COMSIG_ATOM_EXITING))
	unregister_turf(source, source.loc)
	REMOVE_TRAIT(source, TRAIT_ELEVATING_OBJECT, ref(src))
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

/datum/element/elevation/proc/on_source_entering(atom/movable/source, atom/entering, atom/old_loc)
	SIGNAL_HANDLER
	register_turf(source, entering)

/datum/element/elevation/proc/on_source_exiting(atom/movable/source, atom/exiting)
	SIGNAL_HANDLER
	unregister_turf(source, exiting)

/datum/element/elevation/proc/register_turf(atom/movable/source, atom/location)
	if(!isturf(location))
		return
	if(!HAS_TRAIT(location, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
		RegisterSignal(location, COMSIG_TURF_RESET_ELEVATION, PROC_REF(check_elevation))
		RegisterSignal(location, COMSIG_TURF_CHANGE, PROC_REF(pre_change_turf))
		reset_elevation(location)
	ADD_TRAIT(location, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))

/datum/element/elevation/proc/unregister_turf(atom/movable/source, atom/location)
	if(!isturf(location))
		return
	REMOVE_TRAIT(location, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))
	if(!HAS_TRAIT(location, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
		UnregisterSignal(location, list(COMSIG_TURF_RESET_ELEVATION, COMSIG_TURF_CHANGE))
		reset_elevation(location)

/// When a turf with elevated objects changes, we need to unregister all the elevating objects on it. When a turf Initializes(),
/// it calls Entered() on all of its moveable contents, which will invoke on_source_entering(), which will register each elevating
/// object with the new turf. We need to do this because turfs do not keep their traits when changed, and so the check for
/// TRAIT_TURF_HAS_ELEVATED_OBJ above will fail and cause override runtimes when we attempt to register the signals again.
/datum/element/elevation/proc/pre_change_turf(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	for (var/atom/movable/content as anything in changed)
		if(HAS_TRAIT_FROM(content, TRAIT_ELEVATING_OBJECT, ref(src)))
			unregister_turf(content, changed)

#define ELEVATE_TIME 0.2 SECONDS
#define ELEVATION_SOURCE(datum) "elevation_[REF(datum)]"

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

	ADD_TRAIT(target, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))

	for(var/mob/living/living in target)
		register_new_mob(living)

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
	REMOVE_TRAIT(source, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))
	for(var/mob/living/living in source)
		deelevate_mob(living)
		UnregisterSignal(living, list(COMSIG_LIVING_SET_BUCKLED, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION)))
	return ..()

/datum/element/elevation_core/proc/on_entered(turf/source, atom/movable/entered, atom/old_loc)
	SIGNAL_HANDLER
	if((isnull(old_loc) || !HAS_TRAIT_FROM(old_loc, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))) && isliving(entered))
		register_new_mob(entered, elevate_time = isturf(old_loc) && source.Adjacent(old_loc) ? ELEVATE_TIME : 0)

/datum/element/elevation_core/proc/on_initialized_on(turf/source, atom/movable/spawned)
	SIGNAL_HANDLER
	if(isliving(spawned))
		register_new_mob(spawned, elevate_time = 0)

/datum/element/elevation_core/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if((isnull(gone.loc) || !HAS_TRAIT_FROM(gone.loc, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))) && isliving(gone))
		// Always unregister the signals, we're still leaving even if not affected by elevation.
		UnregisterSignal(gone, list(COMSIG_LIVING_SET_BUCKLED, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION)))
		deelevate_mob(gone, isturf(gone.loc) && source.Adjacent(gone.loc) ? ELEVATE_TIME : 0)

/// Registers a new mob to be elevated, and elevates it.
/datum/element/elevation_core/proc/register_new_mob(mob/living/new_mob, elevate_time = ELEVATE_TIME)
	elevate_mob(new_mob, elevate_time = elevate_time)
	// mobs can reasonably be reigstered twice if the element is attached and then their init finishes
	RegisterSignal(new_mob, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_set_buckled), override = TRUE)
	RegisterSignal(new_mob, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_add), override = TRUE)
	RegisterSignal(new_mob, SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_remove), override = TRUE)

/**
 * Elevates the mob by pixel_shift amount.
 *
 * If the mob has the TRAIT_IGNORE_ELEVATION trait, it will not be elevated.
 *
 * If the mob is buckled to something...
 * ...And that something is a vehicle, it will also be elevated.
 * ...And that something is an object, neither the mob nor the object will be elevated.
 * ...And that something is a mob, we will be elevated (but not the other mob).
 */
/datum/element/elevation_core/proc/elevate_mob(mob/living/target, elevate_time = ELEVATE_TIME, force = FALSE)
	if(HAS_TRAIT(target, TRAIT_IGNORE_ELEVATION) && !force)
		return
	// while the offset system can natively handle this,
	// we want to avoid accidentally double-elevating anything they're buckled to (namely vehicles)
	if(target.has_offset(source = ELEVATION_SOURCE(src)))
		return
	ADD_TRAIT(target, TRAIT_MOB_ELEVATED, ELEVATION_SOURCE(src))
	// We are buckled to something
	if(target.buckled)
		// We are buckled to a vehicle, so it also must be elevated
		if(isvehicle(target.buckled))
			animate(target.buckled, pixel_z = pixel_shift, time = elevate_time, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
		// We are buckled to a mob - they're elevated so we're elevated
		else if(isliving(target.buckled))
			pass()
		// We are buckled to some other object - perhaps the object itself - so skip
		else
			return
	target.add_offsets(ELEVATION_SOURCE(src), z_add = pixel_shift, animate = elevate_time > 0)

/// Reverts elevation of the mob.
/datum/element/elevation_core/proc/deelevate_mob(mob/living/target, elevate_time = ELEVATE_TIME)
	REMOVE_TRAIT(target, TRAIT_MOB_ELEVATED, ELEVATION_SOURCE(src))
	target.remove_offsets(ELEVATION_SOURCE(src), animate = elevate_time > 0)
	if(isvehicle(target.buckled))
		animate(target.buckled, pixel_z = -pixel_shift, time = elevate_time, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)

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
	// We were buckled to something
	if(source.buckled)
		// It was a vehicle, so reset its pixel_z
		if(isvehicle(source.buckled))
			animate(source.buckled, pixel_z = -pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
		// It was a mob, so revert our pixel_z
		else if(isliving(source.buckled))
			deelevate_mob(source)
		// It was some object, maybe the object itself, elevate us
		else
			source.add_offsets(ELEVATION_SOURCE(src), z_add = pixel_shift)
	// We are now buckled to something
	if(new_buckled)
		// It's a vehicle, so elevate it
		if(isvehicle(new_buckled))
			animate(new_buckled, pixel_z = pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
		// It's a mob, so elevate us
		else if(isliving(new_buckled))
			elevate_mob(source)
		// It's some object, maybe the object itself, so clear elevation
		else
			source.remove_offsets(ELEVATION_SOURCE(src))

/datum/element/elevation_core/proc/on_ignore_elevation_add(mob/living/source, trait)
	SIGNAL_HANDLER
	deelevate_mob(source)

/datum/element/elevation_core/proc/on_ignore_elevation_remove(mob/living/source, trait)
	SIGNAL_HANDLER
	elevate_mob(source)

/datum/element/elevation_core/proc/on_reset_elevation(turf/source, list/current_values)
	SIGNAL_HANDLER
	current_values[ELEVATION_CURRENT_PIXEL_SHIFT] = pixel_shift

#undef ELEVATE_TIME
#undef ELEVATION_SOURCE
