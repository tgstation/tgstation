/datum/controller/subsystem/shuttle
	var/endvote_passed = FALSE

/datum/controller/subsystem/shuttle/proc/autoEnd()
	if(EMERGENCY_IDLE_OR_RECALLED)
		SSshuttle.emergency.request(null, signal_origin = null, reason = null, red_alert = (SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_RED), silent = TRUE)
		priority_announce("The shift has come to an end and the transfer shuttle called. [SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_RED ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [emergency.timeLeft(600)] minutes.", null, ANNOUNCER_SHUTTLECALLED, "Priority")
		log_game("Round end vote passed. Shuttle has been auto-called.")
		message_admins("Round end vote passed. Shuttle has been auto-called.")
	emergency_no_recall = TRUE
	endvote_passed = TRUE
	SSevents.can_fire = FALSE // we're going home
