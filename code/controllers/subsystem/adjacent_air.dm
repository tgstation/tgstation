SUBSYSTEM_DEF(adjacent_air)
	name = "Atmos Adjacency"
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 10
	priority = FIRE_PRIORITY_ATMOS_ADJACENCY
	var/list/queue = list()

/datum/controller/subsystem/adjacent_air/stat_entry()
#ifdef TESTING
	..("P:[length(queue)], S:[GLOB.atmos_adjacent_savings[1]], T:[GLOB.atmos_adjacent_savings[2]]")
#else
	..("P:[length(queue)]")
#endif

/datum/controller/subsystem/adjacent_air/Initialize()
	while(length(queue))
		fire()
	return ..()

/datum/controller/subsystem/adjacent_air/fire(resumed = 0)

	var/list/queue = src.queue

	while (length(queue))
		var/turf/currT = queue[1]
		queue.Cut(1,2)

		currT.ImmediateCalculateAdjacentTurfs()

		if (MC_TICK_CHECK)
			return
