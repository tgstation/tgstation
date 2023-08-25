/// The subsystem used to tick [/datum/component/netpod_healing] instances.
PROCESSING_SUBSYSTEM_DEF(netpod_healing)
	name = "Netpod Healing"
	flags = SS_NO_INIT | SS_BACKGROUND | SS_KEEP_TIMING
	wait = 0.6 SECONDS
