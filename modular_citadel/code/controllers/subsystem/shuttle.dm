/datum/controller/subsystem/shuttle/proc/autoEnd() //CIT CHANGE - allows shift to end after 3 hours has passed.
	if(world.time > auto_call && EMERGENCY_IDLE_OR_RECALLED) //3 hours
		SSshuttle.emergency.request(null, 1.5)
		priority_announce("The shift has come to an end and the shuttle called.")
		log_game("Round time limit reached. Shuttle has been auto-called.")
		message_admins("Round time limit reached. Shuttle called.")