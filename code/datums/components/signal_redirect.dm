/datum/component/redirect
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/datum/callback/callback

/datum/component/redirect/Initialize(list/signals, _callback)
	//It's not our job to verify the right signals are registered here, just do it.
	if(!signals || !signals.len || !_callback)
		. = COMPONENT_INCOMPATIBLE
		CRASH("A redirection component was initialized with incorrect args.")
	for(var/i in 1 to signals.len)
		RegisterSignal(signals[i], _callback)