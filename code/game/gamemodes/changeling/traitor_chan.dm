/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off

/datum/game_mode/traitor/changeling/announce()
	world << "<B>The current game mode is - Traitor+Changeling!</B>"
	world << "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>"

/datum/game_mode/traitor/changeling/can_start()
	var/count = 0
	for(var/mob/new_player/P in world)
		if(P.client && P.ready && !jobban_isbanned(P, "Syndicate"))
			count++
			if (count==2)
				return 1
	return 0

/datum/game_mode/traitor/changeling/pre_setup()
	var/list/datum/mind/possible_changelings = get_players_for_role(BE_CHANGELING)
	if(possible_changelings.len>0)
		var/changeling = pick(possible_changelings)
		//possible_changelings-=changeling
		changelings += changeling
		must_be_human += changeling
		modePlayer += changelings
		return ..()
	else
		return 0

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
	..()
	return