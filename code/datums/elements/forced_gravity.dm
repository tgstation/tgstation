/datum/element/forced_gravity
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///the level of gravity we force unto our target
	var/gravity
	///whether we will override the turf if it forces no gravity
	var/ignore_turf_gravity

/datum/element/forced_gravity/Attach(datum/target, gravity = 1, ignore_turf_gravity = FALSE, can_override = FALSE)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/our_ref = REF(src)
	if(HAS_TRAIT_FROM(target, TRAIT_FORCED_GRAVITY, our_ref))
		return

	src.gravity = gravity
	src.ignore_turf_gravity = ignore_turf_gravity

	RegisterSignal(target, COMSIG_ATOM_HAS_GRAVITY, PROC_REF(gravity_check), override = can_override)
	if(isturf(target))
		RegisterSignal(target, COMSIG_TURF_HAS_GRAVITY, PROC_REF(turf_gravity_check), override = can_override)

	ADD_TRAIT(target, TRAIT_FORCED_GRAVITY, our_ref)

/datum/element/forced_gravity/Detach(datum/source)
	. = ..()
	var/static/list/signals_b_gone = list(COMSIG_ATOM_HAS_GRAVITY, COMSIG_TURF_HAS_GRAVITY)
	UnregisterSignal(source, signals_b_gone)
	REMOVE_TRAIT(source, TRAIT_FORCED_GRAVITY, REF(src))

/datum/element/forced_gravity/proc/gravity_check(datum/source, turf/location, list/gravs)
	SIGNAL_HANDLER

	if(!ignore_turf_gravity && location.force_no_gravity)
		return FALSE
	gravs += gravity

	return TRUE

/datum/element/forced_gravity/proc/turf_gravity_check(datum/source, atom/checker, list/gravs)
	SIGNAL_HANDLER
	gravity_check(null, source, gravs)
