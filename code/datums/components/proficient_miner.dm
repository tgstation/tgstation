/// Component given to mobs that can mine when moving
/datum/component/proficient_miner
	/// Toolspeed for mining, 0 will cause it to instamine rock
	var/mining_speed = 0
	/// Should we pass the do_after visuals to our rider if we are a mob?
	var/pass_driver = FALSE
	/// Last tick when we bumpmined. Prevents diagonal bumpnining being thrice as fast as normal
	var/last_bumpmine_tick = -1

/datum/component/proficient_miner/Initialize(mining_speed = 0, pass_driver = FALSE)
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.mining_speed = mining_speed
	src.pass_driver = pass_driver

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
	if(istype(mineral_wall, /turf/closed/mineral/gibtonite))
		var/turf/closed/mineral/gibtonite/gibtonite_wall = mineral_wall
		if(gibtonite_wall.stage != GIBTONITE_UNSTRUCK)
			return

	if(user && mining_speed > 0)
		INVOKE_ASYNC(src, PROC_REF(slow_mine), user, target)
		return

	last_bumpmine_tick = world.time
	mineral_wall.gets_drilled(source)

/datum/component/proficient_miner/proc/slow_mine(mob/living/user, turf/closed/mineral/mineral_wall)
	if(TIMER_COOLDOWN_RUNNING(mineral_wall, REF(user))) //prevents mining turfs in progress
		return

	var/mining_delay = mineral_wall.tool_mine_speed * mining_speed
	TIMER_COOLDOWN_START(mineral_wall, REF(user), mining_delay)
	var/static/list/mine_sounds = list('sound/effects/pickaxe/picaxe1.ogg', 'sound/effects/pickaxe/picaxe2.ogg', 'sound/effects/pickaxe/picaxe3.ogg')
	playsound(user, pick(mine_sounds), 50)

	var/mob/living/driver = null
	if (pass_driver && length(user.buckled_mobs))
		driver = user.buckled_mobs[1]

	if(!do_after(user, mining_delay, mineral_wall, bar_override = driver))
		TIMER_COOLDOWN_END(mineral_wall, REF(user)) //if we fail we can start again immediately
		return

	if (mining_delay > MIN_TOOL_SOUND_DELAY)
		playsound(user, pick(mine_sounds), 50)

	if(istype(mineral_wall))
		mineral_wall.gets_drilled(driver || user)
