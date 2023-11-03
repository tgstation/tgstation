/// Handles ticking idle behavior for ai behaviors
PROCESSING_SUBSYSTEM_DEF(ai_idle)
	name = "AI Behavior Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC_ACTIONS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 1
