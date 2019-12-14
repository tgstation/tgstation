/datum/controller/subsystem/job/proc/DisableJob(job_path)
	for(var/I in occupations)
		var/datum/job/J = I
		if(istype(J, job_path))
			J.total_positions = 0
			J.spawn_positions = 0
			J.current_positions = 0

/datum/controller/subsystem/job/proc/AustationFillBannedPosition()
	for(var/p in unassigned)
		var/mob/dead/new_player/player = p
		if(is_banned_from(player.ckey, CATBAN))
			AssignRole(player, overflow_role)
