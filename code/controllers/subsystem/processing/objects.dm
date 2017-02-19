var/datum/subsystem/processing/objects/SSobj

/datum/subsystem/processing/objects
	name = "Objects"
	priority = 40
	flags = SS_NO_INIT

/datum/subsystem/processing/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/processing/objects/Recover()
	..(SSobj)
