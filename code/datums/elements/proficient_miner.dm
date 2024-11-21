///element given to mobs that can mine when moving
/datum/element/proficient_miner

/datum/element/proficient_miner/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return
	RegisterSignal(target, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))

/datum/element/proficient_miner/proc/on_bump(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(!ismineralturf(target) || (istype(source) && source.stat != CONSCIOUS))
		return

	var/turf/closed/mineral/mineral_wall = target

	if(!istype(mineral_wall, /turf/closed/mineral/gibtonite))
		mineral_wall.gets_drilled(source)
		return

	var/turf/closed/mineral/gibtonite/gibtonite_wall = mineral_wall
	if(gibtonite_wall.stage == GIBTONITE_UNSTRUCK)
		mineral_wall.gets_drilled(source)

/datum/element/proficient_miner/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_MOVABLE_BUMP)
	return ..()
