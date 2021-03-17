/*
 * An element specific to turfs that can drop movables on the z level beneath when moved onto.
 * Basically, we want the fall to happen in [/atom/movable/proc/Moved()], not in [/turf/Exited()].
 * Should make pulling, riding vehicles etc. through z levels a bit easier without resorting to many hacks and snowflakes.
 */
/datum/element/entered_open_space_fall
	element_flags = ELEMENT_DETACH
	/// List of movables about to fall and the turfs they should be found at in order to be dropped.
	var/list/associated_turf_by_movable = list()

/datum/element/entered_open_space_fall/Attach(datum/target, climb_time, climb_stun)
	. = ..()

	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_ENTERED, .proc/prepare_zfall)

/datum/element/entered_open_space_fall/Detach(datum/target, force)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_ENTERED)

/datum/element/entered_open_space_fall/proc/prepare_zfall(turf/source, atom/movable/moving, atom/oldloc)
	SIGNAL_HANDLER

	if(moving.currently_z_moving)
		return
	if(ismob(moving))
		var/mob/moving_mob = moving
		if(moving_mob.buckled?.currently_z_moving)
			return
	RegisterSignal(moving, COMSIG_MOVABLE_MOVED, .proc/perform_zfall)
	associated_turf_by_movable[moving] = source

/datum/element/entered_open_space_fall/proc/perform_zfall(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	var/turf/pitfall = associated_turf_by_movable[source]
	if(pitfall == source.loc && pitfall.zFall(source, oldloc = oldloc))
		. = MOVABLE_MOVED_ZFELL_DOWN
	associated_turf_by_movable -= source
