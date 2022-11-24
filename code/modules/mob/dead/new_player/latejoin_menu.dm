#define JOB_CHOICE_YES "Yes"
#define JOB_CHOICE_REROLL "Reroll"
#define JOB_CHOICE_CANCEL "Cancel"

/// Makes a list of jobs and pushes them to a DM list selector. Just in case someone did a special kind of fucky-wucky with TGUI.
/datum/latejoin_menu/proc/fallback_ui(mob/dead/new_player/user)
	var/list/jobs = list()
	for(var/datum/job/job in SSjob.joinable_occupations)
		jobs += job.title

	var/input = tgui_input_list(user, "Pick a job to join as:", "Latejoin Job Selection", jobs)

	if(!input)
		return

	user.AttemptLateSpawn(input)

/datum/latejoin_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JobSelection")
		ui.open()

/datum/latejoin_menu/ui_data(mob/user)
	var/mob/dead/new_player/owner = user
	var/list/departments = list()
	var/list/data = list(
		"disable_jobs_for_non_observers" = SSlag_switch.measures[DISABLE_NON_OBSJOBS],
		"round_duration" = DisplayTimeText(world.time - SSticker.round_start_time),
		"departments" = departments,
	)
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				data += list("shuttle_status" = "The station has been evacuated.")
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					data += list("shuttle_status" = "The station is currently undergoing evacuation procedures.")

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"name" = department.department_name,
			"jobs" = department_jobs,
			"color" = department.ui_color,
			"open_slots" = 0,
		)
		departments += list(department_data)

		for(var/datum/job/job_datum as anything in department.department_jobs)
			var/job_availability = owner.IsJobUnavailable(job_datum.title, TRUE)
			var/datum/outfit/outfit = job_datum.outfit
			var/datum/id_trim/id_trim = initial(outfit.id_trim)

			var/list/job_data = list(
				"command" = !!(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND),
				"description" = job_datum.description,
				"prioritized" = !!(job_datum in SSjob.prioritized_jobs),
				"name" = job_datum.title,
				"used_slots" = job_datum.current_positions,
				"open_slots" = job_datum.total_positions,
				"icon" = initial(id_trim.orbit_icon)
			)

			if(job_availability != JOB_AVAILABLE)
				job_data["unavailable_reason"] = get_job_unavailable_error_message(job_availability, job_datum.title)

			department_data["open_slots"] += job_datum.total_positions - job_datum.current_positions

			department_jobs += list(job_data)

	return data

/datum/latejoin_menu/ui_status(mob/user)
	return isnewplayer(user) ? UI_INTERACTIVE : UI_CLOSE

/datum/latejoin_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!ui.user.client || ui.user.client.interviewee || !isnewplayer(ui.user))
		return TRUE

	var/mob/dead/new_player/owner = ui.user

	if(action == "SelectedJob")
		if(params["job"] == "Random")
			var/list/dept_data = list()
			for(var/datum/job_department/department as anything in SSjob.joinable_departments)
				for(var/datum/job/job_datum as anything in department.department_jobs)
					if(owner.IsJobUnavailable(job_datum.title, TRUE) != JOB_AVAILABLE)
						continue
					dept_data += job_datum.title

			if(dept_data.len <= 0) //Congratufuckinglations
				tgui_alert(owner, "There are literally no random jobs available for you on this server, ahelp for assistance.", "Oh No!")
				return TRUE

			var/random_job

			while(random_job != JOB_CHOICE_YES)
				var/random = pick(dept_data)
				random_job = tgui_alert(owner, "[random]?", "Random Job", list(JOB_CHOICE_YES, JOB_CHOICE_REROLL, JOB_CHOICE_CANCEL))

				if(random_job == JOB_CHOICE_CANCEL)
					return TRUE
				if(random_job == JOB_CHOICE_YES)
					params["job"] = random

		if(!SSticker?.IsRoundInProgress())
			tgui_alert(owner, "The round is either not ready, or has already finished...", "Oh No!")
			return TRUE

		if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
			tgui_alert(owner, "There is an administrative lock on entering the game for non-observers!", "Oh No!")
			return TRUE

		//Determines Relevent Population Cap
		var/relevant_cap
		var/hard_popcap = CONFIG_GET(number/hard_popcap)
		var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
		if(hard_popcap && extreme_popcap)
			relevant_cap = min(hard_popcap, extreme_popcap)
		else
			relevant_cap = max(hard_popcap, extreme_popcap)

		if(SSticker.queued_players.len && !(ckey(owner.key) in GLOB.admin_datums))
			if((living_player_count() >= relevant_cap) || (owner != SSticker.queued_players[1]))
				tgui_alert(owner, "The server is full!", "Oh No!")
				return TRUE

		owner.AttemptLateSpawn(params["job"])
		return TRUE

	if(action == "viewpoll")
		var/datum/poll_question/poll = locate(params["viewpoll"]) in GLOB.polls
		owner.poll_player(poll)

	if(action == "votepollref")
		var/datum/poll_question/poll = locate(params["votepollref"]) in GLOB.polls
		owner.vote_on_poll_handler(poll, params)

#undef JOB_CHOICE_YES
#undef JOB_CHOICE_REROLL
#undef JOB_CHOICE_CANCEL
