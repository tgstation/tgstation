/*The threat datum will handle the spawn of antagonists, based on probabilities and weights
*/
/datum/threat
	var/list/datum/antag_holder/possible_antags = list()
	var/list/antagonists = list()

	var/list/datum/team/teams = list()

	var/antag_score_left = ANTAG_SCORE_INITIAL

/datum/threat/New()
	. = ..()
	possible_antags = sortTim(generate_antag_holder_list(), /proc/cmp_antag_weight)

//Pre setup will handle the round start antagonist selection
/datum/threat/proc/pre_setup()
	for(var/type in possible_antags)
		var/datum/antag_holder/A = type
		if((ticker.totalPlayersReady < A.min_players) || (A.max_players && (ticker.totalPlayersReady > A.max_players)))
			continue
		if(prob(A.probability) && (antag_score_left >= A.weight))
			A.possible_candidates = get_players_for_role(player_list, A.name, mob_type_check = /mob/new_player)
			world << "[A.name]"
			world << "[LAZYLEN(A.possible_candidates)]"
			if(!LAZYLEN(A.possible_candidates))
				continue
			antag_score_left -= A.weight
			var/max_antags = min(A.max_antags, max(A.min_antags, round(ticker.totalPlayersReady / (A.scaling_coeff * 2))))
			for(var/i in 1 to max_antags)
				if(!LAZYLEN(A.possible_candidates))
					break
				var/datum/mind/M = pick_n_take(A.possible_candidates)
				M.add_antag_datum(A.path_to_antag_datum, on_gain = FALSE)

//Handles giving special equipment/application of antag huds to the round antags
/datum/threat/proc/post_setup()
	for(var/antag in antagonists)
		var/list/minds = antagonists[antag]
		for(var/m in minds)
			var/datum/mind/mind = m
			for(var/ad in mind.antag_datums)
				var/datum/antagonist/A = ad
				A.on_gain()
				if(A.owner && A.owner.current && A.landmark_spawn)
					move_to_landmark(A.owner.current, A.landmark_spawn)

/datum/threat/proc/move_to_landmark(mob/A, landmark)
	if(!A)
		return
	if(!landmark)
		return
	for(var/i in landmarks_list)
		var/obj/effect/landmark/L = i
		world << "L: [L.name]"
		if(L.name == landmark)
			world << "[L.name] == [landmark]"
			A.forceMove(get_turf(L))

//Returns a list of possible candidates for a certain role
/datum/threat/proc/get_players_for_role(list/mob/players, role, z_level_check = ZLEVEL_STATION, mob_type_check = /mob/living/carbon/human)
	. = list()
	for(var/p in players)
		var/mob/M = p
		world << M.name
		world << "[M.type]"
		world << "type_c: [mob_type_check]"
		if(!istype(M, mob_type_check))
			world << "!istype"
			continue
		if(!M.client || !M.mind)
			world << "Continue !mind !client"
			continue
		//var/turf/T = get_turf(M)
		//if(z_level_check && (T.z != z_level_check))
		//	continue
		if(jobban_isbanned(M, role) || jobban_isbanned(M, "Syndicate"))
			continue
		if(role in M.client.prefs.be_special)
			. |= M.mind

/datum/threat/proc/generate_antag_holder_list()
	. = list()
	var/list/antags = file2list(file(ANTAG_PROBABILITIES_FILE))
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

		switch(command)
			if("antag")
				antag = new
				antag.name = data
			if("path")
				antag.path_to_antag_datum = text2path("[ANTAG_DATUM_PATH]/[data]")
				if(!ispath(antag.path_to_antag_datum))
					qdel(antag)
					continue
			if("minplayers")
				antag.min_players = text2num(data)
			if("maxplayers")
				antag.max_players = text2num(data)
			if("weight")
				antag.weight = text2num(data)
			if("probability")
				antag.probability = text2num(data)
			if("minantags")
				antag.min_antags = text2num(data)
			if("maxantags")
				antag.max_antags = text2num(data)
			if("scalingcoeff")
				antag.scaling_coeff = text2num(data)

		. |= antag

/datum/antag_holder
	var/name
	var/path_to_antag_datum
	var/min_players = 1
	var/max_players = 0
	var/weight = 20
	var/probability = 15
	var/min_antags = 1
	var/max_antags = 0
	var/scaling_coeff = 1
	var/list/datum/mind/possible_candidates = list()

/datum/team
	var/name
	var/list/members

	var/list/team_objectives = list()

/datum/team/proc/add_member(datum/mind/M)
	if(!M)
		return
	members += M

/datum/team/proc/give_team_objectives(datum/mind/M)

/datum/team/proc/generate_team_objectives(list/possible_objectives, quantity = 1, can_objective_repeat = FALSE, antag_datum_type)
	if(!islist(possible_objectives))
		possible_objectives = list(possible_objectives)

	for(var/i in quantity)
		var/type = can_objective_repeat ? pick(possible_objectives) : pick_n_take(possible_objectives)
		for(var/m in members)
			var/datum/mind/M = m
			var/datum/antagonist/A = M.has_antag_datum(antag_datum_type)
			if(A)
				var/datum/objective/O = new type
				O.owner = M
				A.current_objectives += O
				team_objectives += O


/proc/cmp_antag_weight(datum/antag_holder/A, datum/antag_holder/B)
	return B.weight - A.weight