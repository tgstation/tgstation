PROCESSING_SUBSYSTEM_DEF(movement)
	name = "Movement"
	wait = 1 //SS_TICKER means this runs every tick
	flags = SS_TICKER | SS_NO_INIT
	priority = FIRE_PRIORITY_INPUT + 1
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	stat_tag = "MOV"

/datum/controller/subsystem/processing/movement/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/atom/movable/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(!thing.handle_inertia())
			thing.vx = 0
			thing.vy = 0
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return

