/// The time since the last job opening was created
GLOBAL_VAR_INIT(time_last_changed_position, 0)

/datum/computer_file/program/job_management
	filename = "plexagoncore"
	filedesc = "Plexagon HR Core"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program for viewing and changing job slot avalibility."
	transfer_access = ACCESS_HEADS
	requires_ntnet = TRUE
	size = 4
	tgui_id = "NtosJobManager"
	program_icon = "address-book"

	var/change_position_cooldown = 30
	//Jobs you cannot open new positions for
	var/list/blacklisted = list(
		"AI",
		"Assistant",
		"Cyborg",
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Chief Engineer",
		"Research Director",
		"Chief Medical Officer")

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list()

/datum/computer_file/program/job_management/New()
	..()
	change_position_cooldown = CONFIG_GET(number/id_console_jobslot_delay)

/datum/computer_file/program/job_management/proc/can_open_job(datum/job/job)
	if(!(job?.title in blacklisted))
		if((job.total_positions <= length(GLOB.player_list) * (max_relative_positions / 100)))
			var/delta = (world.time / 10) - GLOB.time_last_changed_position
			if((change_position_cooldown < delta) || (opened_positions[job.title] < 0))
				return TRUE
	return FALSE

/datum/computer_file/program/job_management/proc/can_close_job(datum/job/job)
	if(!(job?.title in blacklisted))
		if(job.total_positions > length(GLOB.player_list) * (max_relative_positions / 100))
			var/delta = (world.time / 10) - GLOB.time_last_changed_position
			if((change_position_cooldown < delta) || (opened_positions[job.title] > 0))
				return TRUE
	return FALSE

/datum/computer_file/program/job_management/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/user_id = card_slot?.stored_card

	if(!user_id || !(ACCESS_CHANGE_IDS in user_id.access))
		return

	switch(action)
		if("PRG_open_job")
			var/edit_job_target = params["target"]
			var/datum/job/j = SSjob.GetJob(edit_job_target)
			if(!j || !can_open_job(j))
				return
			if(opened_positions[edit_job_target] >= 0)
				GLOB.time_last_changed_position = world.time / 10
			j.total_positions++
			opened_positions[edit_job_target]++
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_close_job")
			var/edit_job_target = params["target"]
			var/datum/job/j = SSjob.GetJob(edit_job_target)
			if(!j || !can_close_job(j))
				return
			//Allow instant closing without cooldown if a position has been opened before
			if(opened_positions[edit_job_target] <= 0)
				GLOB.time_last_changed_position = world.time / 10
			j.total_positions--
			opened_positions[edit_job_target]--
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_priority")
			if(length(SSjob.prioritized_jobs) >= 5)
				return
			var/priority_target = params["target"]
			var/datum/job/j = SSjob.GetJob(priority_target)
			if(!j)
				return
			if(j.total_positions <= j.current_positions)
				return
			if(j in SSjob.prioritized_jobs)
				SSjob.prioritized_jobs -= j
			else
				SSjob.prioritized_jobs += j
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE


/datum/computer_file/program/job_management/ui_data(mob/user)
	var/list/data = get_header_data()

	var/authed = FALSE
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/user_id = card_slot?.stored_card
	if(user_id && (ACCESS_CHANGE_IDS in user_id.access))
		authed = TRUE

	data["authed"] = authed

	var/list/pos = list()
	for(var/j in SSjob.occupations)
		var/datum/job/job = j
		if(job.title in blacklisted)
			continue

		pos += list(list(
			"title" = job.title,
			"current" = job.current_positions,
			"total" = job.total_positions,
			"status_open" = authed ? can_open_job(job) : FALSE,
			"status_close" = authed ? can_close_job(job) : FALSE,
		))
	data["slots"] = pos
	var/delta = round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1)
	data["cooldown"] = delta < 0 ? 0 : delta
	var/list/priority = list()
	for(var/j in SSjob.prioritized_jobs)
		var/datum/job/job = j
		priority += job.title
	data["prioritized"] = priority
	return data

