/datum/controller/subsystem/job/proc/FreeRole(rank)
	if(!rank)
		return
	job_debug("Freeing role: [rank]")
	var/datum/job/job = get_job(rank)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)

/// Used for clocking back in, re-claiming the previously freed role. Returns false if no slot is available.
/datum/controller/subsystem/job/proc/OccupyRole(rank)
	if(!rank)
		return FALSE
	job_debug("Occupying role: [rank]")
	var/datum/job/job = get_job(rank)
	if(!job || job.current_positions >= job.total_positions)
		return FALSE
	job.current_positions = job.current_positions + 1
	return TRUE
