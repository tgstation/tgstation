///like normal callbacks but they also record their creation time for measurement purposes
/datum/callback/verb_callback
	///the REALTIMEOFDAY this callback datum was created in. used for testing latency
	var/creation_time = 0

/datum/callback/verb_callback/New(thingtocall, proctocall, ...)
	creation_time = REALTIMEOFDAY
	. = ..()
