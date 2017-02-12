var/datum/subsystem/gravity/SSgravity

/datum/subsystem/gravity
	name = "Gravity"
	priority = 75
	wait = 1
	init_order = -100
	can_fire = FALSE
	flags = SS_KEEP_TIMING | SS_BACKGROUND

	var/list/areas = list()
	var/list/currentrun = list()
	var/list/processing = list()

/datum/subsystem/gravity/New()
	NEW_SS_GLOBAL(SSgravity)

/datum/subsystem/gravity/Initialize()
	for(var/area/A in world)
		areas += A

/datum/subsystem/gravity/proc/calculate_area(var/area/A)
	var/str = A.gravity_strength
	var/dir = A.gravity_direction
	var/trw = A.gravity_throwing
	var/stun = A.gravity_stunning
	var/ovr = A.gravity_overriding
	for(var/atom/movable/AM in A)
		processing += AM
		processing[AM] = list()
		processing[AM]["strength"] = str
		processing[AM]["throwing"] = trw
		processing[AM]["stun"] = stun
		processing[AM]["direction"] = dir
		processing[AM]["override"] = ovr
	A.gravity_stunning = FALSE
	A.gravity_throwing = FALSE

/datum/subsystem/gravity/fire(resumed = FALSE)
	if(!resumed)
		var/calculation_cost = world.time
		processing = list()
		for(var/area/A in areas)
			calculate_area(A)
		currentrun = processing.Copy()
		calculation_cost = (world.time - calculation_cost)
		world << "<span class='danger'>DEBUG: Calculation of all areas took [calculation_cost] ticks!</span>"
	var/list/current_run = src.currentrun
	while(current_run.len)
		var/atom/movable/A = currentrun[current_run.len]
		A.gravity_act(direction = current_run[A]["direction"], strength = current_run[A]["strength"], throwing = current_run[A]["throwing"], stun = current_run[A]["stun"], override = current_run[A]["override"])
