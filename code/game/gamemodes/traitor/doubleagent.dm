/datum/game_mode/traitor/double_agents
	name = "double agents"
	config_tag = "double_agents"
	restricted_jobs = list("Cyborg", "AI", "Captain", "Head of Personnel", "Chief Medical Officer", "Research Director", "Chief Engineer", "Head of Security", "Mobile MMI") // Human / Minor roles only.
	required_players = 25
	required_enemies = 3
	recommended_enemies = 6

	traitor_name = "double agent"

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

	if(target_list.len > 1)
		// Assassinate
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.target = target_list[traitor]
		if(kill_objective.target)
			kill_objective.explanation_text = "Assassinate [kill_objective.target.current.real_name], the [kill_objective.target.special_role]."
		else //Something went wrong, so give them a random assasinate objective
			kill_objective.find_target()
		traitor.objectives += kill_objective


	// Escape
	if(prob(25))
		var/datum/objective/die/die_objective = new
		die_objective.owner = traitor
		traitor.objectives += die_objective
	else
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = traitor
		traitor.objectives += escape_objective
	return

/datum/game_mode/traitor/double_agents/greet_traitor(var/datum/mind/traitor)
	traitor.current << "<B><font size=3 color=red>You are the double agent.<br>Relations with the other groups in the Syndicate Coalition have gone south, take the other agents out before they do the same to you.</font></B>"
	var/obj_count = 1
	for(var/datum/objective/objective in traitor.objectives)
		traitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return