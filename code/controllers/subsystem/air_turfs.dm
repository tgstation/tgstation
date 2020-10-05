//WHAT IF WE TAKE THE ACTIVE TURF PROCESSING AND PUSH IT SOMEWHERE ELSE!!!

SUBSYSTEM_DEF(air_turfs)
	name = "Atmospherics - Turfs"
	init_order = INIT_ORDER_AIR_TURFS
	priority = FIRE_PRIORITY_AIR_TURFS
	wait = 2
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/cost_turfs = 0
	var/cost_groups = 0
	var/cost_equalize = 0
	var/cost_rescan = 0
	var/rescan_enabled = FALSE
	var/currentpart = SSAIR_EQUALIZE

/datum/controller/subsystem/air_turfs/proc/extools_update_ssair_turfs()

/datum/controller/subsystem/air_turfs/Initialize(timeofday)
	extools_update_ssair_turfs()
	. = ..()

/datum/controller/subsystem/air_turfs/stat_entry(msg)
	msg += "C:{"
	msg += "EQ:[round(cost_equalize,1)]|"
	msg += "AT:[round(cost_turfs,1)]|"
	msg += "EG:[round(cost_groups,1)]|"
	msg += "RS:[round(cost_rescan,1)]"
	msg += "}"
	var/active_turfs_len = SSair.get_amt_active_turfs()
	msg += "AT:[active_turfs_len]|"
	msg += "EG:[SSair.get_amt_excited_groups()]|"
	msg += "AT/MS:[round((cost ? active_turfs_len/cost : 0),0.1)]"
	return ..()


/datum/controller/subsystem/air_turfs/fire(resumed = 0)
	var/timer = TICK_USAGE_REAL
	if(currentpart == SSAIR_EQUALIZE)
		timer = TICK_USAGE_REAL
		if(SSair.process_turf_equalize(resumed,times_fired))
			pause()
		cost_equalize = MC_AVERAGE(cost_equalize, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		resumed = 0
		currentpart = SSAIR_ACTIVETURFS
		if(state != SS_RUNNING)
			return

	if(currentpart == SSAIR_ACTIVETURFS)
		timer = TICK_USAGE_REAL
		if(SSair.process_active_turfs(resumed,times_fired))
			pause()
		cost_turfs = MC_AVERAGE(cost_turfs, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		resumed = 0
		currentpart = SSAIR_EXCITEDGROUPS
		if(state != SS_RUNNING)
			return

	if(currentpart == SSAIR_EXCITEDGROUPS)
		timer = TICK_USAGE_REAL
		if(SSair.process_excited_groups(resumed))
			pause()
		cost_groups = MC_AVERAGE(cost_groups, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		resumed = 0
		currentpart = rescan_enabled ? SSAIR_RESCAN : SSAIR_EQUALIZE
		if(state != SS_RUNNING)
			return
	if(currentpart == SSAIR_RESCAN)
		/* first we check if we should rescan.
		   rescanning does the following things:
		   1. clears the active turfs
		   2. goes through every turf in the world and adds them to active if they need to be
		   this is a slowish process (it's faster than you'd think, due to C++ magic),
		   so we don't want to do it every time. it's done whenever there IS time,
		   but also done whenever the active turfs length gets too big--there might
		   be something screwy going on if that happens, so we run the rescan anyway.
		*/
		if(!MC_TICK_CHECK && (tick_usage < 90))
			timer = TICK_USAGE_REAL
			SSair.rescan_active_turfs(resumed)
			cost_rescan = MC_AVERAGE(cost_rescan, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
			rescan_enabled = FALSE
			resumed = 0
		currentpart = SSair.monstermos_enabled ? SSAIR_EQUALIZE : SSAIR_ACTIVETURFS
	return

