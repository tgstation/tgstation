/*
 * A simple subsystem that handles temporarily halted floating animation loops,
 * so they don't get in the way of a few other interpolations and make them jarring.
 */
SUBSYSTEM_DEF(floating_anim)
	name = "Floating Animation"
	priority = FIRE_PRIORITY_FLOATING
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS

	var/list/currentrun = list()

/datum/controller/subsystem/floating_anim/fire()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/atom/movable/AM = currentrun[1]
		if(!AM)
			currentrun -= AM
		else if(currentrun[AM] < world.time)
			UnregisterSignal(AM, COMSIG_PARENT_QDELETING)
			currentrun -= AM
			if(AM.floating_anim_status == UPDATE_FLOATING_ANIM)
				AM.float()
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/floating_anim/proc/remove_reference(datum/source)
	currentrun -= source
