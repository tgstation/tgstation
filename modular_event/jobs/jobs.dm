/datum/job/New()
	. = ..()
	if (type != /datum/job/assistant && type != /datum/job/cyborg)
		job_flags &= ~JOB_NEW_PLAYER_JOINABLE

/datum/controller/subsystem/job/GiveRandomJob(mob/dead/new_player/player)
	return AssignRole(player, new /datum/job/assistant)
