/// The subsystem used to tick [/datum/component/burning] instances.
PROCESSING_SUBSYSTEM_DEF(burning)
	name = "Burning"
	priority = FIRE_PRIORITY_BURNING
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
