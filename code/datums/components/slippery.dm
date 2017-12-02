/datum/component/slippery
	var/intensity
	var/lube_flags
	var/mob/slip_victim

/datum/component/slippery/Initialize(_intensity, _lube_flags = NONE)
	intensity = max(_intensity, 0)
	lube_flags = _lube_flags
	RegisterSignal(list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/Slip)

/datum/component/slippery/proc/Slip(atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && !victim.is_flying() && victim.slip(intensity, parent, lube_flags))
		slip_victim = victim
		return COMPONENT_ACTIVATED

/datum/component/slippery/AfterComponentActivated()
	slip_victim = null
