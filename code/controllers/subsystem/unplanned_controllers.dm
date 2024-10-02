/// Handles making mobs perform lightweight "idle" behaviors such as wandering around when they have nothing planned
SUBSYSTEM_DEF(unplanned_controllers)
	name = "Unplanned AI Controllers"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_UNPLANNED_NPC
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.25 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	///what ai status are we interested in
	var/target_status = AI_STATUS_ON

/datum/controller/subsystem/unplanned_controllers/stat_entry(msg)
	msg = "Planning AIs:[length(GLOB.unplanned_controllers[target_status])]"
	return ..()

/datum/controller/subsystem/unplanned_controllers/fire(resumed)
	for(var/datum/ai_controller/ai_controller as anything in GLOB.unplanned_controllers[target_status])
		ai_controller.idle_behavior.perform_idle_behavior(wait * 0.1, ai_controller)
