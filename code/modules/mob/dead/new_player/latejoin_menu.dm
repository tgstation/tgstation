#define JOB_CHOICE_YES "Yes"
#define JOB_CHOICE_REROLL "Reroll"
#define JOB_CHOICE_CANCEL "Cancel"

GLOBAL_DATUM_INIT(latejoin_menu, /datum/latejoin_menu, new)

/// Makes a list of jobs and pushes them to a DM list selector. Just in case someone did a special kind of fucky-wucky with TGUI.
/datum/latejoin_menu/proc/fallback_ui(mob/dead/new_player/user)
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		jobs += job.title

	var/input_contents = input(user, "Pick a job to join as:", "Latejoin Job Selection") as null|anything in jobs

	if(!input_contents)
		return

	user.AttemptLateSpawn(input_contents)

/datum/latejoin_menu/ui_close(mob/dead/new_player/user)
	. = ..()
	if(istype(user))
		user.jobs_menu_mounted = TRUE // Don't flood a user's chat if they open and close the UI.

/datum/latejoin_menu/ui_interact(mob/dead/new_player/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// In case they reopen the GUI
		// FIXME: this can cause a runtime since user can be a living mob
		if(istype(user))
			user.jobs_menu_mounted = FALSE
			addtimer(CALLBACK(src, PROC_REF(scream_at_player), user), 5 SECONDS)

		ui = new(user, src, "JobSelection", "Latejoin Menu")
		ui.open()

/datum/latejoin_menu/proc/scream_at_player(mob/dead/new_player/player)
	if(!player.jobs_menu_mounted)
		to_chat(player, span_notice("If the late join menu isn't showing, hold CTRL while clicking the join button!"))

/datum/latejoin_menu/ui_data(mob/user)
	var/mob/dead/new_player/owner = user
	var/list/departments = list()
	var/list/data = list(
		"disable_jobs_for_non_observers" = SSlag_switch.measures[DISABLE_NON_OBSJOBS],
		"round_duration" = DisplayTimeText(world.time - SSticker.round_start_time, round_seconds_to = 1),
		"departments" = departments,
	)
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				data["shuttle_status"] = "The station has been evacuated."
			if(SHUTTLE_CALL, SHUTTLE_DOCKED, SHUTTLE_IGNITING, SHUTTLE_ESCAPE)
				if(!SSshuttle.canRecall())
					data["shuttle_status"] = "The station is currently undergoing evacuation procedures."

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"open_slots" = 0,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			//Jobs under multiple departments should only be displayed if this is their first department or the command department
			if(LAZYLEN(job_datum.departments_list) > 1 && job_datum.departments_list[1] != department.type && !(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue

			var/job_availability = owner.IsJobUnavailable(job_datum.title, latejoin = TRUE)

			var/list/job_data = list(
				"prioritized" = (job_datum in SSjob.prioritized_jobs),
				"used_slots" = job_datum.current_positions,
				"open_slots" = job_datum.total_positions < 0 ? "∞" : job_datum.total_positions,
			)

			if(job_availability != JOB_AVAILABLE)
				if (job_datum.job_flags & JOB_HIDE_WHEN_EMPTY)
					continue
				job_data["unavailable_reason"] = get_job_unavailable_error_message(job_availability, job_datum.title)

			if(job_datum.total_positions < 0)
				department_data["open_slots"] = "∞"

			if(department_data["open_slots"] != "∞")
				if(job_datum.total_positions - job_datum.current_positions > 0)
					department_data["open_slots"] += job_datum.total_positions - job_datum.current_positions

			department_jobs[job_datum.title] = job_data

	return data

/datum/latejoin_menu/ui_static_data(mob/user)
	var/list/departments = list()
	var/mob/dead/new_player/owner = user

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"color" = department.ui_color,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			//Jobs under multiple departments should only be displayed if this is their first department or the command department
			if(LAZYLEN(job_datum.departments_list) > 1 && job_datum.departments_list[1] != department.type && !(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue
			if((job_datum.job_flags & JOB_HIDE_WHEN_EMPTY) && owner.IsJobUnavailable(job_datum.title, latejoin = TRUE) != JOB_AVAILABLE)
				continue

			var/list/job_data = list(
				"command" = !!(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND),
				"description" = job_datum.description,
			)

			department_jobs[job_datum.title] = job_data

	return list("departments_static" = departments)

/datum/latejoin_menu/ui_state(mob/user)
	return GLOB.new_player_state

/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!ui.user.client || ui.user.client.interviewee || !isnewplayer(ui.user))
		return TRUE

	var/mob/dead/new_player/owner = ui.user

	switch(action)
		if("ui_mounted_with_no_bluescreen")
			owner.jobs_menu_mounted = TRUE
		if("select_job")
			if(params["job"] == "Random")
				var/job = get_random_job(owner)
				if(!job)
					return TRUE

				params["job"] = job

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

			// SAFETY: AttemptLateSpawn has it's own sanity checks. This is perfectly safe.
			owner.AttemptLateSpawn(params["job"])
		if("viewpoll")
			var/datum/poll_question/poll = locate(params["viewpoll"]) in GLOB.polls
			if(!poll)
				return TRUE

			owner.poll_player(poll)
			return TRUE

		if("votepollref")
			var/datum/poll_question/poll = locate(params["votepollref"]) in GLOB.polls
			if(!poll)
				return TRUE

			owner.vote_on_poll_handler(poll, params)
			return TRUE

/// Gives the user a random job that they can join as, and prompts them if they'd actually like to keep it, rerolling if not. Cancellable by the user.
/// WARNING: BLOCKS THREAD!
/datum/latejoin_menu/proc/get_random_job(mob/dead/new_player/owner)
	var/list/dept_data = list()

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		for(var/datum/job/job_datum as anything in department.department_jobs)
			if(owner.IsJobUnavailable(job_datum.title, latejoin = TRUE) != JOB_AVAILABLE)
				continue
			dept_data += job_datum.title

	if(dept_data.len <= 0) //Congratufuckinglations
		tgui_alert(owner, "There are literally no random jobs available for you on this server, ahelp for assistance.", "Oh No!")
		return

	var/random_job

	while(random_job != JOB_CHOICE_YES)
		if(dept_data.len <= 0)
			tgui_alert(owner, "It seems that there are no more random jobs available for you!", "Oh No!")
			return

		var/random = pick_n_take(dept_data)
		var/list/random_job_options = list(JOB_CHOICE_YES, JOB_CHOICE_REROLL, JOB_CHOICE_CANCEL)

		random_job = tgui_alert(owner, "[random]?", "Random Job", random_job_options)

		if(random_job == JOB_CHOICE_CANCEL)
			return
		if(random_job == JOB_CHOICE_YES)
			return random

#undef JOB_CHOICE_YES
#undef JOB_CHOICE_REROLL
#undef JOB_CHOICE_CANCEL
