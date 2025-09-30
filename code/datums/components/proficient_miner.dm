/// Component given to mobs that can mine when moving
/datum/component/proficient_miner
	/// Last tick when we bumpmined. Prevents diagonal bumpnining being thrice as fast as normal
	var/last_bumpmine_tick = -1

/datum/component/proficient_miner/Initialize()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/proficient_miner/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))

/datum/component/proficient_miner/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_BUMP)

/datum/component/proficient_miner/proc/on_bump(atom/movable/source, atom/target)
	SIGNAL_HANDLER

	if(!ismineralturf(target) || last_bumpmine_tick == world.time)
		return

	var/mob/living/user = null
	if(isliving(parent))
		user = parent
		if(user.stat != CONSCIOUS)
			return

	var/turf/closed/mineral/mineral_wall = target
	if(!istype(mineral_wall, /turf/closed/mineral/gibtonite))
		last_bumpmine_tick = world.time
		mineral_wall.gets_drilled(source)
		return

	var/turf/closed/mineral/gibtonite/gibtonite_wall = mineral_wall
	if(gibtonite_wall.stage == GIBTONITE_UNSTRUCK)
		last_bumpmine_tick = world.time
		mineral_wall.gets_drilled(source)
