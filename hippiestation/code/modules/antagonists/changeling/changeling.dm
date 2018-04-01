//Kills team objectives by removing the if statement which assigns "forge_team_objectives". This is untested.

/datum/antagonist/changeling/on_gain()
	generate_name()
	create_actions()
	reset_powers()
	create_initial_profile()
	if(give_objectives)
		forge_objectives()
	remove_clownmut()
	. = ..()