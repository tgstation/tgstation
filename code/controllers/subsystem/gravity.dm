var/datum/subsystem/gravity/SSgravity

/datum/subsystem/gravity
	name = "Gravity"
	priority = 75
	wait = 1
	init_order = -100
	flags = SS_KEEP_TIMING | SS_BACKGROUND

	var/list/currentrun = list()
	var/list/areas = list()
	var/recalculation_cost = 0

/datum/subsystem/gravity/New()
	NEW_SS_GLOBAL(SSgravity)

/datum/subsystem/gravity/Initialize()
	for(var/area/A in world)
		areas += A
	. = ..()

/datum/subsystem/gravity/proc/recalculate_atoms()
	. = list()
	var/tempcost = world.timeofday
	for(var/area/A in areas)
		if(!A.has_gravity && !A.gravity_generator && !A.gravity_overriding)
			continue
		for(var/atom/movable/AM in A.contents_affected_by_gravity)
			. += AM
	recalculation_cost = world.timeofday - tempcost

/datum/subsystem/gravity/fire(resumed = FALSE)
	if(!resumed)
		currentrun = recalculate_atoms()
	while(currentrun.len)
		var/atom/movable/AM = currentrun[currentrun.len]
		if(AM)
			AM.gravity_act()
		currentrun.len--
		if(MC_TICK_CHECK)
			return
