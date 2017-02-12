var/datum/subsystem/gravity/SSgravity

/datum/subsystem/gravity
	name = "Gravity"
	priority = 75
	wait = 1
	init_order = -100
	flags = SS_KEEP_TIMING | SS_BACKGROUND

	var/list/currentrun = list()
	var/list/areas = list()

/datum/subsystem/gravity/New()
	NEW_SS_GLOBAL(SSgravity)

/datum/subsystem/gravity/Initialize()
	for(var/area/A in world)
		areas += A
	. = ..()

/datum/subsystem/gravity/fire(resumed = FALSE)
	if(!resumed)
		currentrun = atoms_affected_by_gravity.Copy()
	while(currentrun.len)
		var/atom/movable/AM = currentrun[currentrun.len]
		if(AM)
			AM.gravity_act()
		else
			atoms_affected_by_gravity -= AM
		currentrun.len--
		if(MC_TICK_CHECK)
			return
