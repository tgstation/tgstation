/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 20
	required_enemies = 2
	recommended_enemies = 3

	var/const/changeling_amount = 1 //hard limit on changelings if scaling is turned off
	var/const/changeling_scaling_coeff = 25 //how much does the amount of players get divided by to determine changelings

/datum/game_mode/traitor/changeling/announce()
	world << "<B>The current game mode is - Traitor+Changeling!</B>"
	world << "<B>There are alien creatures on the station along with some syndicate operatives out for their own gain! Do not let the changelings or the traitors succeed!</B>"


/datum/game_mode/traitor/changeling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(BE_CHANGELING)

	var/num_changelings = 1

	if(config.traitor_scaling)
		num_changelings = max(1, round((num_players())/(changeling_scaling_coeff)))
	else
		num_changelings = max(1, min(num_players(), changeling_amount))

	for(var/datum/mind/player in possible_changelings)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player

	if(possible_changelings.len>0)
		for(var/j = 0, j < num_changelings, j++)
			if(!possible_changelings.len) break
			var/datum/mind/changeling = pick(possible_changelings)
			possible_changelings -= changeling
			changelings += changeling
			modePlayer += changelings
		return ..()
	else
		return 0

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		changeling.current.make_changeling(changeling.current)
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
	..()
	return

/datum/game_mode/traitor/changeling/make_antag_chance(var/mob/living/carbon/human/character) //Assigns changeling to latejoiners
	if(changelings.len >= round(joined_player_list.len / changeling_scaling_coeff) + 1) //Caps number of latejoin antagonists
		return
	if (prob(100/changeling_scaling_coeff))
		if(character.client.prefs.be_special & BE_CHANGELING)
			if(!jobban_isbanned(character.client, "changeling") && !jobban_isbanned(character.client, "Syndicate"))
				if(!(character.job in ticker.mode.restricted_jobs))
					character.mind.make_Changling()
	..()