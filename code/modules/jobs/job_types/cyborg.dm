/datum/job/cyborg
	title = JOB_CYBORG
	description = "Assist the crew, follow your laws, obey your AI."
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 3
	supervisors = "your laws and the AI" //Nodrak
	spawn_type = /mob/living/silicon/robot
	minimal_player_age = 21
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CYBORG"

	display_order = JOB_DISPLAY_ORDER_CYBORG

	departments_list = list(
		/datum/job_department/silicon,
		)
	random_spawns_possible = FALSE
	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_CANNOT_OPEN_SLOTS


/datum/job/cyborg/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!iscyborg(spawned))
		return
	var/mob/living/silicon/robot/robot_spawn = spawned
	robot_spawn.notify_ai(AI_NOTIFICATION_NEW_BORG)
	if(player_client)
		robot_spawn.set_gender(player_client)
	if(!robot_spawn.connected_ai) // Only log if there's no Master AI
		robot_spawn.log_current_laws()

/datum/job/cyborg/get_radio_information()
	return "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>"
