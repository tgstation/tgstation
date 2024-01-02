/datum/job
	///Whether the job is an 'Officer', the leader of the ship.
	var/officer = FALSE

/**
 * Gets the job slots from our initial ship template, and verifies if that job is available.
 * Excludes non-player job jobs (such as unassigned)
 * Will run as normal if there's no ship assigned.
 * Sets the Captain as the 'overflow' job (This does nothing in practice, as we don't expand the job slots).
 * If a job is not meant to show up in prefs menu, we remove their new player joinable flag before sending it through.
 */
/datum/job/map_check()
	//let non-player jobs function properly.
	if(!(job_flags & JOB_NEW_PLAYER_JOINABLE))
		return TRUE
	if(!SSovermap.set_initial_ship())
		return ..()

	var/static/list/roundstart_ship_jobs
	if(!roundstart_ship_jobs)
		var/datum/map_template/shuttle/voidcrew/voidcrew_ship = new SSovermap.initial_ship_template
		roundstart_ship_jobs = voidcrew_ship.assemble_job_slots()
		qdel(voidcrew_ship)

	for(var/datum/job/job as anything in roundstart_ship_jobs)
		if(type != job.type)
			continue
		if(job.officer)
			SSjob.overflow_role = type
		return TRUE
	job_flags ^= JOB_NEW_PLAYER_JOINABLE
	return TRUE
