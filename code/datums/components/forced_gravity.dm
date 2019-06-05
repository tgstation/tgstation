/datum/component/forced_gravity
	var/gravity
	var/ignore_space	//If forced gravity should also work on space turfs

/datum/component/forced_gravity/Initialize(forced_value = 1, ignore_space = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_HAS_GRAVITY, .proc/gravity_check)
	if(isturf(parent))
		RegisterSignal(parent, COMSIG_TURF_HAS_GRAVITY, .proc/turf_gravity_check)

	gravity = forced_value
	src.ignore_space = ignore_space

/datum/component/forced_gravity/proc/gravity_check(datum/source, turf/location, list/gravs)
	if(!ignore_space && isspaceturf(location))
		return
	gravs += gravity

/datum/component/forced_gravity/proc/turf_gravity_check(datum/source, atom/checker, list/gravs)
	return gravity_check(null, parent, gravs)