var/datum/subsystem/processing/fire_burning/SSfire_burning

/datum/subsystem/processing/fire_burning
	name = "Fire Burning"
	priority = 40
	flags = SS_NO_INIT|SS_BACKGROUND
	stat_tag = "F"

	delegate = /obj/.proc/fire_processing

/datum/subsystem/processing/fire_burning/New()
	NEW_SS_GLOBAL(SSfire_burning)

