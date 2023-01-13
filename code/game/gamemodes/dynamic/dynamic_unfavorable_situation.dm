/// An easy interface to make...*waves hands* bad things happen.
/// This is used for impactful events like traitors hacking and creating more threat, or a revolutions victory.
/// It tries to spawn a heavy midround if possible, otherwise it will trigger a "bad" random event after a short period.
/// Calling this function will not use up any threat.
/datum/game_mode/dynamic/proc/unfavorable_situation()
	SHOULD_NOT_SLEEP(TRUE)

	INVOKE_ASYNC(src, PROC_REF(_unfavorable_situation))

/datum/game_mode/dynamic/proc/_unfavorable_situation()
	var/static/list/unfavorable_random_events = list(
		/datum/round_event_control/immovable_rod,
		/datum/round_event_control/meteor_wave,
		/datum/round_event_control/portal_storm_syndicate,
	)

	var/list/possible_heavies = list()

	// Ignored factors: threat cost, minimum round time
	for (var/datum/dynamic_ruleset/midround/ruleset as anything in midround_rules)
		if (ruleset.midround_ruleset_style != MIDROUND_RULESET_STYLE_HEAVY)
			continue

		if (ruleset.weight == 0)
			continue

		if (ruleset.cost > max_threat_level)
			continue

		if (!ruleset.acceptable(GLOB.alive_player_list.len, threat_level))
			continue

		if (ruleset.minimum_round_time > world.time - SSticker.round_start_time)
			continue

		if(istype(ruleset, /datum/dynamic_ruleset/midround/from_ghosts) && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
			continue

		ruleset.trim_candidates()

		ruleset.load_templates()
		if (!ruleset.ready())
			continue

		possible_heavies[ruleset] = ruleset.get_weight()

	if (possible_heavies.len == 0)
		var/datum/round_event_control/round_event_control_type = pick(unfavorable_random_events)
		var/delay = rand(20 SECONDS, 1 MINUTES)

		log_dynamic_and_announce("An unfavorable situation was requested, but no heavy rulesets could be drafted. Spawning [initial(round_event_control_type.name)] in [DisplayTimeText(delay)] instead.")

		var/datum/round_event_control/round_event_control = new round_event_control_type
		addtimer(CALLBACK(round_event_control, TYPE_PROC_REF(/datum/round_event_control, runEvent)), delay)
	else
		var/datum/dynamic_ruleset/midround/heavy_ruleset = pick_weight(possible_heavies)
		log_dynamic_and_announce("An unfavorable situation was requested, spawning [initial(heavy_ruleset.name)]")
		picking_specific_rule(heavy_ruleset, forced = TRUE, ignore_cost = TRUE)
