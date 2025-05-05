SUBSYSTEM_DEF(dynamic)
	name = "Dynamic"
	flags = SS_NO_INIT
	wait = 1 MINUTES

	/// Reference to a dynamic tier datum, the tier picked for this round
	var/datum/dynamic_tier/current_tier

	/// The config for dynamic loaded from the toml file
	var/list/dynamic_config = list()

	/// Tracks how many of each ruleset category is yet to be spawned
	var/list/rulesets_to_spawn = list(
		ROUNDSTART_RANGE = -1,
		LIGHT_MIDROUND_RANGE = -1,
		HEAVY_MIDROUND_RANGE = -1,
		LATEJOIN_RANGE = -1,
	)

	/// Cooldown for when we are allowed to spawn light rulesets
	COOLDOWN_DECLARE(light_ruleset_start)
	/// Cooldown for when we are allowed to spawn heavy rulesets
	COOLDOWN_DECLARE(heavy_ruleset_start)
	/// Cooldown for when we are allowed to spawn latejoin rulesets
	COOLDOWN_DECLARE(latejoin_ruleset_start)

	/// Cooldown between spawning any mid-game ruleset (latejoin or midround)
	COOLDOWN_DECLARE(ruleset_cooldown)

	/// List of rulesets that have been executed this round
	var/list/datum/dynamic_ruleset/executed_rulesets = list()
	/// List of rulesets that have been set up to run, but not yet executed
	var/list/datum/dynamic_ruleset/queued_rulesets = list()

/datum/controller/subsystem/dynamic/fire(resumed)
	spawn_midround()

/**
 * Selects which rulesets are to run at roundstart, and sets them up
 *
 * Note: This proc can sleep (due to lazyloading of templates)!
 */
/datum/controller/subsystem/dynamic/proc/select_roundstart_antagonists()
	load_config()
	SEND_SIGNAL(src, COMSIG_DYNAMIC_PRE_ROUNDSTART, dynamic_config)
	// we start by doing a dry run of the job selection process to detect antag rollers
	SSjob.divide_occupations(pure = TRUE, allow_all = TRUE)

	var/list/antag_candidates = list()
	// anyone who was readied up and NOT unassigned is a potential candidate (even those who have no antag preferences)
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list - SSjob.unassigned)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			antag_candidates += player

	// anyone unassigned are potential antag rollers, so we need to warn them
	for(var/mob/dead/new_player/player as anything in SSjob.unassigned)
		var/list/job_data = list()
		var/job_prefs = player.client?.prefs.job_preferences
		for(var/job in job_prefs)
			var/priority = job_prefs[job]
			job_data += "[job]: [SSjob.job_priority_level_to_string(priority)]"
		to_chat(player, span_danger("You were unable to qualify for any roundstart antagonist role this round \
			because your job preferences presented a high chance of all of your selected jobs being unavailable, \
			along with 'return to lobby if job is unavailable' enabled. \
			Increase the number of roles set to medium or low priority to reduce the chances of this happening."))
		log_admin("[player.ckey] failed to qualify for any roundstart antagonist role \
			because their job preferences presented a high chance of all of their selected jobs being unavailable, \
			along with 'return to lobby if job is unavailable' enabled and has [player.client.prefs.be_special.len] antag preferences enabled. \
			They will be unable to qualify for any roundstart antagonist role. These are their job preferences - [job_data.Join(" | ")]")

	// we got what we needed, reset so we can do real job selection later
	SSjob.reset_occupations()

	var/num_real_players = length(antag_candidates)
	// now select a tier.
	// this also calculates the number of rulesets to spawn
	pick_tier(num_real_players)
	// and finally, select and run the roundstart rulesets
	// pick_roundstart_rulesets handles filtering out invalid options for us,
	// and even handles if we intend to have 0 roundstart rulesets (greenshift)
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in pick_roundstart_rulesets(num_real_players))
		// NOTE: !! THIS CAN SLEEP !!
		if(!ruleset.prepare_execution( num_real_players, antag_candidates ))
			qdel(ruleset)
			continue

		// Purely for logging
		for(var/datum/mind/selected as anything in ruleset.selected_minds)
			log_dynamic("Dynamic: [key_name(selected)] has been selected for [ruleset.name].")

		// Execution actually happens in post_setup
		queued_rulesets += ruleset
		rulesets_to_spawn[ROUNDSTART_RANGE] -= 1

	return TRUE

/datum/controller/subsystem/dynamic/proc/load_config()
	PRIVATE_PROC(TRUE)

	if(!CONFIG_GET(flag/dynamic_config_enabled))
		return

	var/config_file = file("[global.config.directory]/dynamic.toml")
	if(!fexists(config_file))
		return
	var/list/result = rustg_raw_read_toml_file(config_file)
	if(!result["success"])
		log_dynamic("Dynamic: Failed to load config file [config_file]")
		return

	dynamic_config = json_decode(result["content"])

/// Picks what tier we are going to use for this round and sets up all the corresponding variables and ranges
/datum/controller/subsystem/dynamic/proc/pick_tier(roundstart_population = 0)
	PRIVATE_PROC(TRUE)

	var/list/tier_weighted = list()
	for(var/datum/dynamic_tier/tier_datum as anything in subtypesof(/datum/dynamic_tier))
		var/min_players_config = dynamic_config[tier_datum::config_tag]?[NAMEOF(tier_datum, min_pop)]
		var/min_players = isnull(min_players_config) ? tier_datum::min_pop : min_players_config
		if(roundstart_population < min_players)
			continue

		var/tier_config_weight = dynamic_config[tier_datum::config_tag]?[NAMEOF(tier_datum, weight)]
		var/tier_weight = isnull(tier_config_weight) ? tier_datum::weight : tier_config_weight
		if(tier_weight <= 0)
			continue

		tier_weighted[tier_datum] = tier_weight

	var/picked_tier = pick_weight(tier_weighted)

	current_tier = new picked_tier(dynamic_config)

	for(var/category in current_tier.ruleset_ranges)
		var/list/range = current_tier.ruleset_ranges[category] || list()
		var/low_end = range[LOW_END] || 0
		var/high_end = range[HIGH_END] || 0

		if(roundstart_population <= (range[HALF_RANGE_POP_THRESHOLD] || 0))
			high_end = max(low_end, ceil(high_end * 0.25))
		else if(roundstart_population <= (range[FULL_RANGE_POP_THRESHOLD] || 0))
			high_end = max(low_end, ceil(high_end * 0.5))

		rulesets_to_spawn[category] = rand(low_end, high_end)

	COOLDOWN_START(src, light_ruleset_start, current_tier.ruleset_ranges[LIGHT_MIDROUND_RANGE][TIME_THRESHOLD])
	COOLDOWN_START(src, heavy_ruleset_start, current_tier.ruleset_ranges[HEAVY_MIDROUND_RANGE][TIME_THRESHOLD])
	COOLDOWN_START(src, latejoin_ruleset_start, current_tier.ruleset_ranges[LATEJOIN_RANGE][TIME_THRESHOLD])

	var/roundstart_spawn = rulesets_to_spawn[ROUNDSTART_RANGE]
	var/light_midround_spawn = rulesets_to_spawn[LIGHT_MIDROUND_RANGE]
	var/heavy_midround_spawn = rulesets_to_spawn[HEAVY_MIDROUND_RANGE]
	var/latejoin_spawn = rulesets_to_spawn[LATEJOIN_RANGE]

	log_dynamic("Dynamic tier: [current_tier.tier]")
	log_dynamic("- Roundstart population: [roundstart_population]")
	log_dynamic("- Roundstart ruleset count: [roundstart_spawn]")
	log_dynamic("- Light midround ruleset count: [light_midround_spawn]")
	log_dynamic("- Heavy midround ruleset count: [heavy_midround_spawn]")
	log_dynamic("- Latejoin ruleset count: [latejoin_spawn]")
	SSblackbox.record_feedback(
		"associative",
		"dynamic_tier",
		1,
		list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"tier" = current_tier.tier,
			"player_count" = roundstart_population,
			"roundstart_ruleset_count" = roundstart_spawn,
			"light_midround_ruleset_count" = light_midround_spawn,
			"heavy_midround_ruleset_count" = heavy_midround_spawn,
			"latejoin_ruleset_count" = latejoin_spawn,
		),
	)

/datum/controller/subsystem/dynamic/proc/get_roundstart_rulesets(list/antag_candidates)
	PRIVATE_PROC(TRUE)

	var/list/datum/dynamic_ruleset/roundstart/rulesets = list()
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset/roundstart))
		var/datum/dynamic_ruleset/roundstart/ruleset = new ruleset_type(dynamic_config)
		rulesets[ruleset] = ruleset.get_weight(length(antag_candidates))

	return rulesets

/datum/controller/subsystem/dynamic/proc/pick_roundstart_rulesets(list/antag_candidates)
	PRIVATE_PROC(TRUE)

	var/roundstart_ruleset_num = rulesets_to_spawn[ROUNDSTART_RANGE]
	if(roundstart_ruleset_num <= 0)
		return

	var/list/rulesets_weighted = get_roundstart_rulesets(antag_candidates)
	var/total_weight = 0
	for(var/ruleset in rulesets_weighted)
		total_weight += rulesets_weighted[ruleset]

	var/list/picked_rulesets = list()
	while(rulesets_to_spawn[ROUNDSTART_RANGE] > 0)
		if(!length(rulesets_weighted))
			log_dynamic("Roundstart: No more rulesets to pick from with [rulesets_to_spawn[ROUNDSTART_RANGE]] left!")
			break
		rulesets_to_spawn[ROUNDSTART_RANGE] -= 1
		var/datum/dynamic_ruleset/picked_ruleset = pick_weight(rulesets_weighted)
		picked_rulesets += picked_ruleset
		log_dynamic("Roundstart: Ruleset [picked_ruleset.name] (Chance: [round(rulesets_weighted[picked_ruleset] / total_weight * 100, 0.01)]%)")
		if(!picked_ruleset.repeatable)
			rulesets_weighted -= picked_ruleset
		else if(picked_ruleset.repeatable_weight_decrease)
			rulesets_weighted[picked_ruleset] -= picked_ruleset.repeatable_weight_decrease
			total_weight -= picked_ruleset.repeatable_weight_decrease

	// clean up unused rulesets
	rulesets_weighted -= picked_rulesets
	QDEL_LIST(rulesets_weighted)
	return picked_rulesets

/datum/controller/subsystem/dynamic/proc/get_advisory_report()
	var/shown_tier = current_tier.tier
	if(prob(10))
		shown_tier = pick(list(DYNAMIC_TIER_LOW, DYNAMIC_TIER_LOWMEDIUM, DYNAMIC_TIER_MEDIUMHIGH, DYNAMIC_TIER_HIGH) - current_tier.tier)

	else if(prob(15))
		shown_tier = clamp(current_tier.tier + pick(-1, 1), DYNAMIC_TIER_LOW, DYNAMIC_TIER_HIGH)

	for(var/datum/dynamic_tier/tier_datum as anything in subtypesof(/datum/dynamic_tier))
		if(tier_datum::tier == shown_tier)
			return tier_datum::advisory_report

	return null

/**
 * Invoked by SSdynamic to try to spawn a random midround ruleset
 * Respects ranges and thresholds
 *
 * Prioritizes light midround rulesets first, then heavy midround rulesets
 *
 * Returns TRUE if a ruleset was spawned, FALSE otherwise
 */
/datum/controller/subsystem/dynamic/proc/spawn_midround(mob/living/carbon/human/latejoiner)
	if(!COOLDOWN_FINISHED(src, ruleset_cooldown))
		return FALSE

	if(COOLDOWN_FINISHED(src, light_ruleset_start) && rulesets_to_spawn[LIGHT_MIDROUND_RANGE] > 0)
		if(try_run_light_midround())
			rulesets_to_spawn[LIGHT_MIDROUND_RANGE] -= 1
			return TRUE

	if(COOLDOWN_FINISHED(src, heavy_ruleset_start) && rulesets_to_spawn[HEAVY_MIDROUND_RANGE] > 0)
		if(try_run_heavy_midround())
			rulesets_to_spawn[HEAVY_MIDROUND_RANGE] -= 1
			return TRUE

	return FALSE

/datum/controller/subsystem/dynamic/proc/get_midround_rulesets(midround_type)
	PRIVATE_PROC(TRUE)

	var/list/datum/dynamic_ruleset/midround/rulesets = list()
	for(var/datum/dynamic_ruleset/midround/ruleset_type as anything in subtypesof(/datum/dynamic_ruleset/midround))
		if(initial(ruleset_type.midround_type) != midround_type)
			continue
		var/datum/dynamic_ruleset/midround/ruleset = new ruleset_type(dynamic_config)
		rulesets[ruleset] = ruleset.get_weight(length(GLOB.alive_player_list))

	return rulesets

/// Picks a random light midround ruleset, and tries to run it
/datum/controller/subsystem/dynamic/proc/try_run_light_midround()
	PRIVATE_PROC(TRUE)

	var/list/rulesets_weighted = get_midround_rulesets(MIDROUND_RULESET_STYLE_LIGHT)
	var/datum/dynamic_ruleset/midround/picked_ruleset = pick_weight(rulesets_weighted)
	// NOTE: !! THIS CAN SLEEP !!
	if(!picked_ruleset.prepare_execution( length(GLOB.alive_player_list), picked_ruleset.collect_candidates() ))
		QDEL_LIST(rulesets_weighted)
		return FALSE
	// Purely for logging
	for(var/datum/mind/selected as anything in picked_ruleset.selected_minds)
		message_admins("[ADMIN_LOOKUPFLW(selected)] has been selected for [picked_ruleset.name].")
		log_dynamic("Dynamic: [key_name(selected)] has been selected for [picked_ruleset.name].")
	// Run the thing
	executed_rulesets += picked_ruleset
	rulesets_weighted -= picked_ruleset
	picked_ruleset.execute()
	// Clean up unused rulesets
	QDEL_LIST(rulesets_weighted)
	return TRUE

/// Picks a random heavy midround ruleset, and tries to run it
/datum/controller/subsystem/dynamic/proc/try_run_heavy_midround()
	PRIVATE_PROC(TRUE)

	var/list/rulesets_weighted = get_midround_rulesets(MIDROUND_RULESET_STYLE_HEAVY)
	var/datum/dynamic_ruleset/midround/picked_ruleset = pick_weight(rulesets_weighted)
	// NOTE: !! THIS CAN SLEEP !!
	if(!picked_ruleset.prepare_execution( length(GLOB.alive_player_list), picked_ruleset.collect_candidates() ))
		QDEL_LIST(rulesets_weighted)
		return FALSE
	// Purely for logging
	for(var/datum/mind/selected as anything in picked_ruleset.selected_minds)
		message_admins("[ADMIN_LOOKUPFLW(selected)] has been selected for [picked_ruleset.name].")
		log_dynamic("Dynamic: [key_name(selected)] has been selected for [picked_ruleset.name].")
	// Run the thing
	executed_rulesets += picked_ruleset
	rulesets_weighted -= picked_ruleset
	picked_ruleset.execute()
	// Clean up unused rulesets
	QDEL_LIST(rulesets_weighted)
	return TRUE

/**
 * Attempt to run a midround ruleset of the given type
 *
 * * midround_type - The type of midround ruleset to force
 * * * forced_min_cap - Rather than using the ruleset's mid antag cap, use this value
 * * * forced_max_cap - Rather than using the ruleset's max antag cap, use this value
 */
/datum/controller/subsystem/dynamic/proc/run_midround(midround_typepath, forced_min_cap, forced_max_cap)
	set waitfor = FALSE // prepare_execution can sleep (polling)
	if(!ispath(midround_typepath, /datum/dynamic_ruleset/midround))
		CRASH("run_midround() was called with an invalid midround type: [midround_typepath]")

	var/datum/dynamic_ruleset/midround/running = new midround_typepath(dynamic_config)
	if(isnum(forced_min_cap))
		running.min_antag_cap = forced_min_cap
	if(isnum(forced_max_cap))
		running.max_antag_cap = forced_max_cap

	// NOTE: !! THIS CAN SLEEP !!
	if(!running.prepare_execution( length(GLOB.alive_player_list), running.collect_candidates() ))
		qdel(running)
		return

	// Purely for logging
	for(var/datum/mind/selected as anything in running.selected_minds)
		message_admins("[ADMIN_LOOKUPFLW(selected)] has been selected for [running.name].")
		log_dynamic("Dynamic: [key_name(selected)] has been selected for [running.name].")

	executed_rulesets += running
	running.execute()

/**
 * Invoked by SSdynamic to try to spawn a latejoin ruleset
 * Respects ranges and thresholds
 *
 * Prioritizes queued rulesets first, then selects a random one
 *
 * Returns TRUE if a ruleset was spawned, FALSE otherwise
 */
/datum/controller/subsystem/dynamic/proc/spawn_latejoin(mob/living/carbon/human/latejoiner)
	// First check queued rulesets
	for(var/datum/dynamic_ruleset/latejoin/queued in queued_rulesets)
		// NOTE: !! THIS CAN SLEEP !!
		if(!queued.prepare_execution(length(GLOB.alive_player_list), list(latejoiner)))
			continue
		queued_rulesets -= queued
		executed_rulesets += queued
		queued.execute()
		return TRUE

	// Queued rulesets disregard the time threshold
	if(!COOLDOWN_FINISHED(src, latejoin_ruleset_start) || !COOLDOWN_FINISHED(src, ruleset_cooldown))
		return FALSE
	if(rulesets_to_spawn[LATEJOIN_RANGE] <= 0)
		return FALSE
	if(try_run_latejoin(latejoiner))
		rulesets_to_spawn[LATEJOIN_RANGE] -= 1
		return TRUE
	return FALSE

/datum/controller/subsystem/dynamic/proc/get_latejoin_rulesets(mob/living/carbon/human/latejoiner)
	PRIVATE_PROC(TRUE)

	var/list/datum/dynamic_ruleset/latejoin/rulesets = list()
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset/latejoin))
		var/datum/dynamic_ruleset/latejoin/ruleset = new ruleset_type(dynamic_config)
		rulesets[ruleset] = ruleset.get_weight(length(GLOB.alive_player_list))

	return rulesets

/// Picks a random latejoin ruleset, and tries to run it
/datum/controller/subsystem/dynamic/proc/try_run_latejoin(mob/living/carbon/human/latejoiner)
	PRIVATE_PROC(TRUE)
	var/list/rulesets_weighted = get_latejoin_rulesets(latejoiner)
	// Note, we make no effort to actually pick a valid ruleset here
	// We pick a ruleset, and they player might not even have that antag selected. And that's fine
	var/datum/dynamic_ruleset/latejoin/picked_ruleset = pick_weight(rulesets_weighted)
	// NOTE: !! THIS CAN SLEEP !!
	if(!picked_ruleset.prepare_execution( length(GLOB.alive_player_list), list(latejoiner) ))
		QDEL_LIST(rulesets_weighted)
		return FALSE
	// Purely for logging
	for(var/datum/mind/selected as anything in picked_ruleset.selected_minds)
		message_admins("[ADMIN_LOOKUPFLW(selected)] has been selected for [picked_ruleset.name].")
		log_dynamic("Dynamic: [key_name(selected)] has been selected for [picked_ruleset.name].")
	// Run the thing
	executed_rulesets += picked_ruleset
	rulesets_weighted -= picked_ruleset
	picked_ruleset.execute()
	// Clean up unused rulesets
	QDEL_LIST(rulesets_weighted)
	return TRUE

/**
 * Queues a latejoin ruleset to run on next latejoin which fulfills all requirements
 * For example, if you queue a latejoin revolutionary, it'll only run when population gets large enough and there are enough heads of staff
 * For all latejoins until then, it will simply do nothing
 *
 * * latejoin_type - The type of latejoin ruleset to force
 * * forced_min_cap - Rather than using the ruleset's min antag cap, use this value
 * * forced_max_cap - Rather than using the ruleset's max antag cap, use this value
 */
/datum/controller/subsystem/dynamic/proc/queue_latejoin(latejoin_typepath, forced_min_cap, forced_max_cap)
	if(!ispath(latejoin_typepath, /datum/dynamic_ruleset/latejoin))
		CRASH("queue_latejoin() was called with an invalid latejoin type: [latejoin_typepath]")

	var/datum/dynamic_ruleset/latejoin/running = new latejoin_typepath(dynamic_config)
	if(isnum(forced_min_cap))
		running.min_antag_cap = forced_min_cap
	if(isnum(forced_max_cap))
		running.max_antag_cap = forced_max_cap
	queued_rulesets += running

// Set result and news report here
/datum/controller/subsystem/dynamic/proc/set_round_result()
	// If it got to this part, just pick one high impact ruleset if it exists
	for(var/datum/dynamic_ruleset/rule as anything in executed_rulesets)
		if(rule.round_result())
			return

	SSticker.mode_result = "undefined"

	switch(GLOB.revolution_handler?.result)
		if(STATION_VICTORY)
			SSticker.mode_result = "loss - rev heads killed"
			SSticker.news_report = REVS_LOSE
		if(REVOLUTION_VICTORY)
			SSticker.mode_result = "win - heads killed"
			SSticker.news_report = REVS_WIN

	// Something nuked the station - it wasn't nuke ops (they set their own via their rulset)
	if(GLOB.station_was_nuked)
		SSticker.news_report = STATION_NUKED

	if(SSsupermatter_cascade.cascade_initiated)
		SSticker.news_report = SUPERMATTER_CASCADE

	// Only show this one if we have nothing better to show
	if(EMERGENCY_ESCAPED_OR_ENDGAMED && !SSticker.news_report)
		SSticker.news_report = SSshuttle.emergency?.is_hijacked() ? SHUTTLE_HIJACK : STATION_EVACUATED

/proc/build_dynamic_toml()
	var/data = ""
	for(var/tier_type in subtypesof(/datum/dynamic_tier))
		var/datum/dynamic_tier/tier = new tier_type()
		if(!tier.config_tag)
			qdel(tier)
			continue

		data += "\[[tier.config_tag]\]\n"
		data += "name = \"[tier.name]\"\n"
		data += "min_pop = [tier.min_pop]\n"
		data += "advisory_report = \"[tier.advisory_report]\"\n"
		for(var/range in tier.ruleset_ranges)
			data += "ruleset_ranges.[range].[LOW_END] = [tier.ruleset_ranges[range]?[LOW_END] || 0]\n"
			data += "ruleset_ranges.[range].[HIGH_END] = [tier.ruleset_ranges[range]?[HIGH_END] || 0]\n"
			data += "ruleset_ranges.[range].[HALF_RANGE_POP_THRESHOLD] = [tier.ruleset_ranges[range]?[HALF_RANGE_POP_THRESHOLD] || 0]\n"
			data += "ruleset_ranges.[range].[FULL_RANGE_POP_THRESHOLD] = [tier.ruleset_ranges[range]?[FULL_RANGE_POP_THRESHOLD] || 0]\n"
			if(range != ROUNDSTART_RANGE)
				data += "ruleset_ranges.[range].[TIME_THRESHOLD] = [tier.ruleset_ranges[range]?[TIME_THRESHOLD] || 0]\n"
		data += "\n"
		qdel(tier)

	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset))
		var/datum/dynamic_ruleset/ruleset = new ruleset_type()
		if(!ruleset.config_tag)
			qdel(ruleset)
			continue

		data += "\[[ruleset.config_tag]\]\n"
		if(islist(ruleset.weight))
			for(var/i in 1 to length(ruleset.weight))
				data += "weight.[i] = [ruleset.weight[i]]\n"
		else
			data += "weight = [ruleset.weight || 0]\n"
		if(islist(ruleset.min_pop))
			for(var/i in 1 to length(ruleset.min_pop))
				data += "min_pop.[i] = [ruleset.min_pop[i]]\n"
		else
			data += "min_pop = [ruleset.min_pop || 0]\n"
		if(length(ruleset.blacklisted_roles))
			data += "blacklisted_roles = \[\n"
			for(var/i in ruleset.blacklisted_roles)
				data += "\t[i],\n"
			data += "\]\n"
		else
			data += "blacklisted_roles = \[\]\n"
		if(!istype(ruleset, /datum/dynamic_ruleset/latejoin) && !istype(ruleset, /datum/dynamic_ruleset/midround/from_living))
			if(islist(ruleset.min_antag_cap))
				for(var/ruleset_min_antag_cap in ruleset.min_antag_cap)
					data += "min_antag_cap.[ruleset_min_antag_cap] = [ruleset.min_antag_cap[ruleset_min_antag_cap]]\n"
			else
				data += "min_antag_cap = [ruleset.min_antag_cap || 0]\n"
			if(islist(ruleset.max_antag_cap))
				for(var/ruleset_max_antag_cap in ruleset.max_antag_cap)
					data += "max_antag_cap.[ruleset_max_antag_cap] = [ruleset.max_antag_cap[ruleset_max_antag_cap]]\n"
			else if(!isnull(ruleset.max_antag_cap))
				data += "max_antag_cap = [ruleset.max_antag_cap]\n"
			else
				data += "# max_antag_cap = null ## defaults to min_antag_cap\n"
		data += "repeatable_weight_decrease = [ruleset.repeatable_weight_decrease]\n"
		data += "repeatable = [ruleset.repeatable]\n"
		data += "minimum_required_age = [ruleset.minimum_required_age]\n"
		data += "\n"
		qdel(ruleset)

	var/fp = "code/controllers/subsystem/dynamic2024/dynamic.toml"
	fdel(file(fp))
	text2file(data, fp)
	return TRUE
