var/datum/subsystem/processing/mobs/SSmob

/datum/subsystem/processing/mobs
	name = "Mobs"
	init_order = 4
	display_order = 4
	priority = 100
	wait = 20
	flags = SS_NO_INIT|SS_KEEP_TIMING

	stat_tag = "Mob"

	delegate = /mob/.proc/Life
	processing_list = null

/datum/subsystem/processing/mobs/New()
	if(!mob_list)
		LAZYINITLIST(processing_list)
		mob_list = processing_list
	else
		processing_list = mob_list
	NEW_SS_GLOBAL(SSmob)

/datum/subsystem/processing/mobs/Recover()
	..(SSmob)