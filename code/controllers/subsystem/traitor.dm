SUBSYSTEM_DEF(traitor)
	name = "Traitor"
	flags = SS_KEEP_TIMING
	wait = 1 MINUTES
	/// The current reputation that all traitors should be at in the round
	var/current_global_reputation = 0
	/// The current uplink handlers being managed
	var/list/datum/uplink_handler/uplink_handlers

/datum/controller/subsystem/skills/fire(resumed)
	current_global_reputation += 1 MINUTES


