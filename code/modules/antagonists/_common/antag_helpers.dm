//Returns MINDS of the assigned antags of given type/subtypes
/proc/get_antag_minds(antag_type,specific = FALSE)
	RETURN_TYPE(/list/datum/mind)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type)
			. += A.owner

/// From a list of players (minds, mobs or clients), finds the one with the highest playtime (either from a specific role or overall living) and returns it.
/proc/get_most_experienced(list/players, specific_role)
	if(!CONFIG_GET(flag/use_exp_tracking)) //woops
		return
	var/most_experienced
	for(var/player in players)
		if(!most_experienced)
			most_experienced = player
			continue
		var/client/player_client = get_player_client(player)
		if(!player_client?.prefs || !length(player_client.prefs.exp))
			continue
		var/client/most_played = get_player_client(most_experienced)
		if(!most_played?.prefs || !length(most_played.prefs.exp))
			most_experienced = player
			continue
		var/player_playtime
		var/most_playtime
		if(specific_role)
			player_playtime = player_client.prefs.exp[specific_role] ? text2num(player_client.prefs.exp[specific_role]) : 0
			most_playtime = most_played.prefs.exp[specific_role] ? text2num(most_played.prefs.exp[specific_role]) : 0
		else
			player_playtime = player_client.get_exp_living(TRUE)
			most_playtime = most_played.get_exp_living(TRUE)
		if(player_playtime > most_playtime)
			most_experienced = player
	return most_experienced
