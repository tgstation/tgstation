SUBSYSTEM_DEF(pathfinder)
	name = "pathfinder"
	init_order = INIT_ORDER_PATH
	flags = SS_NO_FIRE
	var/lcount = 20
	var/run
	var/free
	var/list/flow
	var/static/space_type_cache

/datum/controller/subsystem/pathfinder/Initialize()
	space_type_cache = typecacheof(/turf/open/space)
	run = 0
	free = 1
	flow = new/list(lcount)



/datum/controller/subsystem/pathfinder/proc/getfree()
	if(run < lcount)
		while(flow[free])
			free = (free % lcount) + 1
		flow[free] = TRUE
		run += 1
		return free
	else
		return 0
/datum/controller/subsystem/pathfinder/proc/found(l)
	flow[l] = FALSE
	run -= 1