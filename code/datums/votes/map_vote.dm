/datum/vote/map_vote
	name = "Map"

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

	// Before we create a vote, remove all maps from our choices that are outside of our population range.
	// Note that this can result in zero remaining choices for our vote, which is not ideal (but technically fine).
	for(var/map in choices)
		var/datum/map_config/possible_config = config.maplist[map]
		if(possible_config.config_min_users > 0 && GLOB.clients.len < possible_config.config_min_users)
			choices -= map

		else if(possible_config.config_max_users > 0 && GLOB.clients.len > possible_config.config_max_users)
			choices -= map

/datum/vote/map_vote/toggle_votable(mob/toggler)
	if(!toggler)
		CRASH("[type] wasn't passed a \"toggler\" mob to toggle_votable.")
	if(!check_rights_for(toggler.client, R_ADMIN))
		return FALSE

	CONFIG_SET(flag/allow_vote_map, !CONFIG_GET(flag/allow_vote_map))
	return TRUE

/datum/vote/map_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_map)

/datum/vote/map_vote/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(forced)
		return TRUE

	if(!CONFIG_GET(flag/allow_vote_map))
		if(by_who)
			to_chat(by_who, span_warning("Map voting is disabled."))
		return FALSE

	if(SSmapping.map_voted)
		if(by_who)
			to_chat(by_who, span_warning("The next map has already been selected."))
		return FALSE

	return TRUE

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
