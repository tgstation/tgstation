/datum/element/noisy_movement
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	var/movement_sound = 'sound/effects/roll.ogg'
	var/volume = 100

/datum/element/noisy_movement/Attach(datum/target, movement_sound, volume)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.movement_sound = movement_sound
	src.volume = volume

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(play_sound))

/datum/element/noisy_movement/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/element/noisy_movement/proc/play_sound(atom/movable/source, old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	if(!forced && !CHECK_MOVE_LOOP_FLAGS(source, MOVEMENT_LOOP_OUTSIDE_CONTROL) && source.has_gravity())
		playsound(src, movement_sound, volume, TRUE)

