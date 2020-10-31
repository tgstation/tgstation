/// The subsystem used to tick [/datum/ai_actions] instances, and thus also behavior trees.
PROCESSING_SUBSYSTEM_DEF(ai_actions)
	name = "AI behavior"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 10 //Every second
