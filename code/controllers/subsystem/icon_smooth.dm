var/datum/subsystem/icon_smooth/SSicon_smooth

/datum/subsystem/icon_smooth
	name = "Icon Smoothing"
	init_order = -5
	wait = 1
	priority = 35
	flags = SS_TICKER

	var/list/smooth_queue = list()

/datum/subsystem/icon_smooth/New()
	NEW_SS_GLOBAL(SSicon_smooth)

/datum/subsystem/icon_smooth/fire()
	while(smooth_queue.len)
		var/atom/A = smooth_queue[smooth_queue.len]
		smooth_queue.len--
		ss_smooth_icon(A)
		if (MC_TICK_CHECK)
			return
	if (!smooth_queue.len)
		can_fire = 0

/datum/subsystem/icon_smooth/Initialize()
	smooth_zlevel(1,TRUE)
	smooth_zlevel(2,TRUE)
	for(var/V in smooth_queue)
		var/atom/A = V
		if(A.z == 1 || A.z == 2)
			smooth_queue -= A
	..()