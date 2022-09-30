/// The subsystem used to tick [/datum/component/aura_healing] instances.
PROCESSING_SUBSYSTEM_DEF(aura_healing)
	name = "Aura Healing"
	flags = SS_NO_INIT | SS_BACKGROUND | SS_KEEP_TIMING
	wait = 0.3 SECONDS
