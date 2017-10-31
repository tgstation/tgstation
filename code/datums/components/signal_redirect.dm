/datum/component/redirect
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/datum/callback/callback

/datum/component/redirect/Initialize(list/signals, _callback)
	//It's not our job to verify the right signals are registered here, just do it.
	if(!signals || !_callback)
		WARNING("A redirection component was initialized with incorrect args.")
		return COMPONENT_INCOMPATIBLE
	for(var/i in 1 to signals.len)
		RegisterSignal(signals[i], .proc/relay_signal)

/datum/component/redirect/proc/relay_signal(...)
	callback.Invoke(args)