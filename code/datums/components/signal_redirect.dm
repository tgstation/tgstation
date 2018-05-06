/datum/component/redirect
	dupe_mode = COMPONENT_DUPE_ALLOWED

/datum/component/redirect/Initialize(list/signals, datum/callback/_callback)
	//It's not our job to verify the right signals are registered here, just do it.
	if(!LAZYLEN(signals) || !istype(_callback))
		warning("signals are [list2params(signals)], callback is [_callback]]")
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(signals, _callback)
