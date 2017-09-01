/datum/brother_pair
	var/datum/mind/brother1
	var/datum/mind/brother2

/datum/game_mode
	var/list/datum/mind/brothers = list()

/datum/game_mode/traitor/bros
	name = "traitor+brothers"
	config_tag = "traitorbro"
	antag_flag = ROLE_BROTHER
	restricted_jobs = list("AI", "Cyborg")
	required_players = 0
	required_enemies = 2 // It's just called two brothers.
	recommended_enemies = 4
	reroll_friendly = TRUE
	enemy_minimum_age = 7

	var/list/datum/mind/pre_brothers = list()
	var/const/pair_amount = 1 //hard limit on brother pairs if scaling is turned off

/datum/game_mode/traitor/bros/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Brothers!</B>")
	to_chat(world, "<B>There are blood brothers on the station along with some syndicate operatives out for their own gain! Do not let the blood brothers or the traitors succeed!</B>")

/datum/game_mode/traitor/bros/can_start()
	if(!..())
		return FALSE
	var/list/datum/mind/possible_bros = get_players_for_role(ROLE_BROTHER)
	return possible_bros.len >= required_enemies

/datum/game_mode/traitor/bros/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_bros = get_players_for_role(ROLE_BROTHER)

	var/num_pairs = 1

	if(config.brother_scaling_coeff)
		num_pairs = max(1, min( round(num_players()/(config.brother_scaling_coeff*4))+2, round(num_players()/(config.brother_scaling_coeff*2)) ))
	else
		num_pairs = max(1, min(num_players(), pair_amount/2))

	for(var/j = 0, j < num_pairs, j++)
		if(possible_bros.len < 2) 
			return FALSE

		var/datum/mind/bro1 = pick(possible_bros)
		antag_candidates -= bro1
		possible_bros -= bro1
		bro1.special_role = "Brother"
		bro1.restricted_roles = restricted_jobs
		pre_brothers += bro1

		var/datum/mind/bro2 = pick(possible_bros)
		antag_candidates -= bro2
		possible_bros -= bro2
		bro2.special_role = "Brother"
		bro2.restricted_roles = restricted_jobs
		pre_brothers += bro2

		log_game("[traitor.key] (ckey) has been selected as a [traitor_name]")

	return ..()

/datum/game_mode/traitor/bros/post_setup()
	modePlayer += brothers
	for(var/datum/brother_pair/P in brother_pairs)
		P.brother1.add_antag_datum(antag_datum)
		P.brother2.add_antag_datum(antag_datum)

		forge_brother_objectives(P.brother1, P.brother2)
		greet_brother(brother)
	..()


add_objective_to_brothers(objective_type, brother1, brother2)
	var/datum/objective/objective1 = new objective_type
	objective1.owner = brother1
	objective1.conspirators = list(brother2)
	objective1.find_target()

	var/datum/objective/objective2 = new objective_type
	objective1.owner = brother2
	objective1.conspirators = list(brother1)
	objective2.match_target(objective_1)

/datum/antagonist/brother/forge_single_objective() //Returns how many objectives are added
	. = 1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			add_objective_to_brothers(datum/objective/destroy, brother1, brother2)
		else if(prob(30))
			add_objective_to_brothers(datum/objective/maroon, brother1, brother2)
		else
			add_objective_to_brothers(datum/objective/assassinate, brother1, brother2)
	else
		add_objective_to_brothers(datum/objective/steal, brother1, brother2)

