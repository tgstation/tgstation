/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * recent_episodes - The number of recent antagonist episodes
 *
 * Returns a weight value (higher = more likely to be selected)
 */
/proc/calculate_candidate_weight(recent_episodes)
	if(!recent_episodes)
		return CONFIG_GET(number/antag_base_weight)

	var/base_weight = CONFIG_GET(number/antag_base_weight)
	var/penalty_per_episode = CONFIG_GET(number/antag_weight_penalty)
	var/min_weight = CONFIG_GET(number/antag_min_weight)

	return max(base_weight - (recent_episodes * penalty_per_episode), min_weight)

/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * candidate_ckey - The ckey of the player
 *
 * Returns a weight value (higher = more likely to be selected)
 */
/datum/dynamic_ruleset/proc/get_candidate_weight(candidate_ckey)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!candidate_ckey)
		return CONFIG_GET(number/antag_base_weight)

	var/recent_episodes = count_player_antag_episodes(candidate_ckey)
	var/weight = calculate_candidate_weight(recent_episodes)

	if(CONFIG_GET(flag/log_antag_candidate_weight))
		log_dynamic("[config_tag]: Candidate weight for [candidate_ckey]: recent=[recent_episodes], final=[weight]")

	return weight

/**
 * Counts the number of antagonist episodes for a player in the known time window.
 *
 * * ckey - The ckey of the player
 *
 * Returns the number of antagonist episodes
 */
/datum/dynamic_ruleset/proc/count_player_antag_episodes(ckey)
	return 0

/datum/dynamic_ruleset/roundstart/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_roundstart)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)

/datum/dynamic_ruleset/midround/from_ghosts/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_midround)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)

/datum/dynamic_ruleset/latejoin/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_latejoin)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)

/datum/dynamic_ruleset/latejoin/is_valid_candidate(mob/candidate, client/candidate_client)
	if(!..())
		return FALSE

	if(!CONFIG_GET(flag/antag_weighted_selection))
		return TRUE

	var/base_weight = CONFIG_GET(number/antag_base_weight)
	var/current_weight = get_candidate_weight(candidate.ckey)
	var/selection_chance = 100 * current_weight / base_weight

	if(prob(selection_chance))
		return TRUE

	if(CONFIG_GET(flag/log_antag_candidate_weight))
		log_dynamic("[config_tag]: Candidate [candidate_client.ckey] failed latejoin weight check ([selection_chance]%)")

	return FALSE

/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * candidate_ckey - The ckey of the player
 *
 * Returns a weight value (higher = more likely to be selected)
 */
/datum/round_event/ghost_role/proc/get_candidate_weight(candidate_ckey)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!candidate_ckey)
		return CONFIG_GET(number/antag_base_weight)

	var/recent_episodes = count_player_antag_episodes(candidate_ckey)
	var/weight = calculate_candidate_weight(recent_episodes)

	if(CONFIG_GET(flag/log_antag_candidate_weight))
		log_dynamic("[role_name]: Candidate weight for [candidate_ckey]: recent=[recent_episodes], final=[weight]")

	return weight

/**
 * Counts the number of antagonist episodes for a player in the known time window.
 *
 * * ckey - The ckey of the player
 *
 * Returns the number of antagonist episodes
 */
/datum/round_event/ghost_role/proc/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_midround)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)
