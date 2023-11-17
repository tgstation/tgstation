//WAITING UNTIL SAN7890'S PR ABOUT TRAITS GLOBALVARS IS MERGED
#define TRAIT_TURF_HAS_ELEVATED_OBJ(z) "turf_has_elevated_obj_[z]"
#define TRAIT_ELEVATED_TURF "elevated_turf"

/**
 * Manages the elevation of the turf the source is on (can be the turf itself)
 * The atom with the highest pixel_shift gets to set the elevation of the turf to that
 * value
 */
/datum/element/elevation
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///The amount of pixel_z applied to the mob standing on the turf.
	var/pixel_shift

/datum/element/elevation/Attach(datum/target, pixel_shift)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	src.pixel_shift = pixel_shift

	if(ismovable(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

	var/turf/turf = get_turf(target)
	if(turf)
		if(!HAS_TRAIT(turf, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
			RegisterSignal(turf, COMSIG_TURF_RESET_ELEVATION, PROC_REF(check_elevation))
			reset_elevation(turf)
		ADD_TRAIT(turf, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(target))

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
	if(isturf(oldloc))
		REMOVE_TRAIT(oldloc, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))
		if(!HAS_TRAIT(oldloc, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
			UnregisterSignal(oldloc, COMSIG_TURF_RESET_ELEVATION)
			reset_elevation(oldloc)
	if(isturf(source.loc))
		if(!HAS_TRAIT(source.loc, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift)))
			RegisterSignal(source.loc, COMSIG_TURF_RESET_ELEVATION, PROC_REF(check_elevation))
			reset_elevation(source.loc)
		ADD_TRAIT(source.loc, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))

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

	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_initialized_on))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(target, COMSIG_TURF_RESET_ELEVATION, PROC_REF(on_reset_elevation))

	src.pixel_shift = pixel_shift

	ADD_TRAIT(target, TRAIT_ELEVATED_TURF, REF(src))

	for(var/mob/living/living in target)
		RegisterSignal(living, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_set_buckled))
		elevate_mob(living)

/datum/element/elevation_core/Detach(datum/source)
	REMOVE_TRAIT(source, TRAIT_ELEVATED_TURF, REF(src))
	for(var/mob/living/living in source)
		elevate_mob(living, -pixel_shift)
	return ..()

/datum/element/elevation_core/proc/on_entered(turf/source, atom/movable/entered, atom/old_loc)
	SIGNAL_HANDLER
	if((isnull(old_loc) || !HAS_TRAIT_FROM(old_loc, TRAIT_ELEVATED_TURF, REF(src))) && isliving(entered))
		elevate_mob(entered)

/datum/element/elevation_core/proc/on_initialized_on(turf/source, atom/movable/spawned)
	SIGNAL_HANDLER
	if(isliving(spawned))
		elevate_mob(spawned)

/datum/element/elevation_core/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if((isnull(gone.loc) || !HAS_TRAIT_FROM(gone.loc, TRAIT_ELEVATED_TURF, REF(src))) && isliving(gone))
		elevate_mob(gone, -pixel_shift)
		UnregisterSignal(gone, COMSIG_LIVING_SET_BUCKLED)

/datum/element/elevation_core/proc/elevate_mob(mob/living/target, z_shift = pixel_shift)
	animate(target, pixel_z = z_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	if(target.buckled && isvehicle(target.buckled))
		animate(target.buckled, pixel_z = z_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)

///Vehicles or other things the mob is buckled too also are shifted.
/datum/element/elevation_core/proc/on_set_buckled(mob/living/source, atom/movable/new_buckled)
	SIGNAL_HANDLER
	if(source.buckled && isvehicle(source.buckled))
		animate(source.buckled, pixel_z = -pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	if(new_buckled && isvehicle(new_buckled))
		animate(source.buckled, pixel_z = pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)

/datum/element/elevation_core/proc/on_reset_elevation(turf/source, list/current_values)
	SIGNAL_HANDLER
	current_values[ELEVATION_CURRENT_PIXEL_SHIFT] = pixel_shift

#undef ELEVATE_TIME
