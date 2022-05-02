/datum/vote/map_vote
	config_key = "allow_vote_map"

/datum/vote/map_vote/New()
	. = ..()

	default_choices = list()

	var/list/maps = shuffle(global.config.maplist)

	for(var/map in maps)
		var/datum/map_config/possible_config = config.maplist[map]
		if(!possible_config.votable || (possible_config.map_name in SSpersistence.blocked_maps))
			continue
		if (possible_config.config_min_users > 0 && GLOB.clients.len < VM.config_min_users)
			continue
		if (possible_config.config_max_users > 0 && GLOB.clients.len > VM.config_max_users)
			continue

		default_choices += possible_config.map_name

/datum/vote/map_vote/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!forced && SSmapping.map_voted)
		if(by_who)
			to_chat(by_who, span_warning("The next map has already been selected."))
		return FALSE

	return TRUE

/datum/vote/map_vote/get_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote) && !isnull(global.config.defaultmap))
		for(var/non_voter_ckey in non_voters)
			var/client/non_voter_client = non_voters[non_voter_ckey]
			// Non-voters will have their preferred map voted for automatically.
			var/their_preferred_map = non_voter_client?.prefs?.read_preference(/datum/preference/choiced/preferred_map)
			var/default_map = global.config.defaultmap.map_name

			// If the non-voter's preferred map is null for some reason, we just use the default map.
			choices[their_preferred_map || default_map] += 1

	return ..()

/datum/vote/map_vote/finalize_vote(winning_option)
	var/datum/map_config/winning_map = global.config.maplist[winning_option]
	if(!istype(winning_map))
		CRASH("[type] wasn't passed a valid winning map choice. (Got: [winning_option])")

	SSmapping.changemap(winning_map)
	SSmapping.map_voted = TRUE
