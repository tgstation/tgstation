/datum/component/redirect
	dupe_mode = COMPONENT_DUPE_ALLOWED

/datum/component/redirect/Initialize(list/signals, _callback)
	//It's not our job to verify the right signals are registered here, just do it.
	if(!signals || !signals.len || !_callback)
		. = COMPONENT_INCOMPATIBLE
		CRASH("A redirection component was initialized with incorrect args.")
	RegisterSignal(signals, _callback)