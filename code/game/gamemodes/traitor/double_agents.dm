/datum/game_mode/traitor/double_agents
	name = "double agents"
	config_tag = "double_agents"
	required_players = 25
	required_enemies = 5
	recommended_enemies = 8
	reroll_friendly = 0

	traitors_possible = 10 //hard limit on traitors if scaling is turned off
	num_modifier = 6 // Six additional traitors

	var/list/target_list = list()
	var/list/late_joining_list = list()

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

/datum/game_mode/traitor/double_agents/forge_traitor_objectives(datum/mind/traitor)

	if(target_list.len && target_list[traitor]) // Is a double agent

		// Assassinate
		var/datum/mind/target_mind = target_list[traitor]
		if(issilicon(target_mind.current))
			var/datum/objective/default/destroy/destroy_objective = add_objective(traitor, /datum/objective/default/destroy)
			destroy_objective.target = target_mind
			destroy_objective.update_explanation_text()
		else
			var/datum/objective/default/assassinate/kill_objective = add_objective(traitor, /datum/objective/default/assassinate)
			kill_objective.target = target_mind
			kill_objective.update_explanation_text()

		// Escape
		if(issilicon(traitor.current))
			add_objective(traitor, /datum/objective/escape_obj/survive)
		else
			add_objective(traitor, /datum/objective/escape_obj/escape)

	else
		..() // Give them standard objectives.
	return

/datum/game_mode/traitor/double_agents/add_latejoin_traitor(datum/mind/character)

	check_potential_agents()

	// As soon as we get 3 or 4 extra latejoin traitors, make them traitors and kill each other.
	if(late_joining_list.len >= rand(3, 4))
		// True randomness
		shuffle(late_joining_list)
		// Reset the target_list, it'll be used again in force_traitor_objectives
		target_list = list()

		// Basically setting the target_list for who is killing who
		var/i = 0
		for(var/datum/mind/traitor in late_joining_list)
			i++
			if(i + 1 > late_joining_list.len)
				i = 0
			target_list[traitor] = late_joining_list[i + 1]
			traitor.special_role = traitor_name

		// Now, give them their targets
		for(var/datum/mind/traitor in target_list)
			..(traitor)

		late_joining_list = list()
	else
		late_joining_list += character
	return

/datum/game_mode/traitor/double_agents/proc/check_potential_agents()

	for(var/M in late_joining_list)
		if(istype(M, /datum/mind))
			var/datum/mind/agent_mind = M
			if(ishuman(agent_mind.current))
				var/mob/living/carbon/human/H = agent_mind.current
				if(H.stat != DEAD)
					if(H.client)
						continue // It all checks out.

		// If any check fails, remove them from our list
		late_joining_list -= M