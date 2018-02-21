SUBSYSTEM_DEF(pathfinder)
	name = "pathfinder"
	init_order = INIT_ORDER_PATH
	flags = SS_NO_FIRE
	var/lcount = 10
	var/run
	var/free
	var/list/flow
	var/static/space_type_cache

/datum/controller/subsystem/pathfinder/Initialize()
	space_type_cache = typecacheof(/turf/open/space)
	run = 0
	free = 1
	flow = new()
	flow.len=lcount

/datum/controller/subsystem/pathfinder/proc/getfree(atom/M)
	if(run < lcount)
		run += 1
		while(flow[free])
			CHECK_TICK
			free = (free % lcount) + 1
		var/t = addtimer(CALLBACK(SSpathfinder, /datum/controller/subsystem/pathfinder.proc/toolong, free), 150, TIMER_STOPPABLE)
		flow[free] = t
		flow[t] = M
		return free
	else
		return 0

/datum/controller/subsystem/pathfinder/proc/toolong(l)
	log_game("Pathfinder route took longer than 150 ticks, src bot [flow[flow[l]]]")
	found(l)

/datum/controller/subsystem/pathfinder/proc/found(l)
	deltimer(flow[l])
	flow[l] = null
	run -= 1
