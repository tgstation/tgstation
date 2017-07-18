/datum/component/slippery
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/intensity
	var/lube_flags = NONE
	var/mob/last_successful_slip

/datum/component/slippery/New(datum/P, _intensity, _lube_flags)
	intensity = _intensity
	lube_flags = _lube_flags
	if(ismovableatom(O))
		RegisterSignal(COMSIG_ATOM_CROSSED, .proc/Slip)
	else
		RegisterSignal(COMSIG_ATOM_ENTERED, .proc/Slip)

/datum/component/slippery/Destroy()
	last_successful_slip = null
	return ..()

/datum/component/slippery/proc/Slip(atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && !victim.is_flying() && victim.slip(intensity, null, parent, lube_flags))
		last_successful_slip = victim
		addtimer(CALLBACK(src, .proc/ClearMobRef), 0, TIMER_UNIQUE)
		return TRUE

/datum/component/slippery/proc/ClearMobRef()
	last_successful_slip = null
