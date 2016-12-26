
var/datum/subsystem/processing/flightpacks/SSflightpacks
/datum/subsystem/processing/flightpacks
	name = "Flightpack Movement"
	priority = 30
	wait = 2
	stat_tag = "FM"
	flags = SS_NO_INIT|SS_TICKER|SS_KEEP_TIMING

/datum/subsystem/processing/flightpacks/New()
	NEW_SS_GLOBAL(SSflightpacks)
