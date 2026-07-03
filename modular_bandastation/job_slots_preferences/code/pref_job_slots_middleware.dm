/datum/preference_middleware/pref_job_slots
	action_delegations = list(
			"set_job_slot" = PROC_REF(set_job_slot),
			"reset_job_slots" = PROC_REF(reset_job_slots),
		)

/datum/preference_middleware/pref_job_slots/get_ui_data(mob/user)
	var/list/data = list()

	data["pref_job_slots"] = preferences.pref_job_slots
	data["profile_index"] = preferences.get_slot_options()

	return data

/datum/preference_middleware/pref_job_slots/proc/set_job_slot(list/params, mob/user)
	if(!params["job"] || isnull(params["slot"]))
		CRASH("Missing parameter in job slot update request")

	var/job_title = params["job"]
	var/slot_index = params["slot"]

	if(JOB_SLOT_RANDOMISED_SLOT > slot_index > preferences.max_save_slots)
		CRASH("Invalid slot index [slot_index] for job [job_title] in job slot update request")

	if(!SSjob.get_job(job_title))
		CRASH("Invalid job title [job_title] in job slot update request")

	if(slot_index == JOB_SLOT_CURRENT_SLOT)
		preferences.pref_job_slots.Remove(job_title)
	else
		preferences.pref_job_slots[job_title] = slot_index

	preferences.save_preferences()
	return TRUE

/datum/preference_middleware/pref_job_slots/proc/reset_job_slots(list/params, mob/user)
	preferences.reset_job_slots()
	return TRUE

#undef JOB_SLOT_RANDOMISED_SLOT
#undef JOB_SLOT_CURRENT_SLOT
