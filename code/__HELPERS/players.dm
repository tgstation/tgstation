#define CHECK_PLAYER(player) if(!player.client || !player.ready || !player.client.prefs) continue
#define CHECK_BANS(player, role) if(jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, role)) continue

/proc/number_ready()
	var/list/L = get_ready_players()
	. = L.len

/proc/get_ready_players()
	. = list()
	for(var/mob/new_player/P in player_list)
		if(P.client && P.ready)
			. += P

/proc/age_check(client/C, days=0)
	if(!C)
		return TRUE
	if(!config.use_age_restriction_for_jobs)
		return TRUE
	// No db connection results in C.player_age = "Requires database"
	if(!isnum(C.player_age))
		return TRUE
	if(!isnum(days))
		return TRUE
	if(C.player_age >= days)
		return TRUE

	return FALSE

/proc/get_player_minds_for_role(role, minimum_age=0)
	var/list/players = shuffle(get_ready_players())
	var/list/candidates = list()

	for(var/i in players)
		var/mob/new_player/player = i
		CHECK_PLAYER(player)
		CHECK_BANS(player, role)
		if(!age_check(player.client, minimum_age))
			continue

		if(role in player.client.prefs.be_special)
			if(player.mind)
				candidates += player.mind

	return candidates

#undef CHECK_PLAYER
#undef CHECK_BANS
