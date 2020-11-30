/datum/controller/subsystem/job/proc/FreeRole(rank)
	if(!rank)
		return
	var/datum/job/job = GetJob(rank)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)
