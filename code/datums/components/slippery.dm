/datum/component/slippery
	var/intensity
	var/lube_flags
	var/mob/slip_victim

/datum/component/slippery/New(datum/P, _intensity, _lube_flags = NONE)
	..()
	intensity = max(_intensity, 0)
	lube_flags = _lube_flags
	if(ismovableatom(P))
		RegisterSignal(COMSIG_MOVABLE_CROSSED, .proc/Slip)
	else
		RegisterSignal(COMSIG_ATOM_ENTERED, .proc/Slip)

/datum/component/slippery/proc/Slip(atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && !victim.is_flying() && victim.slip(intensity, parent, lube_flags))
		slip_victim = victim
		return TRUE

/datum/component/slippery/AfterComponentActivated()
	slip_victim = null
