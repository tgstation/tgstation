/datum/controller/subsystem/shuttle
	var/endvote_passed = FALSE

/datum/controller/subsystem/shuttle/proc/autoEnd()
	if(EMERGENCY_IDLE_OR_RECALLED)
		SSshuttle.emergency.request(silent = TRUE)
		priority_announce("The shift has come to an end and the shuttle called. [SSsecurity_level.current_level == SEC_LEVEL_RED ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [emergency.timeLeft(600)] minutes.", null, ANNOUNCER_SHUTTLECALLED, "Priority")
		log_game("Round end vote passed. Shuttle has been auto-called.")
		message_admins("Round end vote passed. Shuttle has been auto-called.")
	emergencyNoRecall = TRUE
	endvote_passed = TRUE
