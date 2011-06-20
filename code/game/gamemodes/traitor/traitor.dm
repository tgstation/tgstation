/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/laser = 1
	var/const/hand_tele = 2
	var/const/plasma_bomb = 3
	var/const/jetpack = 4
	var/const/captain_card = 5
	var/const/captain_suit = 6

	var/const/destroy_plasma = 1
	var/const/destroy_ai = 2
	var/const/kill_monkeys = 3
	var/const/cut_power = 4

	var/const/percentage_plasma_destroy = 70 // what percentage of the plasma tanks you gotta destroy
	var/const/percentage_station_cut_power = 80 // what percentage of the tiles have to have power cut
	var/const/percentage_station_evacuate = 80 // what percentage of people gotta leave - you also gotta change the objective in the traitor menu

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/const/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 5.0 //how much does the amount of players get divided by to determine traitors

/datum/game_mode/traitor/announce()
	world << "<B>The current game mode is - Traitor!</B>"
	world << "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!!</B>"

/datum/game_mode/traitor/pre_setup()
	var/list/possible_traitors = get_possible_traitors()

	var/num_players = 0
	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			num_players++

	var/num_traitors = 1

	// stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	if(config.traitor_scaling)
		num_traitors = max(1, round((num_players)/(traitor_scaling_coeff)))
	else
		num_traitors = max(1, min(num_players, traitors_possible))

//	log_game("Number of traitors: [num_traitors]")
//	message_admins("Players counted: [num_players]  Number of traitors chosen: [num_traitors]")

	for(var/j = 0, j < num_traitors, j++)
		if (!possible_traitors.len)
			break
		var/datum/mind/traitor = pick(possible_traitors)
		traitors += traitor
		possible_traitors.Remove(traitor)

	for(var/datum/mind/traitor in traitors)
		if(!traitor || !istype(traitor))
			traitors.Remove(traitor)
			continue
		if(istype(traitor))
			traitor.special_role = "traitor"

	if(!traitors.len)
		return 0
	return 1

/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		if(istype(traitor.current, /mob/living/silicon))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = traitor
			kill_objective.find_target()
			traitor.objectives += kill_objective

			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = traitor
			traitor.objectives += survive_objective

		else
			switch(rand(1,100))
				if(1 to 50)
					var/datum/objective/assassinate/kill_objective = new
					kill_objective.owner = traitor
					kill_objective.find_target()
					traitor.objectives += kill_objective
				else
					var/datum/objective/steal/steal_objective = new
					steal_objective.owner = traitor
					steal_objective.find_target()
					traitor.objectives += steal_objective
			switch(rand(1,100))
				if(1 to 90)
					var/datum/objective/escape/escape_objective = new
					escape_objective.owner = traitor
					traitor.objectives += escape_objective

				else
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = traitor
					traitor.objectives += hijack_objective



		spawn(rand(10,100))
			traitor.current << "<B>You are the traitor.</B>"

			var/obj_count = 1
			for(var/datum/objective/objective in traitor.objectives)
				traitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++
			if (istype(traitor.current, /mob/living/silicon))
				add_law_zero(traitor.current)
			else
				equip_traitor(traitor.current)

	modePlayer = traitors
	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/traitor/proc/get_possible_traitors()
	var/list/candidates = list()
	for(var/mob/new_player/player in world)
		if (player.client && player.ready)
			if(player.preferences.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				candidates += player.mind

	return candidates

/datum/game_mode/traitor/declare_completion()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.

/datum/game_mode/traitor/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	killer << "<b>Your laws have been changed!</b>"
	killer:set_zeroth_law(law)
	killer << "New law: 0. [law]"

	//Begin code phrase.
	killer << "The Syndicate provided you with the following information on how to identify their agents:"
	if(prob(80))
		killer << "\red Code Phrase: \black [syndicate_code_phrase]"
		killer.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	else
		killer << "Unfortunetly, the Syndicate did not provide you with a code phrase."
	if(prob(80))
		killer << "\red Code Response: \black [syndicate_code_response]"
		killer.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
	else
		killer << "Unfortunetly, the Syndicate did not provide you with a code response."
	killer << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
	//End code phrase.

/datum/game_mode/traitor/proc/get_mob_list()
	var/list/mobs = list()
	for(var/mob/living/player in world)
		if (player.client)
			mobs += player
	return mobs

/datum/game_mode/traitor/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/mob/living/player in world)
		if (player.client && (player.real_name != excluded_name))
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)