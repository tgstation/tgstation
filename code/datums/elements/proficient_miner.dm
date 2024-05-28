///element given to mobs that can mine when moving
/datum/element/proficient_miner

/datum/element/proficient_miner/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return
	RegisterSignal(target, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))

/datum/element/proficient_miner/proc/on_bump(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if(!ismineralturf(target))
		return
	var/turf/closed/mineral/mineral_wall = target
	mineral_wall.gets_drilled(source)

/datum/element/proficient_miner/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_MOVABLE_BUMP)
	return ..()
