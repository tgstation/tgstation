/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
PROCESSING_SUBSYSTEM_DEF(ai_controllers)
	name = "AI behavior"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 20
