PROCESSING_SUBSYSTEM_DEF(idle_ai_behaviors)
	name = "AI Idle Behaviors"
	flags = SS_BACKGROUND
	wait = 1.5 SECONDS
	priority = FIRE_PRIORITY_IDLE_NPC
	dependencies = list(
		/datum/controller/subsystem/ai_controllers
	)
	///List of all the idle ai behaviors
	var/list/idle_behaviors = list()

/datum/controller/subsystem/processing/idle_ai_behaviors/Initialize()
	setup_idle_behaviors()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/idle_ai_behaviors/proc/setup_idle_behaviors()
	for(var/behavior_type in subtypesof(/datum/idle_behavior))
		var/datum/idle_behavior/behavior = new behavior_type
		idle_behaviors[behavior_type] = behavior
