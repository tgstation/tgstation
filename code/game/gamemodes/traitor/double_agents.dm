/datum/game_mode/traitor/double_agents
	name = "double agents"
	config_tag = "double_agents"
	restricted_jobs = list("Cyborg", "AI", "Captain", "Head of Personnel", "Chief Medical Officer", "Research Director", "Chief Engineer", "Head of Security") // Human / Minor roles only.
	required_players = 25
	required_enemies = 5
	recommended_enemies = 8

	traitor_name = "double agent"

	traitors_possible = 8 //hard limit on traitors if scaling is turned off

	var/list/target_list = list()

/datum/game_mode/traitor/double_agents/announce()
	world << "<B>The current game mode is - Double Agents!</B>"
	world << "<B>There are double agents killing eachother! Do not let them succeed!</B>"

/datum/game_mode/traitor/double_agents/post_setup()
	var/i = 0
	for(var/datum/mind/traitor in traitors)
		i++
		if(i + 1 > traitors.len)
			i = 0
		target_list[traitor] = traitors[i + 1]
	..()

/datum/game_mode/traitor/double_agents/forge_traitor_objectives(var/datum/mind/traitor)

	if(target_list.len && target_list[traitor]) // Is a double agent

		// Assassinate
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.target = target_list[traitor]
		kill_objective.explanation_text = "Assassinate [kill_objective.target.current.real_name], the [kill_objective.target.special_role]."
		traitor.objectives += kill_objective

		// Escape
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = traitor
		traitor.objectives += escape_objective

	else
		..() // Give them standard objectives.
	return

/datum/game_mode/traitor/double_agents/make_antag_chance(var/mob/living/carbon/human/character)
	return // TODO: Have late joining double agents.