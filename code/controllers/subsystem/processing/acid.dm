var/datum/subsystem/processing/acid/SSacid

/datum/subsystem/processing/acid
	name = "Acid"
	priority = 40
	flags = SS_NO_INIT|SS_BACKGROUND
	
	delegate = /obj/.proc/acid_processing

/datum/subsystem/processing/acid/New()
	NEW_SS_GLOBAL(SSacid)

/datum/subsystem/processing/Recover()
	..(SSacid)