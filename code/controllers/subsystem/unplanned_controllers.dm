GLOBAL_LIST_EMPTY(unplanned_controller_subsystems)
/// Handles making mobs perform lightweight "idle" behaviors such as wandering around when they have nothing planned
SUBSYSTEM_DEF(unplanned_controllers)
	name = "Unplanned AI Controllers"
	ss_flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
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

// DEPRECATED — idle behaviors are no longer dispatched here. Subsystem kept to avoid removing it from all controller dependency lists.
/datum/controller/subsystem/unplanned_controllers/stat_entry(msg)
	return ..()

/datum/controller/subsystem/unplanned_controllers/fire(resumed)
	return
