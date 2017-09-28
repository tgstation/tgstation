/datum/game_mode/nuclear/pre_setup()
	var/n_players = num_players()
	var/n_agents = min(round(n_players * 0.14), agents_possible) //One nukie per 7 players, that means at around 30 plyers we should see 3-4 nukies.

	if(antag_candidates.len < n_agents) //In the case of having less candidates than the selected number of agents
		n_agents = antag_candidates.len

	while(n_agents > 0)
		var/datum/mind/new_syndicate = pick(antag_candidates)
		syndicates += new_syndicate
		antag_candidates -= new_syndicate //So it doesn't pick the same guy each time.
		n_agents--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "Syndicate"
		synd_mind.special_role = "Syndicate"//So they actually have a special role/N
		log_game("[synd_mind.key] (ckey) has been selected as a nuclear operative")

	return 1