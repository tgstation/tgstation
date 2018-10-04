SUBSYSTEM_DEF(adjacent_air)
	name = "Atmos Adjacency"
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1
	priority = FIRE_PRIORITY_ATMOS_ADJACENCY
	var/list/queue = list()

/datum/controller/subsystem/adjacent_air/stat_entry()
	..("P:[length(queue)]")

/datum/controller/subsystem/adjacent_air/Initialize()
	while(length(queue))
		fire()
	return ..()

/datum/controller/subsystem/adjacent_air/fire(resumed = 0)

	var/list/queue = src.queue

	while (length(queue))
		var/turf/currT = queue[1]
		queue.Cut(1, 2)

		var/list/atmos_adjacent_turfs = currT.atmos_adjacent_turfs
		for(var/direction in GLOB.cardinals)
			var/turf/neighborT = get_step(currT, direction)
			if(!neighborT)
				continue
			var/list/neighbor_adjacent_turfs = neighborT.atmos_adjacent_turfs
			if( !(currT.blocks_air || neighborT.blocks_air) && CANATMOSPASS(neighborT, currT) )
				LAZYINITLIST(neighbor_adjacent_turfs)
				LAZYINITLIST(atmos_adjacent_turfs)
				atmos_adjacent_turfs[neighborT] = TRUE
				neighbor_adjacent_turfs[currT] = TRUE
			else
				if (atmos_adjacent_turfs)
					atmos_adjacent_turfs -= neighborT
				if (neighbor_adjacent_turfs)
					neighbor_adjacent_turfs -= currT
				UNSETEMPTY(neighbor_adjacent_turfs)
			neighborT.atmos_adjacent_turfs = neighbor_adjacent_turfs
		UNSETEMPTY(atmos_adjacent_turfs)
		// If the list was null before, our thing isn't a reference to the thing in the object, we need to assign the list back just in case.
		currT.atmos_adjacent_turfs = atmos_adjacent_turfs

		if (MC_TICK_CHECK)
			return
