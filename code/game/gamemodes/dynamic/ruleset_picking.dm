#define ADMIN_CANCEL_MIDROUND_TIME (10 SECONDS)

/// From a list of rulesets, returns one based on weight and availability.
/// Mutates the list that is passed into it to remove invalid rules.
/datum/game_mode/dynamic/proc/pick_ruleset(list/drafted_rules)
	if (only_ruleset_executed)
		log_dynamic("FAIL: only_ruleset_executed")
		return null

	while (TRUE)
		var/datum/dynamic_ruleset/rule = pick_weight(drafted_rules)
		if (!rule)
			var/list/leftover_rules = list()
			for (var/leftover_rule in drafted_rules)
				leftover_rules += "[leftover_rule]"

			log_dynamic("FAIL: No rulesets left to pick. Leftover rules: [leftover_rules.Join(", ")]")

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
			log_dynamic("FAIL: [rule] can't execute as a high impact ruleset was already executed.")
			drafted_rules -= rule
			if(drafted_rules.len <= 0)
				return null
			continue

		return rule

/// Executes a random midround ruleset from the list of drafted rules.
/datum/game_mode/dynamic/proc/pick_midround_rule(list/drafted_rules, description)
	log_dynamic("Rolling [drafted_rules.len] [description]")

	var/datum/dynamic_ruleset/rule = pick_ruleset(drafted_rules)
	if (isnull(rule))
		return null

	current_midround_rulesets = drafted_rules - rule

	midround_injection_timer_id = addtimer(
		CALLBACK(src, .proc/execute_midround_rule, rule), \
		ADMIN_CANCEL_MIDROUND_TIME, \
		TIMER_STOPPABLE, \
	)

	log_dynamic("[rule] ruleset executing...")
	message_admins("DYNAMIC: Executing midround ruleset [rule] in [DisplayTimeText(ADMIN_CANCEL_MIDROUND_TIME)]. \
		<a href='?src=[REF(src)];cancelmidround=[midround_injection_timer_id]'>CANCEL</a> | \
		<a href='?src=[REF(src)];differentmidround=[midround_injection_timer_id]'>SOMETHING ELSE</a>")

	return rule

/// Fired after admins do not cancel a midround injection.
/datum/game_mode/dynamic/proc/execute_midround_rule(datum/dynamic_ruleset/rule)
	current_midround_rulesets = null
	midround_injection_timer_id = null
	if (!rule.repeatable)
		midround_rules = remove_from_list(midround_rules, rule.type)
	addtimer(CALLBACK(src, .proc/execute_midround_latejoin_rule, rule), rule.delay)

/// Executes a random latejoin ruleset from the list of drafted rules.
/datum/game_mode/dynamic/proc/pick_latejoin_rule(list/drafted_rules)
	var/datum/dynamic_ruleset/rule = pick_ruleset(drafted_rules)
	if (isnull(rule))
		return
	if (!rule.repeatable)
		latejoin_rules = remove_from_list(latejoin_rules, rule.type)
	addtimer(CALLBACK(src, .proc/execute_midround_latejoin_rule, rule), rule.delay)
	return TRUE

/// Mainly here to facilitate delayed rulesets. All midround/latejoin rulesets are executed with a timered callback to this proc.
/datum/game_mode/dynamic/proc/execute_midround_latejoin_rule(sent_rule)
	var/datum/dynamic_ruleset/rule = sent_rule
	spend_midround_budget(rule.cost, threat_log, "[worldtime2text()]: [rule.ruletype] [rule.name]")
	rule.pre_execute(GLOB.alive_player_list.len)
	if (rule.execute())
		log_dynamic("Injected a [rule.ruletype == "latejoin" ? "latejoin" : "midround"] ruleset [rule.name].")
		if(rule.flags & HIGH_IMPACT_RULESET)
			high_impact_ruleset_executed = TRUE
		else if(rule.flags & ONLY_RULESET)
			only_ruleset_executed = TRUE
		if(rule.ruletype == "Latejoin")
			var/mob/M = pick(rule.candidates)
			message_admins("[key_name(M)] joined the station, and was selected by the [rule.name] ruleset.")
			log_dynamic("[key_name(M)] joined the station, and was selected by the [rule.name] ruleset.")
		executed_rules += rule
		rule.candidates.Cut()
		if (rule.persistent)
			current_rules += rule
		new_snapshot(rule)
		return TRUE
	rule.clean_up()
	stack_trace("The [rule.ruletype] rule \"[rule.name]\" failed to execute.")
	return FALSE

/// Fired when an admin cancels the current midround injection.
/datum/game_mode/dynamic/proc/admin_cancel_midround(mob/user, timer_id)
	if (midround_injection_timer_id != timer_id || !deltimer(midround_injection_timer_id))
		to_chat(user, span_notice("Too late!"))
		return

	log_admin("[key_name(user)] cancelled the next midround injection.")
	message_admins("[key_name(user)] cancelled the next midround injection.")
	midround_injection_timer_id = null
	current_midround_rulesets = null

/// Fired when an admin requests a different midround injection.
/datum/game_mode/dynamic/proc/admin_different_midround(mob/user, timer_id)
	if (midround_injection_timer_id != timer_id || !deltimer(midround_injection_timer_id))
		to_chat(user, span_notice("Too late!"))
		return

	midround_injection_timer_id = null

	if (isnull(current_midround_rulesets) || current_midround_rulesets.len == 0)
		log_admin("[key_name(user)] asked for a different midround injection, but there were none left.")
		message_admins("[key_name(user)] asked for a different midround injection, but there were none left.")
		return

	log_admin("[key_name(user)] asked for a different midround injection.")
	message_admins("[key_name(user)] asked for a different midround injection.")
	pick_midround_rule(current_midround_rulesets, "different midround rulesets")

#undef ADMIN_CANCEL_MIDROUND_TIME
