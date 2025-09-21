/// Represents the runtime state for an AI-controlled human crew member.

/datum/ai_crew_profile
	/// Weak reference to the controlled mob.
	var/datum/weakref/mob_ref
	/// Cached job identifier for telemetry/role routing.
	var/job_id
	/// Collection of duty objectives the profile should cycle through.
	var/list/duty_objectives = list()
	/// Per-category exploration multipliers (copy of policy defaults with per-profile tuning).
	var/list/action_taxonomy_weights = list()
	/// Behavioral risk tolerance flag.
	var/risk_tolerance = AI_RISK_TOLERANCE_NORMAL
	/// Bitfield tracking activation/player override/emergency lockdown.
	var/status_flags = 0
	/// Last action metadata (`verb`, `result`, `timestamp`, optional `notes`).
	var/list/last_action
	/// FIFO queue for administrator or player-issued orders.
	var/list/pending_orders = list()
	/// Reference to the active control policy (for config lookups).
	var/datum/ai_control_policy/policy
	/// Sequence counter used when emitting telemetry records.
	var/decision_sequence = 0
	/// Last execution timestamps for rate-limited metrics.
	var/list/rate_limit_timestamps = list()

/datum/ai_crew_profile/New(mob/living/carbon/human/target, datum/ai_control_policy/policy, risk_tolerance = AI_RISK_TOLERANCE_NORMAL)
	..()
	src.policy = policy
	set_mob(target)
	set_risk_tolerance(risk_tolerance)
	refresh_action_taxonomy()
	refresh_job_id()
	refresh_duty_objectives()
	rate_limit_timestamps = list()
	status_flags = AI_CREW_STATUS_ACTIVE

/// Resolve the weak reference into a mob (if still valid).
/datum/ai_crew_profile/proc/get_mob()
	return mob_ref?.resolve()

/// Assign the controlled mob, storing a weak reference.
/datum/ai_crew_profile/proc/set_mob(mob/living/carbon/human/target)
	if(target)
		mob_ref = WEAKREF(target)
	else
		mob_ref = null
	refresh_job_id()
	return mob_ref

/// Update cached job identifier from the current mob/mind state.
/datum/ai_crew_profile/proc/refresh_job_id()
	var/mob/living/carbon/human/crew = get_mob()
	if(!crew)
		job_id = null
		return

	var/datum/mind/mind = crew.mind
	if(mind?.assigned_role)
		var/datum/job/role = mind.assigned_role
		job_id = role?.title || "[role?.type]"
		return

	if(istext(crew.job))
		job_id = crew.job
	else
		job_id = null

/// Return the cached job identifier.
/datum/ai_crew_profile/proc/get_job_id()
	return job_id

/// Copy policy defaults (or constants) into the per-profile multiplier map.
/datum/ai_crew_profile/proc/refresh_action_taxonomy()
	action_taxonomy_weights = list()
	var/list/defaults = policy?.action_category_defaults?.Copy()
	if(!islist(defaults))
		defaults = GLOB.ai_control_default_multipliers?.Copy()
	if(!islist(defaults))
		defaults = list()

	for(var/category in GLOB.ai_control_action_categories)
		var/value = defaults?[category]
		if(!isnum(value))
			value = 1
		action_taxonomy_weights[category] = max(0.1, value)

/// Refresh objectives — placeholder ensures list is present, to be populated when job sources are wired.
/datum/ai_crew_profile/proc/refresh_duty_objectives()
	duty_objectives = list()

/// Append a new objective.
/datum/ai_crew_profile/proc/add_duty_objective(datum/ai_duty_objective/objective)
	if(!objective)
		return
	duty_objectives += objective

/datum/ai_crew_profile/proc/clear_duty_objectives()
	duty_objectives = list()

/// Risk tolerance setter with validation.
/datum/ai_crew_profile/proc/set_risk_tolerance(value)
	if(value in list(AI_RISK_TOLERANCE_CAUTIOUS, AI_RISK_TOLERANCE_NORMAL, AI_RISK_TOLERANCE_ASSERTIVE))
		risk_tolerance = value
	else
		risk_tolerance = AI_RISK_TOLERANCE_NORMAL
	return risk_tolerance

/datum/ai_crew_profile/proc/get_risk_tolerance()
	return risk_tolerance

/// Retrieve the exploration multiplier for an action category, factoring alert scaling.
/datum/ai_crew_profile/proc/get_action_multiplier(category, alert_level)
	var/base = action_taxonomy_weights?[category]
	if(!isnum(base))
		base = 1
	var/scale = policy ? policy.get_alert_scale(alert_level) : 1
	return max(0.1, base) * scale

/datum/ai_crew_profile/proc/set_action_multiplier(category, value)
	if(!action_taxonomy_weights)
		action_taxonomy_weights = list()
	if(!(category in GLOB.ai_control_action_categories))
		return
	if(!isnum(value))
		return
	action_taxonomy_weights[category] = max(0.1, value)

/// Update multipliers from policy defaults when administrators change config at runtime.
/datum/ai_crew_profile/proc/on_policy_updated(datum/ai_control_policy/new_policy)
	policy = new_policy
	refresh_action_taxonomy()

/// Mark profile as active.
/datum/ai_crew_profile/proc/activate()
	set_status(AI_CREW_STATUS_ACTIVE, TRUE)

/// Mark profile as inactive (but do not drop ownership yet).
/datum/ai_crew_profile/proc/deactivate()
	set_status(AI_CREW_STATUS_ACTIVE, FALSE)

/datum/ai_crew_profile/proc/set_player_override(state = TRUE)
	set_status(AI_CREW_STATUS_PLAYER_OVERRIDE, state)
	if(state)
		clear_pending_orders()

/datum/ai_crew_profile/proc/set_emergency_lockdown(state = TRUE)
	set_status(AI_CREW_STATUS_EMERGENCY_LOCKDOWN, state)

/datum/ai_crew_profile/proc/has_status(flag)
	return !!(status_flags & flag)

/datum/ai_crew_profile/proc/set_status(flag, state = TRUE)
	if(state)
		status_flags |= flag
	else
		status_flags &= ~flag
	return status_flags

/datum/ai_crew_profile/proc/is_active()
	return has_status(AI_CREW_STATUS_ACTIVE) && (isnull(policy) || policy.enabled)

/datum/ai_crew_profile/proc/is_under_player_override()
	return has_status(AI_CREW_STATUS_PLAYER_OVERRIDE)

/// Queue a new order at the tail.
/datum/ai_crew_profile/proc/enqueue_order(order)
	if(isnull(order))
		return
	if(!pending_orders)
		pending_orders = list()
	pending_orders += list(order)

/datum/ai_crew_profile/proc/dequeue_order()
	if(!pending_orders || !pending_orders.len)
		return null
	var/order = pending_orders[1]
	pending_orders.Cut(1, 2)
	return order

/datum/ai_crew_profile/proc/clear_pending_orders()
	if(pending_orders)
		pending_orders.Cut()
	else
		pending_orders = list()

/datum/ai_crew_profile/proc/has_pending_orders()
	return !!(pending_orders && pending_orders.len)

/// Capture metadata about the most recent action for telemetry/debugging.
/datum/ai_crew_profile/proc/record_action(verb, result = null, notes = null)
	last_action = list(
		"verb" = verb,
		"result" = result,
		"timestamp" = world.time,
		"notes" = notes,
	)

/datum/ai_crew_profile/proc/clear_last_action()
	last_action = null

/datum/ai_crew_profile/proc/get_last_action()
	return last_action

/datum/ai_crew_profile/proc/get_policy()
	return policy

/datum/ai_crew_profile/proc/get_rate_limit_seconds(metric, default_value = 0)
	if(policy)
		return policy.get_rate_limit_seconds(metric, default_value)
	return default_value

/datum/ai_crew_profile/proc/is_rate_limited(metric, current_time = world.time)
	var/limit_seconds = get_rate_limit_seconds(metric)
	if(limit_seconds <= 0)
		return FALSE
	var/last = rate_limit_timestamps?[metric]
	if(isnull(last))
		return FALSE
	return (current_time - last) < round(limit_seconds * 10)

/datum/ai_crew_profile/proc/mark_rate_usage(metric, current_time = world.time)
	if(!rate_limit_timestamps)
		rate_limit_timestamps = list()
	rate_limit_timestamps[metric] = current_time

/datum/ai_crew_profile/proc/next_sequence_id()
	decision_sequence++
	return decision_sequence

/datum/ai_crew_profile/proc/can_plan()
	if(policy && !policy.enabled)
		return FALSE
	if(is_under_player_override())
		return FALSE
	return !!get_mob()

/datum/ai_crew_profile/proc/to_list()
	return list(
		"mob" = get_mob(),
		"job_id" = job_id,
		"risk_tolerance" = risk_tolerance,
		"status_flags" = status_flags,
		"pending_orders" = pending_orders?.Copy(),
		"action_taxonomy_weights" = action_taxonomy_weights?.Copy(),
		"last_action" = last_action?.Copy(),
	)
