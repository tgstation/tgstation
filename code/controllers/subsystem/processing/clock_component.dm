/// The subsystem used to tick [/datum/component/acid] instances.
PROCESSING_SUBSYSTEM_DEF(clock_component)
	name = "Clock Component"
	flags = SS_NO_INIT|SS_BACKGROUND|SS_KEEP_TIMING
	wait = COMP_CLOCK_DELAY
