/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI planning"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.5 SECONDS //Plan every half second if required, not great not terrible.

	var/list/active_ai_controllers = list()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	for(var/datum/ai_controller/ai_controller as anything in active_ai_controllers)
		if(!ai_controller.current_behaviors?.len)
			ai_controller.SelectBehaviors(wait * 0.1)
			if(!ai_controller.current_behaviors?.len) //Still no plan
				COOLDOWN_START(ai_controller, failed_planning_cooldown, AI_FAILED_PLANNING_COOLDOWN)
