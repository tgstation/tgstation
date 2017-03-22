//Fires five times every second.

GLOBAL_REAL(SSfastprocess, /datum/controller/subsystem/processing/fastprocess)
/datum/controller/subsystem/processing/fastprocess
	name = "Fast Processing"
	wait = 2
	stat_tag = "FP"

/datum/controller/subsystem/processing/fastprocess/New()
	NEW_SS_GLOBAL(SSfastprocess)
