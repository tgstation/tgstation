/datum/vote/map_vote
	name = "Map"
	default_message = "Vote for next round's map!"
	count_method = VOTE_COUNT_METHOD_SINGLE
	winner_method = VOTE_WINNER_METHOD_WEIGHTED_RANDOM
	display_statistics = FALSE

/datum/vote/map_vote/New()
	. = ..()

	default_choices = list()

	// Fill in our default choices with all of the maps in our map config, if they are votable and not blocked.
	var/list/maps = shuffle(global.config.maplist)
	for(var/map in maps)
		var/datum/map_config/possible_config = config.maplist[map]
		if(!possible_config.votable || (possible_config.map_name in SSpersistence.blocked_maps))
			continue

		default_choices += possible_config.map_name

/datum/vote/map_vote/create_vote()
	. = ..()
	if(!.)
		return FALSE

	choices -= get_choices_invalid_for_population()
	if(length(choices) == 1) // Only one choice, no need to vote. Let's just auto-rotate it to the only remaining map because it would just happen anyways.
		var/datum/map_config/change_me_out = global.config.maplist[choices[1]]
		finalize_vote(choices[1])// voted by not voting, very sad.
		to_chat(world, span_boldannounce("The map vote has been skipped because there is only one map left to vote for. \
			The map has been changed to [change_me_out.map_name]."))
		return FALSE
	if(length(choices) == 0)
		to_chat(world, span_boldannounce("A map vote was called, but there are no maps to vote for! \
			Players, complain to the admins. Admins, complain to the coders."))
		return FALSE

	return TRUE

/datum/vote/map_vote/toggle_votable()
	CONFIG_SET(flag/allow_vote_map, !CONFIG_GET(flag/allow_vote_map))

/datum/vote/map_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_map)

/datum/vote/map_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .
	if(forced)
		return VOTE_AVAILABLE
	var/num_choices = length(default_choices - get_choices_invalid_for_population())
	if(num_choices <= 1)
		return "There [num_choices == 1 ? "is only one map" : "are no maps"] to choose from."
	if(SSmapping.map_vote_rocked)
		return VOTE_AVAILABLE
	if(SSmapping.map_voted)
		return "The next map has already been selected."
	return VOTE_AVAILABLE

/// Returns a list of all map options that are invalid for the current population.
/datum/vote/map_vote/proc/get_choices_invalid_for_population()
	var/filter_threshold = 0
	if(SSticker.HasRoundStarted())
		filter_threshold = get_active_player_count(alive_check = FALSE, afk_check = TRUE, human_check = FALSE)
	else
		filter_threshold = GLOB.clients.len

	var/list/invalid_choices = list()
	for(var/map in default_choices)
		var/datum/map_config/possible_config = config.maplist[map]
		if(possible_config.config_min_users > 0 && filter_threshold < possible_config.config_min_users)
			invalid_choices += map

		else if(possible_config.config_max_users > 0 && filter_threshold > possible_config.config_max_users)
			invalid_choices += map

	return invalid_choices

/datum/vote/map_vote/get_vote_result(list/non_voters)
	// Even if we have default no vote off,
	// if our default map is null for some reason, we shouldn't continue
	if(CONFIG_GET(flag/default_no_vote) || isnull(global.config.defaultmap))
		return ..()

	for(var/non_voter_ckey in non_voters)
		var/client/non_voter_client = non_voters[non_voter_ckey]
		// Non-voters will have their preferred map voted for automatically.
		var/their_preferred_map = non_voter_client?.prefs.read_preference(/datum/preference/choiced/preferred_map)
		// If the non-voter's preferred map is null for some reason, we just use the default map.
		var/voting_for = their_preferred_map || global.config.defaultmap.map_name

		if(voting_for in choices)
			choices[voting_for] += 1

	return ..()

/datum/vote/map_vote/finalize_vote(winning_option)
	var/datum/map_config/winning_map = global.config.maplist[winning_option]
	if(!istype(winning_map))
		CRASH("[type] wasn't passed a valid winning map choice. (Got: [winning_option || "null"] - [winning_map || "null"])")

	SSmapping.changemap(winning_map)
	SSmapping.map_voted = TRUE
	if(SSmapping.map_vote_rocked)
		SSmapping.map_vote_rocked = FALSE

/proc/revert_map_vote()
	var/datum/map_config/override_map = SSmapping.config
	if(isnull(override_map))
		return

	SSmapping.changemap(override_map)
	log_game("The next map has been reset to [override_map.map_name].")
	send_to_playing_players(span_boldannounce("The next map is: [override_map.map_name]."))
