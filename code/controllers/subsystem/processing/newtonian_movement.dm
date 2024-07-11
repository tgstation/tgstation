/// The subsystem used to tick [/datum/component/jetpack] instances.
PROCESSING_SUBSYSTEM_DEF(newtonian_movement)
	name = "Newtonian Movement"
	flags = SS_NO_INIT|SS_BACKGROUND|SS_KEEP_TIMING
	wait = 1
