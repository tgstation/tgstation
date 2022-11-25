/// Helper proc for converting a job outfit, trim or datum to an FA icon for use in TGUI. Returns "question" if it can't find a match.
/proc/job_to_tgui_icon(datum/job)
	var/datum/job/job_datum
	var/datum/outfit/outfit
	var/datum/id_trim/trim
	var/found_icon

	if(istype(job, /datum/job))
		job_datum = job
		outfit = job_datum.outfit

	else if(istype(job, /datum/outfit))
		outfit = job

	else if(istype(job, /datum/id_trim))
		trim = job

	if(outfit)
		trim = initial(outfit.id_trim)

	if(trim)
		found_icon = initial(trim.orbit_icon)

	if(!found_icon)
		// Handling for special roles that don't have an outfit.
		if(!ispath(job))
			job = job.type

		switch(job)
			if(/datum/job/ai)
				return "eye"
			if(/datum/job/cyborg)
				return "robot"
			if(/datum/job/personal_ai)
				return "mobile_alt"

	if(found_icon)
		return found_icon

	return "question" // WHO ARE YOU?! WHAT DID YOU DO TO MY SON?!
