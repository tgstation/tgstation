/datum/game_mode/infiltration
	name = "infiltration"
	config_tag = "infiltration"
	false_report_weight = 10
	required_players = 35
	required_enemies = 3
	recommended_enemies = 5
	antag_flag = ROLE_INFILTRATOR

	announce_span = "danger"
	announce_text = "Syndicate infiltrators are attempting to board the station!\n\
	<span class='danger'>Infiltrators</span>: Board the station stealthfully and complete your objectives!\n\
	<span class='notice'>Crew</span>: Prevent the infiltrators from completing their objectives!"

	var/const/agents_possible = 5 //If we ever need more syndicate agents.
	var/agents_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/list/pre_sit = list()

	var/datum/team/infiltrator/sit_team

	var/static/list/areas_that_can_finish = typecacheof(list(/area/shuttle/stealthcruiser, /area/infiltrator_base))

/datum/game_mode/infiltration/pre_setup()
	var/n_agents = min(round(num_players() / 10), antag_candidates.len, agents_possible)
	for(var/i = 0, i < n_agents, ++i)
		var/datum/mind/new_sit = pick_n_take(antag_candidates)
		pre_sit += new_sit
		new_sit.assigned_role = "Syndicate Infiltrator"
		new_sit.special_role = "Syndicate Infiltrator"
		log_game("[new_sit.key] (ckey) has been selected as a syndicate infiltrator")
	return TRUE

/datum/game_mode/infiltration/post_setup()
	for(var/datum/mind/sit_mind in pre_sit)
		sit_mind.add_antag_datum(/datum/antagonist/infiltrator)
	return ..()

/datum/game_mode/infiltration/generate_report() //make this less shit
	return "Reports show that the Syndicate is rounding up it's elite agents, possibly for a raid on a NanoTrasen-controlled station. Keep an eye out for unusual people."

/datum/game_mode/infiltration/check_finished() //to be called by SSticker
	if(!sit_team || !LAZYLEN(sit_team.objectives) || CONFIG_GET(keyed_flag_list/continuous)["infiltration"])
		return ..()
	var/objectives_complete = TRUE
	var/all_at_base = TRUE
	for(var/A in sit_team.objectives)
		var/datum/objective/O = A
		if(!O.check_completion())
			objectives_complete = FALSE
	if(objectives_complete)
		for(var/B in sit_team.members)
			var/datum/mind/M = B
			if(M && M.current && !considered_afk(M) && considered_alive(M))
				var/turf/T = get_turf(M.current)
				var/area/A = get_area(T)
				if(!is_centcom_level(T.z) || !is_type_in_typecache(A, areas_that_can_finish))
					all_at_base = FALSE
	return all_at_base && objectives_complete