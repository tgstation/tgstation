// This should only be used by non components trying to listen to a signal
// If you use this inside a component I will replace your eyes with lemons ~ninjanomnom

/datum/component/redirect
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/list/signals

/datum/component/redirect/Initialize(list/_signals, flags=NONE)
	//It's not our job to verify the right signals are registered here, just do it.
	if(!LAZYLEN(_signals))
		return COMPONENT_INCOMPATIBLE
	if(flags & REDIRECT_TRANSFER_WITH_TURF && isturf(parent))
		RegisterSignal(parent, COMSIG_TURF_CHANGE, .proc/turf_change)
	
	signals = _signals

/datum/component/redirect/RegisterWithParent()
	for(var/signal in signals)
		RegisterSignal(parent, signal, signals[signal])

/datum/component/redirect/UnregisterFromParent()
	UnregisterSignal(parent, signals)

/datum/component/redirect/proc/turf_change(path, new_baseturfs, flags, list/transfers)
	transfers += src
