//Fires five times every second.

var/datum/controller/subsystem/processing/fastprocess/SSfastprocess
/datum/controller/subsystem/processing/fastprocess
	name = "Fast Processing"
	wait = 2
	stat_tag = "FP"

/datum/controller/subsystem/processing/fastprocess/New()
	NEW_SS_GLOBAL(SSfastprocess)
