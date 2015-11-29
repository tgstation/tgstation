/datum/game_mode/traitor/double_agents
	name = "double agents"
	config_tag = "double_agents"
	restricted_jobs = list("Cyborg", "AI", "Captain", "Head of Personnel", "Chief Medical Officer", "Research Director", "Chief Engineer", "Head of Security", "Mobile MMI") // Human / Minor roles only.
	required_players = 15
	required_enemies = 2 //we only need 2 - the agent, and the other agent
	recommended_enemies = 6

	traitor_name = "double agent"

	var/list/target_list = list()

/datum/game_mode/traitor/double_agents/announce()
	to_chat(world, "<B>The current game mode is - Double Agents!</B>")
	to_chat(world, "<B>There are double agents killing eachother! Do not let them succeed!</B>")

/datum/game_mode/traitor/double_agents/post_setup()
	var/i = 0
	for(var/datum/mind/traitor in traitors)
		i++
		if(i + 1 > traitors.len)
			i = 0
		target_list[traitor] = traitors[i + 1]
	..()

/datum/game_mode/traitor/double_agents/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_traitors = get_players_for_role(ROLE_TRAITOR)

	// stop setup if no possible traitors
	if(!possible_traitors.len)
		log_admin("Failed to set-up a round of double agents. Couldn't find any volunteers to be traitors.")
		message_admins("Failed to set-up a round of double agents. Couldn't find any volunteers to be traitors.")
		return 0

	var/num_traitors = 1

	if(config.traitor_scaling)
		num_traitors = max(required_enemies, round((num_players())/(traitor_scaling_coeff)))
	else
		num_traitors = Clamp(num_players(), required_enemies, traitors_possible)

	for(var/datum/mind/player in possible_traitors)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_traitors -= player

	if(possible_traitors.len < required_enemies) //fixes double agent starting with 1 traitor
		log_admin("Failed to set-up a round of double agents. Couldn't find enough volunteers to be traitors.")
		message_admins("Failed to set-up a round of double agents. Couldn't find enough volunteers to be traitors.")
		return 0

	for(var/j = 0, j < num_traitors, j++)
		if (!possible_traitors.len)
			break
		var/datum/mind/traitor = pick(possible_traitors)
		traitors += traitor
		traitor.special_role = "traitor"
		possible_traitors.Remove(traitor)

	if(!traitors.len)
		log_admin("Failed to set-up a round of double agents. Couldn't find any volunteers to be traitors.")
		message_admins("Failed to set-up a round of double agents. Couldn't find any volunteers to be traitors.")
		return 0
	if(traitors.len < required_enemies)
		log_admin("Failed to set-up a round of double agents. Couldn't find enough volunteers to be traitors.")
		message_admins("Failed to set-up a round of double agents. Couldn't find enough volunteers to be traitors.")
		return 0

	log_admin("Starting a round of double agents with [traitors.len] starting traitors.")
	message_admins("Starting a round of double agents with [traitors.len] starting traitors.")
	return 1

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
	to_chat(traitor.current, "<B><font size=3 color=red>You are the double agent.<br>Relations with the other groups in the Syndicate Coalition have gone south, take the other agents out before they do the same to you.</font></B>")
	var/obj_count = 1
	for(var/datum/objective/objective in traitor.objectives)
		to_chat(traitor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	to_chat(traitor.current, sound('sound/voice/syndicate_intro.ogg'))
	return