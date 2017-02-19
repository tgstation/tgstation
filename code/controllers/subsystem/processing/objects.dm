var/datum/subsystem/processing/objects/SSobj

/datum/subsystem/processing/objects
	name = "Objects"
	priority = 40
	wait = 20

/datum/subsystem/processing/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/processing/objects/Recover()
	..(SSobj)
