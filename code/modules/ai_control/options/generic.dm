/// Generic role pack providing placeholder macro-options until specialist packs land.

/datum/ai_option_role/generic
	id = "generic"
	display_name = "Generic Crew Toolkit"

/datum/ai_option_role/generic/on_registered()
	add_option(new /datum/ai_option/generic/hold_position)
	add_option(new /datum/ai_option/generic/patrol_zone)
	add_option(new /datum/ai_option/generic/call_for_help)


/datum/ai_option/generic/hold_position
	id = "hold_position"
	display_name = "Hold Position"
	category = AI_ACTION_CATEGORY_SUPPORT
	priority = 4
	timeout_ds = 60

/datum/ai_option/generic/hold_position/New()
	..()
	default_args = list("mode" = "hold")

/datum/ai_option/generic/hold_position/compute_score(datum/ai_context_snapshot/snapshot, datum/ai_control_policy/policy)
	var/score = priority
	if(blackboard && blackboard.get_confidence() < 0.5)
		score += 0.5
	return score


/datum/ai_option/generic/patrol_zone
	id = "patrol_zone"
	display_name = "Patrol Current Zone"
	category = AI_ACTION_CATEGORY_ROUTINE
	priority = 5
	timeout_ds = 80

/datum/ai_option/generic/patrol_zone/New()
	..()
	default_args = list("mode" = "patrol")

/datum/ai_option/generic/patrol_zone/precond(datum/ai_context_snapshot/snapshot)
	if(!..(snapshot))
		return FALSE
	return !!blackboard?.get_zone()

/datum/ai_option/generic/patrol_zone/compute_score(datum/ai_context_snapshot/snapshot, datum/ai_control_policy/policy)
	var/score = priority
	if(blackboard)
		var/list/path = blackboard.get_path()
		if(!length(path))
			score += 0.25
	return score

/datum/ai_option/generic/patrol_zone/get_metadata(datum/ai_context_snapshot/snapshot)
	return list("zone" = blackboard?.get_zone())


/datum/ai_option/generic/call_for_help
	id = "call_for_help"
	display_name = "Call For Help"
	category = AI_ACTION_CATEGORY_SUPPORT
	priority = 6
	timeout_ds = 40

/datum/ai_option/generic/call_for_help/New()
	..()
	default_args = list("mode" = "radio_burst")

/datum/ai_option/generic/call_for_help/precond(datum/ai_context_snapshot/snapshot)
	if(!..(snapshot))
		return FALSE
	var/list/alerts = blackboard?.get_recent_alerts()
	return length(alerts) > 0

/datum/ai_option/generic/call_for_help/compute_score(datum/ai_context_snapshot/snapshot, datum/ai_control_policy/policy)
	var/score = priority
	if(policy)
		var/multiplier = policy.get_category_multiplier(category, null)
		if(isnum(multiplier))
			score *= multiplier
	return score

/datum/ai_option/generic/call_for_help/get_metadata(datum/ai_context_snapshot/snapshot)
	return list("recent_alerts" = clamp(length(blackboard?.get_recent_alerts()), 0, AI_BLACKBOARD_ALERT_EVENT_LIMIT))

