/datum/preference_middleware/jobs
	action_delegations = list(
		"set_job_preference" = .proc/set_job_preference,
	)

/datum/preference_middleware/jobs/proc/set_job_preference(list/params, mob/user)
	var/job_title = params["job"]
	var/level = params["level"]

	if (level != null && level != JP_LOW && level != JP_MEDIUM && level != JP_HIGH)
		return FALSE

	var/datum/job/job = SSjob.GetJob(job_title)

	if (isnull(job))
		return FALSE

	if (job.faction != FACTION_STATION)
		return FALSE

	if (!preferences.set_job_preference_level(job, level))
		return FALSE

	preferences.character_preview_view.update_body()
	return TRUE

/datum/preference_middleware/jobs/get_ui_data(mob/user)
	var/list/data = list()

	data["job_preferences"] = preferences.job_preferences

	return data

/datum/preference_middleware/jobs/get_ui_static_data(mob/user)
	var/list/data = list()

	var/list/job_days_left = get_job_days_left(user)
	if (job_days_left.len)
		data["job_days_left"] = job_days_left

	var/list/job_bans = get_job_bans(user)
	if (job_bans.len)
		data["job_bans"] = job_bans

	return data.len > 0 ? data : null

/datum/preference_middleware/jobs/proc/get_job_days_left(mob/user)
	var/list/data = list()

	for (var/datum/job/job as anything in SSjob.all_occupations)
		var/days_left = job.available_in_days(user.client)
		if (days_left > 0)
			data[job.title] = days_left

	return data

/datum/preference_middleware/jobs/proc/get_job_bans(mob/user)
	var/list/data = list()

	for (var/datum/job/job as anything in SSjob.all_occupations)
		if (is_banned_from(user.client?.ckey, job.title))
			data += job.title

	return data
