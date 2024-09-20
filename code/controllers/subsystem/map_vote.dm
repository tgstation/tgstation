#define MAP_VOTE_CACHE_LOCATION "data/map_vote_cache.json"

SUBSYSTEM_DEF(map_vote)
	name = "Map Vote"
	flags = SS_NO_FIRE

	/// Has an admin specifically set a map.
	var/admin_override = FALSE

	/// Have we already done a vote.
	var/already_voted = FALSE

	/// The map that has been chosen for next round.
	var/datum/map_config/next_map_config

	/// Stores the current map vote cache, so that players can look at the current tally.
	var/list/map_vote_cache

	/// Stores the previous map vote cache, used when a map vote is reverted.
	var/list/previous_cache

/datum/controller/subsystem/map_vote/Initialize()
	if(!fexists(MAP_VOTE_CACHE_LOCATION))
		map_vote_cache = json_decode(file2text(MAP_VOTE_CACHE_LOCATION))
		var/carryover = CONFIG_GET(number/map_vote_tally_carryover_percentage)
		for(var/map_id in map_vote_cache)
			map_vote_cache[map_id] = round(map_vote_cache[map_id] * (carryover / 100))
		sanitize_cache()
	else
		map_vote_cache = list()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/map_vote/proc/write_cache()
	text2file(json_encode(map_vote_cache), MAP_VOTE_CACHE_LOCATION)

/datum/controller/subsystem/map_vote/proc/sanitize_cache()
	var/max = CONFIG_GET(number/map_vote_maximum_tallies)
	for(var/map_id in map_vote_cache)
		if(!(map_id in config.maplist))
			map_vote_cache -= map_id
		var/count = map_vote_cache[map_id]
		if(count > max)
			map_vote_cache[map_id] = max

/datum/controller/subsystem/map_vote/proc/map_vote_notice(list/messages)
	if(!islist(messages))
		messages = args
	to_chat(world, span_purple(examine_block("Map Vote\n<hr>\n[messages.Join("\n")]")))

/datum/controller/subsystem/map_vote/proc/finalize_map_vote(datum/vote/map_vote/map_vote)
	if(already_voted)
		message_admins("Attempted to finalize a map vote after a map vote has already been finalized.")
		return

	previous_cache = map_vote_cache.Copy()
	for(var/map_id in map_vote.choices)
		map_vote_cache[map_id] += map_vote.choices[map_id]
	sanitize_cache()
	write_cache()

	if(admin_override)
		map_vote_notice("Admin Override is in effect. Map will not be changed.", "Tallies are recorded and saved.")
		return

	var/winner = pick_weight(map_vote_cache)
	map_vote_cache[winner] = CONFIG_GET(number/map_vote_minimum_tallies)
	set_next_map(config.maplist[winner])
	write_cache()

/datum/controller/subsystem/map_vote/proc/set_next_map(datum/map_config/change_to)
	if(!change_to.MakeNextMap())
		message_admins("Failed to set new map with next_map.json for [change_to.map_name]!")
		return FALSE

	var/filter_threshold = get_active_player_count(alive_check = FALSE, afk_check = TRUE, human_check = FALSE)
	if (change_to.config_min_users > 0 && filter_threshold != 0 && filter_threshold < change_to.config_min_users)
		message_admins("[change_to.map_name] was chosen for the next map, despite there being less current players than its set minimum population range!")
		log_game("[change_to.map_name] was chosen for the next map, despite there being less current players than its set minimum population range!")
	if (change_to.config_max_users > 0 && filter_threshold > change_to.config_max_users)
		message_admins("[change_to.map_name] was chosen for the next map, despite there being more current players than its set maximum population range!")
		log_game("[change_to.map_name] was chosen for the next map, despite there being more current players than its set maximum population range!")

	next_map_config = change_to
	return TRUE

/datum/controller/subsystem/map_vote/proc/revert_next_map()
	if(!next_map_config)
		return
	if(previous_cache)
		map_vote_cache = previous_cache
		previous_cache = null

	already_voted = FALSE
	admin_override = FALSE
	map_vote_notice("Next map reverted. Voting re-enabled.")

#undef MAP_VOTE_CACHE_LOCATION
