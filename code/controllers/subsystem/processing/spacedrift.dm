var/datum/subsystem/processing/spacedrift/SSspacedrift

/datum/subsystem/processing/spacedrift
	name = "Space Drift"
	priority = 30
	wait = 5
	flags = SS_NO_INIT|SS_KEEP_TIMING

	stat_tag = "SD"
	delegate = /atom/movable/.proc/Spacedrift	

/datum/subsystem/processing/spacedrift/New()
	NEW_SS_GLOBAL(SSspacedrift)

/datum/subsystem/processing/spacedrift/Recover()
	..(SSspacedrift)

/atom/movable/proc/Spacedrift()		
	if (inertia_next_move > world.time)
		return

	if (!loc || loc != inertia_last_loc || Process_Spacemove(0))
		inertia_dir = 0

	if (inertia_dir)
		inertia_last_loc = null
		return PROCESS_KILL

	var/old_dir = dir
	var/old_loc = loc
	inertia_moving = TRUE
	step(src, inertia_dir)
	inertia_moving = FALSE
	inertia_next_move = world.time + inertia_move_delay
	if (loc == old_loc)
		inertia_dir = 0

	setDir(old_dir)
	inertia_last_loc = loc