/// Adds 1 available slot for the position, if possible
/datum/controller/subsystem/job/proc/free_job_position(position)
	if(!position)
		return

	var/datum/job/job_to_modify = get_job(position)
	if(!job_to_modify)
		return

	var/new_current_positions = max(0, job_to_modify.current_positions - 1)
	job_debug("Freeing position: [position]; was: [job_to_modify.current_positions]; now: [new_current_positions]")
	job_to_modify.current_positions = new_current_positions
