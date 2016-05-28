var/datum/subsystem/icon_smooth/SSicon_smooth

/datum/subsystem/icon_smooth
	name = "Icon Smoothing"
	init_order = -5
	wait = 2
	priority = 30
	flags = SS_POST_FIRE_TIMING

	var/list/smooth_queue = list()

/datum/subsystem/icon_smooth/New()
	NEW_SS_GLOBAL(SSicon_smooth)

/datum/subsystem/icon_smooth/fire()
	for(var/atom in smooth_queue)
		ss_smooth_icon(atom)
		smooth_queue -= atom
		if (MC_TICK_CHECK)
			return

/datum/subsystem/icon_smooth/Initialize()
	smooth_zlevel(1,TRUE)
	smooth_zlevel(2,TRUE)
	for(var/V in smooth_queue)
		var/atom/A = V
		if(A.z == 1 || A.z == 2)
			smooth_queue -= A
	..()