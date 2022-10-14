/// The subsystem used to tick [/datum/component/gravity_aura] instances.
PROCESSING_SUBSYSTEM_DEF(gravity_aura)
	name = "Gravity Aura"
	flags = SS_NO_INIT | SS_BACKGROUND | SS_KEEP_TIMING
	wait = 0.3 SECONDS
