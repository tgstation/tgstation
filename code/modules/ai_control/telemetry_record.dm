/// Represents a single decision node recorded for administrator auditing.

/datum/ai_decision_telemetry
	var/profile_id
	var/sequence_id
	var/list/candidate_actions
	var/selected_action
	var/exploration_bonus = 0
	var/rollout_count = 0
	var/result
	var/notes
	var/created_at = 0
	var/created_at_tick = 0

	var/datum/ai_decision_telemetry/prev_entry
	var/datum/ai_decision_telemetry/next_entry

/datum/ai_decision_telemetry/New(profile_id, sequence_id, list/candidate_actions = null, selected_action = null, exploration_bonus = 0, rollout_count = 0, result = null, notes = null)
	..()
	src.profile_id = profile_id
	src.sequence_id = sequence_id
	created_at = world.timeofday
	created_at_tick = world.time
	set_candidate_actions(candidate_actions)
	set_selected_action(selected_action)
	set_exploration_bonus(exploration_bonus)
	set_rollout_count(rollout_count)
	src.result = result
	src.notes = notes

/datum/ai_decision_telemetry/proc/set_candidate_actions(list/actions)
	if(!islist(actions))
		candidate_actions = list()
		return

	var/list/sanitized = list()
	for(var/index in 1 to actions.len)
		var/list/entry = sanitize_candidate(actions[index])
		sanitized += list(entry)

	candidate_actions = sanitized

/datum/ai_decision_telemetry/proc/append_candidate_action(list/action)
	if(!candidate_actions)
		candidate_actions = list()
	candidate_actions += list(sanitize_candidate(action))

/datum/ai_decision_telemetry/proc/sanitize_candidate(list/action)
	var/list/sanitized = list()
	sanitized["verb"] = action?["verb"]
	sanitized["Q"] = isnum(action?["Q"]) ? action["Q"] : null
	sanitized["prior"] = isnum(action?["prior"]) ? action["prior"] : null
	var/visit_count = action?["visit_count"]
	if(!isnum(visit_count))
		visit_count = 0
	sanitized["visit_count"] = max(0, round(visit_count))
	return sanitized

/datum/ai_decision_telemetry/proc/set_selected_action(value)
	selected_action = value

/datum/ai_decision_telemetry/proc/set_exploration_bonus(value)
	if(!isnum(value))
		value = 0
	exploration_bonus = clamp(value, -AI_CONTROL_EXPLORATION_BONUS_MAX, AI_CONTROL_EXPLORATION_BONUS_MAX)

/datum/ai_decision_telemetry/proc/set_rollout_count(value)
	if(!isnum(value))
		value = 0
	rollout_count = clamp(round(value), 0, AI_CONTROL_DEFAULT_MAX_ROLLOUTS)

/datum/ai_decision_telemetry/proc/link_after(datum/ai_decision_telemetry/previous)
	prev_entry = previous
	if(previous)
		previous.next_entry = src

/datum/ai_decision_telemetry/proc/unlink()
	if(prev_entry)
		prev_entry.next_entry = next_entry
	if(next_entry)
		next_entry.prev_entry = prev_entry
	prev_entry = null
	next_entry = null

/datum/ai_decision_telemetry/proc/to_list()
	return list(
		"profile_id" = profile_id,
		"sequence_id" = sequence_id,
		"candidate_actions" = candidate_actions?.Copy(),
		"selected_action" = selected_action,
		"exploration_bonus" = exploration_bonus,
		"rollout_count" = rollout_count,
		"result" = result,
		"notes" = notes,
		"created_at" = created_at,
		"created_at_tick" = created_at_tick,
	)
