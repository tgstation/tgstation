/**
 * This subsystem updates shadowcasting overlays for updates not caused by mob movement.
 */
SUBSYSTEM_DEF(shadowcasting)
	name = "Shadowcasting"
	wait = 2
	init_order = INIT_ORDER_SHADOWCASTING
	flags = SS_TICKER
	var/static/list/turf/turf_queue = list()

/datum/controller/subsystem/shadowcasting/stat_entry(msg)
	msg = "T:[length(turf_queue)]|"
	return ..()

/datum/controller/subsystem/shadowcasting/Initialize()
	fire(FALSE, TRUE)
	initialized = TRUE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/shadowcasting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK

	var/list/queue = turf_queue
	var/i = 0
	for (i in 1 to length(queue))
		var/turf/shadow_source = queue[i]

		shadow_source.update_shadowcasting()

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		queue.Cut(1, i+1)

/datum/controller/subsystem/shadowcasting/Recover()
	initialized = SSshadowcasting.initialized
	return ..()
