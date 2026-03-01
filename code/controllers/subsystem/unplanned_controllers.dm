GLOBAL_LIST_EMPTY(unplanned_controller_subsystems)
/// Handles making mobs perform lightweight "idle" behaviors such as wandering around when they have nothing planned
SUBSYSTEM_DEF(unplanned_controllers)
	name = "Unplanned AI Controllers"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_UNPLANNED_NPC
	dependencies = list(
		/datum/controller/subsystem/movement/ai_movement,
	)
	wait = 0.25 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	///what ai status are we interested in
	var/target_status = AI_STATUS_ON
	var/list/current_run = list()

/datum/controller/subsystem/unplanned_controllers/Initialize()
	..()
	GLOB.unplanned_controller_subsystems += src
	return SS_INIT_SUCCESS

/datum/controller/subsystem/unplanned_controllers/Destroy()
	GLOB.unplanned_controller_subsystems -= src
	return ..()

/datum/controller/subsystem/unplanned_controllers/stat_entry(msg)
	msg = "\n  Planning AIs:[length(GLOB.unplanned_controllers[target_status])]"
	return ..()

/datum/controller/subsystem/unplanned_controllers/fire(resumed)
	if(!resumed)
		src.current_run = GLOB.unplanned_controllers[target_status].Copy()
	var/list/current_run = src.current_run // cache for sonic speed
	while(length(current_run))
		var/datum/ai_controller/unplanned = current_run[current_run.len]
		current_run.len--
		if(!QDELETED(unplanned))
			unplanned.idle_behavior.perform_idle_behavior(wait * 0.1, unplanned)
		if (MC_TICK_CHECK)
			return
