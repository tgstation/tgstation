var/datum/subsystem/processing/icon_smooth/SSicon_smooth

/datum/subsystem/processing/icon_smooth
	name = "Icon Smoothing"
	init_order = -5
	wait = 1
	priority = 35
	flags = SS_TICKER

	stat_tag = "IS"
	processing_list = null	//1 queue
	delegate = /atom/.proc/smooth_icon

/datum/subsystem/processing/icon_smooth/New()
	processing_list = run_cache	//1 queue
	NEW_SS_GLOBAL(SSicon_smooth)

/datum/subsystem/processing/icon_smooth/Initialize()
	smooth_zlevel(1,TRUE)
	smooth_zlevel(2,TRUE)
	var/queue = run_cache
	run_cache = list()
	processing_list = run_cache	//1 queue
	for(var/V in queue)
		var/atom/A = V
		if(!A || A.z <= 2)
			continue
		A.smooth_icon()
		CHECK_TICK
	..()

/datum/subsystem/processing/icon_smooth/fire()
	..(TRUE)	//never copy processing_list