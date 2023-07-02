SUBSYSTEM_DEF(challenges)
	name = "Challenges"
	wait = 10 SECONDS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	priority = FIRE_PRIOTITY_LIQUIDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	///list of challenges that have something we need to process
	var/list/processing_challenges = list()

/datum/controller/subsystem/challenges/stat_entry(msg)
	msg += "RC:[length(processing_challenges)]"
	return ..()

/datum/controller/subsystem/challenges/fire(resumed = FALSE)
	if(!processing_challenges)
		return
	for(var/datum/challenge/listed as anything in processing_challenges)
		listed.on_process()

/datum/controller/subsystem/challenges/proc/apply_challenges(client/owner)
