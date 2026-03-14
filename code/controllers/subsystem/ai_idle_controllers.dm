AI_CONTROLLER_SUBSYSTEM_DEF(ai_idle_controllers)
	name = "AI Idle Controllers"
	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND
	priority = FIRE_PRIORITY_IDLE_NPC
	dependencies = list(
		/datum/controller/subsystem/ai_controllers,
	)
	wait = 5 SECONDS
	runlevels = RUNLEVEL_GAME
	planning_status = AI_STATUS_IDLE
