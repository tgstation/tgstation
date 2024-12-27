/// Returns the world.time of the next midround injection.
/// Will return a cached result from `next_midround_injection`, the variable.
/// If that variable is null, will generate a new one.
/datum/controller/subsystem/dynamic/proc/next_midround_injection()
	if (!isnull(next_midround_injection))
		return next_midround_injection

	// Admins can futz around with the midround threat, and we want to be able to react to that
	var/midround_threat = threat_level - round_start_budget

	var/rolls = CEILING(midround_threat / threat_per_midround_roll, 1)
	var/distance = ((1 / (rolls + 1)) * midround_upper_bound) + midround_lower_bound

	if (last_midround_injection_attempt == 0)
		last_midround_injection_attempt = SSticker.round_start_time

	return last_midround_injection_attempt + distance

/datum/controller/subsystem/dynamic/proc/try_midround_roll()
	if (!mid_forced_injection && next_midround_injection() > world.time)
		return

	if (GLOB.dynamic_forced_extended)
		return

	if (EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return

	var/spawn_heavy = prob(get_heavy_midround_injection_chance())

	last_midround_injection_attempt = world.time
	next_midround_injection = null
	mid_forced_injection = FALSE

	log_dynamic_and_announce("A midround ruleset is rolling, and will be [spawn_heavy ? "HEAVY" : "LIGHT"].")

	random_event_hijacked = HIJACKED_NOTHING

	var/list/drafted_heavies = list()
	var/list/drafted_lights = list()

	for (var/datum/dynamic_ruleset/midround/ruleset in midround_rules)
		if (ruleset.weight == 0)
			log_dynamic("FAIL: [ruleset] has a weight of 0")
			continue

		if (!ruleset.acceptable(GLOB.alive_player_list.len, threat_level))
			var/ruleset_forced = GLOB.dynamic_forced_rulesets[type] || RULESET_NOT_FORCED
			if (ruleset_forced == RULESET_NOT_FORCED)
				log_dynamic("FAIL: [ruleset] is not acceptable with the current parameters. Alive players: [GLOB.alive_player_list.len], threat level: [threat_level]")
			else
				log_dynamic("FAIL: [ruleset] was disabled.")
			continue

		if (mid_round_budget < ruleset.cost)
			log_dynamic("FAIL: [ruleset] is too expensive, and cannot be bought. Midround budget: [mid_round_budget], ruleset cost: [ruleset.cost]")
			continue

		if (ruleset.minimum_round_time > world.time - SSticker.round_start_time)
			log_dynamic("FAIL: [ruleset] is trying to run too early. Minimum round time: [ruleset.minimum_round_time], current round time: [world.time - SSticker.round_start_time]")
			continue

		// If admins have disabled dynamic from picking from the ghost pool
		if(istype(ruleset, /datum/dynamic_ruleset/midround/from_ghosts) && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
			log_dynamic("FAIL: [ruleset] is a from_ghosts ruleset, but ghost roles are disabled")
			continue

		ruleset.trim_candidates()
		ruleset.load_templates()
		if (!ruleset.ready())
			log_dynamic("FAIL: [ruleset] is not ready()")
			continue

		var/ruleset_is_heavy = (ruleset.midround_ruleset_style == MIDROUND_RULESET_STYLE_HEAVY)
		if (ruleset_is_heavy)
			drafted_heavies[ruleset] = ruleset.get_weight()
		else
			drafted_lights[ruleset] = ruleset.get_weight()

	var/heavy_light_log_count = "[drafted_heavies.len] heavies / [drafted_lights.len] lights"

	log_dynamic("Rolling [spawn_heavy ? "HEAVY" : "LIGHT"]... [heavy_light_log_count]")

	if (spawn_heavy && drafted_heavies.len > 0 && pick_midround_rule(drafted_heavies, "heavy rulesets"))
		return
	else if (drafted_lights.len > 0 && pick_midround_rule(drafted_lights, "light rulesets"))
		if (spawn_heavy)
			log_dynamic_and_announce("A heavy ruleset was intended to roll, but there weren't any available. [heavy_light_log_count]")
	else
		log_dynamic_and_announce("No midround rulesets could be drafted. ([heavy_light_log_count])")

/// Gets the chance for a heavy ruleset midround injection, the dry_run argument is only used for forced injection.
/datum/controller/subsystem/dynamic/proc/get_heavy_midround_injection_chance(dry_run)
	var/chance_modifier = 1
	var/next_midround_roll = next_midround_injection() - SSticker.round_start_time

	if (random_event_hijacked != HIJACKED_NOTHING)
		chance_modifier += (hijacked_random_event_injection_chance_modifier / 100)

	if (GLOB.current_living_antags.len == 0)
		chance_modifier += 0.5

	if (GLOB.dead_player_list.len > GLOB.alive_player_list.len)
		chance_modifier -= 0.3

	var/heavy_coefficient = CLAMP01((next_midround_roll - midround_light_upper_bound) / (midround_heavy_lower_bound - midround_light_upper_bound))

	return 100 * (heavy_coefficient * max(1, chance_modifier))
