/*The threat datum will handle the spawn of antagonists, based on probabilities and weights
*/
/datum/threat
	var/list/datum/antag_holder/possible_antags = list()
	var/list/antagonists = list()
	var/list/datum/team/teams = list()

	var/list/drafted_candidates = list()

	var/antag_score_left = ANTAG_SCORE_INITIAL

/datum/threat/New()
	. = ..()
	possible_antags = sortTim(generate_antag_list(), /proc/cmp_antag_weight, TRUE)

//Pre setup will handle the round start antagonist selection
/datum/threat/proc/pre_setup()
	for(var/type in possible_antags)
		var/datum/antag_holder/A = possible_antags[type]
		if((ticker.totalPlayersReady < A.min_players) || (A.max_players && (ticker.totalPlayersReady > A.max_players)))
			continue
		if(prob(A.probability) && (antag_score_left > A.weight))
			A.possible_candidates = get_players_for_role(A.name)
			if(!LAZYLEN(A.possible_candidates))
				continue
			antag_score_left -= A.weight
			var/max_antags = min(A.max_antags, max(A.min_players, round(ticker.totalPlayersReady / (A.scaling_coeff * 2))))
			for(var/i = 0 in max_antags)
				var/datum/mind/M = pick_n_take(A.possible_candidates)
				M.add_antag_datum(type, on_gain = FALSE)

//Handles giving special equipment/application of antag huds to the round antags
/datum/threat/proc/post_setup()
	for(var/antag in antagonists)
		var/list/minds = antagonists[antag]
		for(var/m in minds)
			var/datum/mind/mind = m
			for(var/ad in mind.antag_datums)
				var/datum/antagonist/A = ad
				A.on_gain()

//This generates the list of possible candidates based on the antag role. Returns a list of minds that can be the antag.
/datum/threat/proc/get_players_for_role(role)
	. = list()
	for(var/p in player_list)
		var/mob/new_player/player = p
		if(!player.client || !player.mind)
			continue
		if(role in player.client.prefs.be_special)
			if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, role) && age_check(player.client))
				. += player.mind

/datum/threat/proc/generate_antag_list()
	. = list()
	var/list/antags = file2list(ANTAG_PROBABILITIES_FILE)
	var/datum/antag_holder/antag = null
	for(var/a in antags)
		if(!a)
			continue

		a = trim(a)
		if((length(a) == 0) || (copytext(a, 1, 2) == "#"))
			continue

		var/pos = findtext(a, " ")
		var/command = null
		var/data = null

		if(pos)
			command = lowertext(copytext(a, 1, pos))
			data = copytext(a, pos + 1)
		else
			command = lowertext(a)

		if(!command)
			continue
		if(!antag && command != "antag")
			continue

		var/path = null
		switch(command)
			if("antag")
				antag = new
			if("path")
				path = text2path(ANTAG_DATUM_PATH + data)
			if("minplayers")
				antag.min_players = text2num(data)
			if("maxplayers")
				antag.max_players = text2num(data)
			if("antagweight")
				antag.weight = text2num(data)
			if("probability")
				antag.probability = text2num(data)
			if("minantags")
				antag.min_antags = text2num(data)
			if("maxantags")
				antag.max_antags = text2num(data)
			if("scalingcoeff")
				antag.scaling_coeff = text2num(data)

		.[path] += antag

/datum/threat/proc/select_antag_player()
	//for(var/i in

/datum/antag_holder
	var/name
	var/min_players = 0
	var/max_players = 0
	var/weight = 20
	var/probability = 15
	var/min_antags = 1
	var/max_antags = 0
	var/list/datum/mind/possible_candidates = list()

/datum/team
	var/name
	var/list/members

/proc/cmp_antag_weight(datum/antag_holder/A, datum/antag_holder/B)
	return A.weight - B.weight