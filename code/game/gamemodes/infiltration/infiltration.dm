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

	var/datum/team/infiltration/sit_team

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

/datum/game_mode/infiltration/generate_report()
	return "Reports show that the Syndicate is rounding up it's elite agents, possibly for a raid on a NanoTrasen-controlled station. Keep an eye out for unusual people."