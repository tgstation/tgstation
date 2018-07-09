// This should only be used by non components trying to listen to a signal
// If you use this inside a component I will replace your eyes with lemons ~ninjanomnom

/datum/component/redirect
	dupe_mode = COMPONENT_DUPE_ALLOWED

/datum/component/redirect/Initialize(list/signals, datum/callback/_callback, flags=NONE)
	//It's not our job to verify the right signals are registered here, just do it.
	if(!LAZYLEN(signals) || !istype(_callback))
		warning("signals are [list2params(signals)], callback is [_callback]]")
		return COMPONENT_INCOMPATIBLE
	if(flags & REDIRECT_TRANSFER_WITH_TURF && isturf(parent))
		RegisterSignal(parent, COMSIG_TURF_CHANGE, .proc/turf_change)
	RegisterSignal(parent, signals, _callback)

/datum/component/redirect/proc/turf_change(path, new_baseturfs, flags, list/transfers)
	transfers += src
