//Fires once every second.

var/datum/subsystem/processing/mediumprocess/SSmediumprocess
/datum/subsystem/processing/mediumprocess
	name = "Medium Processing"
	wait = 10
	stat_tag = "MP"
	priority = 25
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT

/datum/subsystem/processing/mediumprocess/New()
	NEW_SS_GLOBAL(SSmediumprocess)

/datum/subsystem/processing/mediumprocess/Recover()
	..(SSmediumprocess)