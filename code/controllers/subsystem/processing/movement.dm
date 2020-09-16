SUBSYSTEM_DEF(movement)
	name = "Movement"
	wait = 1 //SS_TICKER means this runs every tick
	flags = SS_TICKER | SS_NO_INIT
	priority = FIRE_PRIORITY_MOVEMENT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/moving = list()
	var/list/currentrun = list()

/datum/controller/subsystem/movement/stat_entry(msg)
	msg = "MOV: [length(moving)]"
	return msg

/datum/controller/subsystem/movement/fire(resumed = 0)
	if (!resumed)
		src.currentrun = moving.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.currentrun

	while(current_run.len)
		var/atom/movable/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			moving -= thing
		else if(!thing.handle_inertia())
			thing.vx = 0
			thing.vy = 0
			moving -= thing
		if (MC_TICK_CHECK)
			return

