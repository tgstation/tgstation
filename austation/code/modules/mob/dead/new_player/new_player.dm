/mob/dead/new_player/IsJobUnavailable(rank, latejoin = FALSE)
	. = ..()
	if(. == JOB_AVAILABLE)
		if(is_banned_from(src.ckey, CATBAN) && rank != SSjob.overflow_role)
			return JOB_UNAVAILABLE_BANNED
