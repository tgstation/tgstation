/// The subsystem used to tick auras ([/datum/component/aura_healing] and [/datum/component/damage_aura]).
PROCESSING_SUBSYSTEM_DEF(aura)
	name = "Aura"
	flags = SS_NO_INIT | SS_BACKGROUND | SS_KEEP_TIMING
	wait = 0.3 SECONDS
