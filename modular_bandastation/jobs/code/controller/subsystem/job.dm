/datum/controller/subsystem/job/proc/pick_highest_priority_job(list/jobs)
	PRIVATE_PROC(TRUE)

	if(!length(jobs))
		return null

	return shuffle_and_sort_jobs_by_staffing_priority(jobs)[1]

/datum/controller/subsystem/job/proc/give_priority_job(mob/dead/new_player/player)
	job_debug("GRJ: Giving random priority job, Player: [player]")
	if(QDELETED(player))
		job_debug("GRJ: Player is deleted, aborting")
		return FALSE

	for(var/datum/job/job as anything in shuffle_and_sort_jobs_by_staffing_priority(joinable_occupations))
		if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
			job_debug("GRJ: Job lacks spawn positions to be eligible, Player: [player], Job: [job]")
			continue

		if(istype(job, get_job_type(overflow_role))) // We don't want to give him assistant, that's boring!
			job_debug("GRJ: Skipping overflow role, Player: [player], Job: [job]")
			continue

		if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) //If you want a command position, select it!
			job_debug("GRJ: Skipping command role, Player: [player], Job: [job]")
			continue

		// This check handles its own output to job_debug.
		if(check_job_eligibility(player, job, "GRJ", add_job_to_log = TRUE) != JOB_AVAILABLE)
			continue

		if(assign_role(player, job, do_eligibility_checks = FALSE))
			job_debug("GRJ: Random job given, Player: [player], Job: [job]")
			return TRUE

		job_debug("GRJ: Player eligible but assign_role failed, Player: [player], Job: [job]")
		
	return FALSE

/datum/controller/subsystem/job/proc/shuffle_and_sort_jobs_by_staffing_priority(list/jobs)
	if(!length(jobs))
		return list()

	return sortTim(shuffle(jobs), GLOBAL_PROC_REF(cmp_job_staffing_priority))
