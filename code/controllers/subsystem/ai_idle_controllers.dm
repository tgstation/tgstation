AI_CONTROLLER_SUBSYSTEM_DEF(ai_idle_controllers)
	name = "AI Idle Controllers"
	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND
	priority = FIRE_PRIORITY_IDLE_NPC
	init_order = INIT_ORDER_AI_IDLE_CONTROLLERS
	wait = 5 SECONDS
	runlevels = RUNLEVEL_GAME
	planning_status = AI_STATUS_IDLE
