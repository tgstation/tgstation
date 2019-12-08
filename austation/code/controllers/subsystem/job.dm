/datum/controller/subsystem/job/proc/DisableJob(job_path)
	for(var/I in occupations)
		var/datum/job/J = I
		if(istype(J, job_path))
			J.total_positions = 0
			J.spawn_positions = 0
			J.current_positions = 0
