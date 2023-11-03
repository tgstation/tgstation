/// Handles ticking idle behavior for ai behaviors
PROCESSING_SUBSYSTEM_DEF(ai_idle)
	name = "AI Processor"
	flags = SS_NO_INIT|SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC_ACTIONS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1
