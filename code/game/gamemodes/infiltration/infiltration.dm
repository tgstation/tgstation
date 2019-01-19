/datum/game_mode/infiltration
	name = "infiltration"
	config_tag = "infiltration"
	false_report_weight = 10
	required_players = 25
	required_enemies = 3
	recommended_enemies = 5
	antag_flag = ROLE_INFILTRATOR

	announce_span = "danger"
	announce_text = "Syndicate infiltrators are attempting to board the station!\n\
	<span class='danger'>Infiltrators</span>: Board the station stealthfully and complete your objectives!\n\
	<span class='notice'>Crew</span>: Prevent the infiltrators from completing their objectives!"

	var/agents_possible = 5
	var/agents_left = 1
	var/list/pre_sit = list()

	var/datum/team/infiltrator/sit_team

	var/static/list/areas_that_can_finish = typecacheof(list(/area/shuttle/stealthcruiser, /area/infiltrator_base))

/datum/game_mode/infiltration/pre_setup()
	var/n_agents = min(max(CEILING(num_players() / 7, 1), 1), antag_candidates.len, agents_possible)
	if(GLOB.Debug2 || n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/new_sit = pick_n_take(antag_candidates)
			pre_sit += new_sit
			new_sit.assigned_role = "Syndicate Infiltrator"
			new_sit.special_role = "Syndicate Infiltrator"
			log_game("[key_name(new_sit)] has been selected as a syndicate infiltrator")
		return TRUE
	else
		setup_error = "Not enough infiltrator candidates"
		message_admins("Not enough infiltrator candidates! Was making [n_agents], but we need [required_enemies]!")
		return FALSE

/datum/game_mode/infiltration/post_setup()
	sit_team = new /datum/team/infiltrator
	for(var/datum/mind/sit_mind in pre_sit)
		sit_mind.add_antag_datum(/datum/antagonist/infiltrator, sit_team)
	sit_team.update_objectives()
	return ..()

/datum/game_mode/infiltration/generate_report() //make this less shit
	return "Reports show that the Syndicate is rounding up it's elite agents, possibly for a raid on a NanoTrasen-controlled station. Keep an eye out for unusual people."

/datum/game_mode/infiltration/check_finished() //to be called by SSticker
	if(!sit_team || !LAZYLEN(sit_team.objectives) || CONFIG_GET(keyed_list/continuous)["infiltration"])
		return ..()
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if((SSshuttle.emergency.mode == SHUTTLE_ENDGAME) || station_was_nuked)
		return TRUE
	var/objectives_complete = TRUE
	var/all_at_base = TRUE
	for(var/A in sit_team.objectives)
		var/datum/objective/O = A
		if(!O.check_completion())
			objectives_complete = FALSE
	if(objectives_complete)
		for(var/B in sit_team.members)
			var/datum/mind/M = B
			if(M && M.current && M.current.stat && M.current.client)
				var/turf/T = get_turf(M.current)
				var/area/A = get_area(T)
				if(is_centcom_level(T.z) || !is_type_in_typecache(A, areas_that_can_finish))
					all_at_base = FALSE
	return all_at_base && objectives_complete


/datum/game_mode/infiltration/set_round_result()
	..()
	var result = sit_team.get_result()
	switch(result)
		if(INFILTRATION_ALLCOMPLETE)
			SSticker.mode_result = "major win - objectives complete"
		if(INFILTRATION_MOSTCOMPLETE)
			SSticker.mode_result = "semi-major win - most objectives complete"
		if(INFILTRATION_SOMECOMPLETE)
			SSticker.mode_result = "minor win - some objectives complete"
		else
			SSticker.mode_result = "loss - no objectives complete"

/datum/game_mode/infiltration/set_round_result()
	..()
	var result = sit_team.get_result()
	switch(result)
		if(INFILTRATION_ALLCOMPLETE)
			SSticker.mode_result = "major win - objectives complete"
		if(INFILTRATION_MOSTCOMPLETE)
			SSticker.mode_result = "semi-major win - most objectives complete"
		if(INFILTRATION_SOMECOMPLETE)
			SSticker.mode_result = "minor win - some objectives complete"
		else
			SSticker.mode_result = "loss - no objectives complete"
