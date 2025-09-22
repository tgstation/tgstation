/// Telemetry manager buffers decision records in memory, applies retention limits
/// from the active policy, and prepares batched inserts for SSdbcore.

/datum/ai_telemetry_manager
	/// Owning subsystem.
	var/datum/controller/subsystem/ai/owner
	/// Profile → list of /datum/ai_decision_telemetry in chronological order.
	var/list/profile_buffers = list()
	/// Profile → highest sequence id observed.
	var/list/profile_sequences = list()
	/// Pending SQL row payloads awaiting SSdbcore batching.
	var/list/pending_rows = list()
	/// Cached retention window in deciseconds.
	var/retention_window_ds = AI_CONTROL_DEFAULT_TELEMETRY_MINUTES * 600

/datum/ai_telemetry_manager/New(datum/controller/subsystem/ai/new_owner)
	owner = new_owner
	sync_from_policy(owner?.get_policy())
	return ..()

/// Synchronize retention window using the active control policy.
/datum/ai_telemetry_manager/proc/sync_from_policy(datum/ai_control_policy/policy)
	if(!policy)
		return
	var/minutes = clamp(round(policy.get_telemetry_window_minutes()), AI_CONTROL_MIN_TELEMETRY_MINUTES, AI_CONTROL_MAX_TELEMETRY_MINUTES)
	var/new_window = minutes * 600
	if(new_window == retention_window_ds)
		return
	retention_window_ds = new_window
	prune_all()

/datum/ai_telemetry_manager/proc/get_retention_window_ds()
	return retention_window_ds

/// Append a telemetry record for the supplied profile.
/// `record_data` may contain:
///   candidate_actions, selected_action, exploration_bonus, rollout_count, result, notes, sequence_id
/datum/ai_telemetry_manager/proc/record_decision(profile_id, job_id, action_category, list/record_data)
	if(!istext(profile_id) || !length(profile_id))
		return null
	if(!islist(record_data))
		record_data = list()

	var/sequence_id = record_data["sequence_id"]
	if(!isnum(sequence_id))
		sequence_id = next_sequence_id(profile_id)
	else
		sequence_id = max(1, round(sequence_id))
	profile_sequences[profile_id] = max(sequence_id, profile_sequences?[profile_id] || 0)

	var/list/candidates = record_data["candidate_actions"]
	var/selected_action = record_data["selected_action"]
	var/exploration_bonus = record_data["exploration_bonus"]
	var/rollout_count = record_data["rollout_count"]
	var/result = record_data["result"]
	var/notes = record_data["notes"]

	var/datum/ai_decision_telemetry/entry = new /datum/ai_decision_telemetry(
		profile_id,
		sequence_id,
		candidates,
		selected_action,
		exploration_bonus,
		rollout_count,
		result,
		notes,
	)

	append_profile_entry(profile_id, entry)
	prune_profile(profile_id)
	queue_row(profile_id, job_id, action_category, entry, record_data)
	return entry

/datum/ai_telemetry_manager/proc/append_profile_entry(profile_id, datum/ai_decision_telemetry/entry)
	if(!profile_buffers)
		profile_buffers = list()
	var/list/buffer = profile_buffers[profile_id]
	if(!islist(buffer))
		buffer = list()
	if(buffer.len)
		var/datum/ai_decision_telemetry/previous = buffer[buffer.len]
		if(previous)
			entry.link_after(previous)
	buffer += entry
	profile_buffers[profile_id] = buffer

/datum/ai_telemetry_manager/proc/prune_profile(profile_id)
	if(!profile_buffers)
		return
	var/list/buffer = profile_buffers[profile_id]
	if(!islist(buffer) || !length(buffer))
		profile_buffers -= profile_id
		return

	var/cutoff = world.time - retention_window_ds
	var/changed = FALSE
	while(length(buffer))
		var/datum/ai_decision_telemetry/entry = buffer[1]
		if(!entry)
			buffer.Cut(1, 2)
			changed = TRUE
			continue
		if(entry.created_at_tick < cutoff)
			entry.unlink()
			buffer.Cut(1, 2)
			changed = TRUE
			continue
		break

	if(!length(buffer))
		profile_buffers -= profile_id
	else if(changed)
		profile_buffers[profile_id] = buffer

/datum/ai_telemetry_manager/proc/prune_all()
	if(!profile_buffers)
		return
	for(var/profile_id in profile_buffers.Copy())
		prune_profile(profile_id)

/datum/ai_telemetry_manager/proc/next_sequence_id(profile_id)
	if(!profile_sequences)
		profile_sequences = list()
	var/current = profile_sequences?[profile_id]
	if(!isnum(current))
		current = 0
	current++
	profile_sequences[profile_id] = current
	return current

/datum/ai_telemetry_manager/proc/get_recent_records(profile_id, limit = 0, as_lists = TRUE)
	var/list/buffer = profile_buffers?[profile_id]
	if(!islist(buffer) || !buffer.len)
		return list()

	var/start_index = 1
	if(limit > 0 && buffer.len > limit)
		start_index = buffer.len - limit + 1

	var/list/output = list()
	for(var/index in start_index to buffer.len)
		var/datum/ai_decision_telemetry/entry = buffer[index]
		if(!entry)
			continue
		output += list(as_lists ? entry.to_list() : entry)
	return output

/datum/ai_telemetry_manager/proc/get_pending_rows(limit = 0)
	if(!pending_rows || !pending_rows.len)
		return list()
	if(limit <= 0 || limit > pending_rows.len)
		limit = pending_rows.len
	var/list/batch = list()
	for(var/i in 1 to limit)
		batch += list(pending_rows[i])
	return batch

/datum/ai_telemetry_manager/proc/pop_pending_rows(limit = 50)
	if(!pending_rows || !pending_rows.len)
		return list()
	limit = clamp(round(limit), 1, pending_rows.len)
	var/list/batch = list()
	for(var/i in 1 to limit)
		batch += list(pending_rows[1])
		pending_rows.Cut(1, 2)
	return batch

/datum/ai_telemetry_manager/proc/has_pending_rows()
	return !!(pending_rows && pending_rows.len)

/datum/ai_telemetry_manager/proc/clear_profile(profile_id)
	if(!profile_buffers || !(profile_id in profile_buffers))
		return
	var/list/buffer = profile_buffers[profile_id]
	if(islist(buffer))
		for(var/datum/ai_decision_telemetry/entry as anything in buffer)
			if(entry)
				entry.unlink()
	profile_buffers -= profile_id
	profile_sequences -= profile_id

/datum/ai_telemetry_manager/proc/reset()
	if(profile_buffers)
		for(var/profile_id in profile_buffers)
			clear_profile(profile_id)
	profile_buffers = list()
	profile_sequences = list()
	pending_rows = list()

/datum/ai_telemetry_manager/proc/queue_row(profile_id, job_id, action_category, datum/ai_decision_telemetry/entry, list/record_data)
	if(!pending_rows)
		pending_rows = list()
	var/list/row = list(
		"round_id" = GLOB.round_id,
		"profile_id" = profile_id,
		"job_id" = job_id || "unknown",
		"action_category" = action_category || "unknown",
		"selected_action" = resolve_selected_action(entry.selected_action),
		"exploration_bonus" = entry.exploration_bonus,
		"rollout_count" = entry.rollout_count,
		"result" = sanitize_result(entry.result),
		"decision_epoch_ms" = to_epoch_ms(entry.created_at),
		"notes" = sanitize_notes(entry.notes),
	)
	if(islist(record_data?["db_overrides"]))
		row |= record_data["db_overrides"]
	pending_rows += list(row)

/datum/ai_telemetry_manager/proc/resolve_selected_action(value)
	if(istext(value))
		return value
	if(islist(value))
		if(istext(value["id"]))
			return value["id"]
		if(istext(value["verb"]))
			return value["verb"]
	return "unknown"

/datum/ai_telemetry_manager/proc/sanitize_result(value)
	if(!istext(value))
		return "partial"
	var/lower = lowertext(value)
	if(lower in list("success", "partial", "failure", "aborted"))
		return lower
	return "partial"

/datum/ai_telemetry_manager/proc/sanitize_notes(value)
	if(isnull(value))
		return null
	if(istext(value))
		return copytext(value, 1, 2048)
	return text("[value]")

/datum/ai_telemetry_manager/proc/to_epoch_ms(created_at_ds)
	if(!isnum(created_at_ds))
		created_at_ds = world.timeofday
	return round(created_at_ds * 100)

