var/datum/subsystem/gravity/SSgravity

/datum/subsystem/gravity
	name = "Gravity"
	priority = 75
	wait = 1
	init_order = -100
	flags = SS_KEEP_TIMING | SS_BACKGROUND

	var/list/atoms_pending_calculation = list()
	var/calculation_cost = 0
	var/recalculating = FALSE
	var/recalculation_cost = 0
	var/list/areas = list()
	var/list/currentrun = list()
	var/list/processing = list()

/datum/subsystem/gravity/New()
	NEW_SS_GLOBAL(SSgravity)

/datum/subsystem/gravity/Initialize()
	for(var/area/A in world)
		areas += A

/datum/subsystem/gravity/proc/calculate_atom(atom/movable/AM)
	var/turf/T = get_turf(AM)
	if(!T)
		T = get_turf(AM.loc)
		if(!T)
			return FALSE
	var/area/A = T.loc
	processing += AM
	processing[AM] = list()
	processing[AM]["strength"] = A.gravity_strength
	processing[AM]["direction"] = A.gravity_direction
	processing[AM]["throwing"] = A.gravity_throwing
	processing[AM]["stun"] = A.gravity_stunning
	processing[AM]["override"] = A.gravity_overriding

/datum/subsystem/gravity/proc/calculate_all_atoms(resumed = FALSE)
	if(!resumed)
		recalculating = TRUE
		processing = list()
		atoms_pending_calculation = atoms_affected_by_gravity.Copy()
		calculation_cost = world.timeofday
	while(atoms_pending_calculation.len)
		calculate_atom(atoms_pending_calculation[atoms_pending_calculation.len])
		if(MC_TICK_CHECK)
			return -1
	for(var/area/A in world)
		A.gravity_stunning = FALSE
		A.gravity_throwing = FALSE
	recalculation_cost = world.timeofday - calculation_cost
	recalculating = FALSE
	world << "<span class='danger'>Recalculation took [recalculation_cost] deciseconds!</span>"

/datum/subsystem/gravity/fire(resumed = FALSE)
	if(!resumed)
		currentrun = atoms_affected_by_gravity.Copy()
	while(currentrun.len)
		var/atom/movable/AM = currentrun[currentrun.len]
		AM.gravity_act()
		currentrun.len--
		if(MC_TICK_CHECK)
			return
