/datum/component/slippery
	var/intensity
	var/lube_flags
	var/datum/callback/callback

/datum/component/slippery/Initialize(_intensity, _lube_flags = NONE, datum/callback/_callback)
	intensity = max(_intensity, 0)
	lube_flags = _lube_flags
	callback = _callback
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/Slip)

/datum/component/slippery/proc/Slip(datum/source, atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && !victim.is_flying() && victim.slip(intensity, parent, lube_flags) && callback)
		callback.Invoke(victim)
