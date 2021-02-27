#define ADMIN_CANCEL_MIDROUND_TIME (10 SECONDS)

/// From a list of rulesets, returns one based on weight and availability.
/// Mutates the list that is passed into it to remove invalid rules.
/datum/game_mode/dynamic/proc/pick_ruleset(list/drafted_rules)
	if (only_ruleset_executed)
		return null

	while (TRUE)
		var/datum/dynamic_ruleset/rule = pickweight(drafted_rules)
		if (!rule)
			return null

		if (check_blocking(rule.blocking_rules, executed_rules))
			drafted_rules -= rule
			if(drafted_rules.len <= 0)
				return null
			continue
		else if (
			rule.flags & HIGH_IMPACT_RULESET \
			&& threat_level < GLOB.dynamic_stacking_limit \
			&& GLOB.dynamic_no_stacking \
			&& high_impact_ruleset_executed \
		)
			drafted_rules -= rule
			if(drafted_rules.len <= 0)
				return null
			continue

		return rule

/// Executes a random midround ruleset from the list of drafted rules.
/datum/game_mode/dynamic/proc/pick_midround_rule(list/drafted_rules)
	var/datum/dynamic_ruleset/rule = pick_ruleset(drafted_rules)
	if (isnull(rule))
		return
	if (!rule.repeatable)
		midround_rules = remove_from_list(midround_rules, rule.type)
	addtimer(CALLBACK(src, /datum/game_mode/dynamic/.proc/execute_midround_latejoin_rule, rule), rule.delay)

/// Executes a random latejoin ruleset from the list of drafted rules.
/datum/game_mode/dynamic/proc/pick_latejoin_rule(list/drafted_rules)
	var/datum/dynamic_ruleset/rule = pick_ruleset(drafted_rules)
	if (isnull(rule))
		return
	if (!rule.repeatable)
		latejoin_rules = remove_from_list(latejoin_rules, rule.type)
	addtimer(CALLBACK(src, /datum/game_mode/dynamic/.proc/execute_midround_latejoin_rule, rule), rule.delay)

/// Mainly here to facilitate delayed rulesets. All midround/latejoin rulesets are executed with a timered callback to this proc.
/datum/game_mode/dynamic/proc/execute_midround_latejoin_rule(sent_rule)
	var/datum/dynamic_ruleset/rule = sent_rule
	spend_midround_budget(rule.cost)
	threat_log += "[worldtime2text()]: [rule.ruletype] [rule.name] spent [rule.cost]"
	rule.pre_execute(current_players[CURRENT_LIVING_PLAYERS].len)
	if (rule.execute())
		log_game("DYNAMIC: Injected a [rule.ruletype == "latejoin" ? "latejoin" : "midround"] ruleset [rule.name].")
		if(rule.flags & HIGH_IMPACT_RULESET)
			high_impact_ruleset_executed = TRUE
		else if(rule.flags & ONLY_RULESET)
			only_ruleset_executed = TRUE
		if(rule.ruletype == "Latejoin")
			var/mob/M = pick(rule.candidates)
			message_admins("[key_name(M)] joined the station, and was selected by the [rule.name] ruleset.")
			log_game("DYNAMIC: [key_name(M)] joined the station, and was selected by the [rule.name] ruleset.")
		executed_rules += rule
		rule.candidates.Cut()
		if (rule.persistent)
			current_rules += rule
		new_snapshot(rule)
		return TRUE
	rule.clean_up()
	stack_trace("The [rule.ruletype] rule \"[rule.name]\" failed to execute.")
	return FALSE

#undef ADMIN_CANCEL_MIDROUND_TIME
