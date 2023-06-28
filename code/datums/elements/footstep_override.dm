/datum/element/footstep_override
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	var/clawfootstep
	var/barefootstep
	var/heavyfootstep
	var/footstep
	var/priority
	var/list/occupied_turfs = list()

/datum/element/footstep_override/Attach(atom/movable/target, clawfootstep = FOOTSTEP_HARD_CLAW, barefootstep = FOOTSTEP_HARD_BAREFOOT, heavyfootstep = FOOTSTEP_GENERIC_HEAVY, footstep = FOOTSTEP_FLOOR, priority = STEP_SOUND_NO_PRIORITY)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.clawfootstep = clawfootstep
	src.barefootstep = barefootstep
	src.heavyfootstep = heavyfootstep
	src.footstep = footstep
	src.priority = priority

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(isturf(target.loc))
		occupy_turf(target, target.loc)

/datum/element/footstep_override/Detach(atom/movable/source)
	if(isturf(source.loc))
		vacate_turf(source, source.loc)
	return ..()

/datum/element/footstep_override/proc/on_moved(atom/movable/source, atom/oldloc)
	SIGNAL_HANDLER
	if(isturf(oldloc))
		vacate_turf(source, oldloc)
	if(isturf(source.loc))
		occupy_turf(source, source.loc)

/datum/element/footstep_override/proc/occupy_turf(atom/movable/movable, turf/location)
	if(occupied_turfs[location])
		occupied_turfs[location] |= movable
		return
	occupied_turfs[location] = list(movable)
	RegisterSignal(location, COMSIG_TURF_PREPARE_STEP_SOUND, PROC_REF(prepare_steps))

/datum/element/footstep_override/proc/vacate_turf(atom/movable/movable, turf/location)
	LAZYREMOVE(occupied_turfs[location], movable)
	if(!occupied_turfs[location])
		occupied_turfs -= location
		UnregisterSignal(location, COMSIG_TURF_PREPARE_STEP_SOUND)

/datum/element/footstep_override/proc/prepare_steps(turf/source, list/steps)
	SIGNAL_HANDLER
	if(steps[STEP_SOUND_PRIORITY] > priority)
		return
	steps[FOOTSTEP_MOB_SHOE] = footstep
	steps[FOOTSTEP_MOB_BAREFOOT] = barefootstep
	steps[FOOTSTEP_MOB_HEAVY] = heavyfootstep
	steps[FOOTSTEP_MOB_CLAW] = clawfootstep
	steps[STEP_SOUND_PRIORITY] = priority
