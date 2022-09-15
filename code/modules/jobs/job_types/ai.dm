/datum/job/ai
	title = JOB_AI
	description = "Assist the crew, follow your laws, coordinate your cyborgs."
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "your laws"
	selection_color = "#ccffcc"
	spawn_type = /mob/living/silicon/ai
	req_admin_notify = TRUE
	minimal_player_age = 30
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SILICON
	exp_granted_type = EXP_TYPE_CREW
	display_order = JOB_DISPLAY_ORDER_AI
	allow_bureaucratic_error = FALSE
	departments_list = list(
		/datum/job_department/silicon,
		)
	random_spawns_possible = FALSE
	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_BOLD_SELECT_TEXT
	var/do_special_check = TRUE


/datum/job/ai/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	//we may have been created after our borg
	if(SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
			if(!R.connected_ai)
				R.TryConnectToAI()
	var/mob/living/silicon/ai/ai_spawn = spawned
	ai_spawn.log_current_laws()


/datum/job/ai/get_roundstart_spawn_point()
	return get_latejoin_spawn_point()


/datum/job/ai/get_latejoin_spawn_point()
	var/list/primary_spawn_points = list() // Ideal locations.
	var/list/secondary_spawn_points = list() // Fallback locations.
	for(var/obj/effect/landmark/start/ai/spawn_point in GLOB.landmarks_list)
		if(spawn_point.used)
			secondary_spawn_points += list(spawn_point)
			continue
		if(spawn_point.primary_ai)
			primary_spawn_points = list(spawn_point)
			break // Bingo.
		primary_spawn_points += spawn_point
	var/obj/effect/landmark/start/ai/chosen_spawn_point
	if(length(primary_spawn_points))
		chosen_spawn_point = pick(primary_spawn_points)
	else if(length(secondary_spawn_points))
		chosen_spawn_point = pick(secondary_spawn_points)
	else
		CRASH("Failed to find any AI spawn points.")
	chosen_spawn_point.used = TRUE
	return chosen_spawn_point


/datum/job/ai/get_latejoin_spawn_point()
	for(var/obj/structure/ai_core/latejoin_inactive/inactive_core as anything in GLOB.latejoin_ai_cores)
		if(!inactive_core.is_available())
			continue
		GLOB.latejoin_ai_cores -= inactive_core
		inactive_core.available = FALSE
		. = inactive_core.loc
		qdel(inactive_core)
		return
	return ..()


/datum/job/ai/special_check_latejoin(client/C)
	if(!do_special_check)
		return TRUE
	for(var/i in GLOB.latejoin_ai_cores)
		var/obj/structure/ai_core/latejoin_inactive/LAI = i
		if(istype(LAI))
			if(LAI.is_available())
				return TRUE
	return FALSE


/datum/job/ai/announce_job(mob/living/joining_mob)
	. = ..()
	if(SSticker.HasRoundStarted())
		minor_announce("[joining_mob] has been downloaded to an empty bluespace-networked AI core at [AREACOORD(joining_mob)].")


/datum/job/ai/config_check()
	return CONFIG_GET(flag/allow_ai)

/datum/job/ai/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :b to speak with cyborgs and other AIs.</b>")
