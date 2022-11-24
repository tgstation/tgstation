/datum/preference_middleware/jobs
	action_delegations = list(
		"set_job_preference" = PROC_REF(set_job_preference),
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

	preferences.character_preview_view?.update_body()

	return TRUE

/datum/preference_middleware/jobs/get_constant_data()
	var/list/data = list()

	var/list/departments = list()

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"name" = department.department_name,
			"jobs" = department_jobs,
			"color" = department.ui_color,
		)
		departments += list(department_data)

		for(var/datum/job/job_datum as anything in department.department_jobs)
			if(isnull(job_datum.description))
				stack_trace("[job_datum] does not have a description set, yet is a joinable occupation!")
				continue
			var/datum/outfit/outfit = job_datum.outfit
			var/datum/id_trim/id_trim = initial(outfit.id_trim)

			var/list/job_data = list(
				"command" = !!(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND),
				"description" = job_datum.description,
				"name" = job_datum.title,
				"icon" = initial(id_trim.orbit_icon),
			)

			department_jobs += list(job_data)

	data["departments"] = departments

	return data

/datum/preference_middleware/jobs/get_ui_data(mob/user)
	var/list/data = list()

	data["job_preferences"] = preferences.job_preferences

	return data

/datum/preference_middleware/jobs/get_ui_static_data(mob/user)
	var/list/data = list()

	var/list/required_job_playtime = get_required_job_playtime(user)
	if (!isnull(required_job_playtime))
		data += required_job_playtime

	var/list/job_bans = get_job_bans(user)
	if (job_bans.len)
		data["job_bans"] = job_bans

	return data.len > 0 ? data : null

/datum/preference_middleware/jobs/proc/get_required_job_playtime(mob/user)
	var/list/data = list()

	var/list/job_days_left = list()
	var/list/job_required_experience = list()

	for (var/datum/job/job as anything in SSjob.all_occupations)
		var/required_playtime_remaining = job.required_playtime_remaining(user.client)
		if (required_playtime_remaining)
			job_required_experience[job.title] = list(
				"experience_type" = job.get_exp_req_type(),
				"required_playtime" = required_playtime_remaining,
			)

			continue

		if (!job.player_old_enough(user.client))
			job_days_left[job.title] = job.available_in_days(user.client)

	if (job_days_left.len)
		data["job_days_left"] = job_days_left

	if (job_required_experience)
		data["job_required_experience"] = job_required_experience

	return data

/datum/preference_middleware/jobs/proc/get_job_bans(mob/user)
	var/list/data = list()

	for (var/datum/job/job as anything in SSjob.all_occupations)
		if (is_banned_from(user.client?.ckey, job.title))
			data += job.title

	return data
