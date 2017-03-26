
var/datum/controller/subsystem/processing/flightpacks/SSflightpacks
/datum/controller/subsystem/processing/flightpacks
	name = "Flightpack Movement"
	priority = 30
	wait = 2
	stat_tag = "FM"
	flags = SS_NO_INIT|SS_TICKER|SS_KEEP_TIMING
	var/flightsuit_processing = FLIGHTSUIT_PROCESSING_FULL

/datum/controller/subsystem/processing/flightpacks/New()
	NEW_SS_GLOBAL(SSflightpacks)

/datum/controller/subsystem/processing/flightpacks/vv_edit_var()
	..()
	for(var/obj/item/device/flightpack/FP in processing)
		FP.sync_processing(src)
