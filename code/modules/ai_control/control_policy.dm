/// Runtime configuration for the AI control foundation. Loads defaults from JSON config
/// and exposes helper APIs for exploration scaling, safety thresholds, and rate limits.

/datum/ai_control_policy
	/// Whether the foundation is currently enabled.
	var/enabled = TRUE
	/// Evaluation cadence in seconds.
	var/cadence_seconds = AI_CONTROL_DEFAULT_CADENCE
	/// Rollout cap per planning cycle.
	var/max_rollouts_per_cycle = AI_CONTROL_DEFAULT_MAX_ROLLOUTS
	/// Outstanding task queue limit per profile.
	var/task_queue_limit = AI_CONTROL_DEFAULT_TASK_QUEUE_LIMIT
	/// Rolling in-memory telemetry retention in minutes.
	var/telemetry_retention_minutes = AI_CONTROL_DEFAULT_TELEMETRY_MINUTES

	var/list/action_category_defaults
	var/list/emergency_modifiers
	var/list/safety_thresholds
	var/list/rate_limits
	var/list/telemetry
	var/list/reservation

	/// Cached snapshot of the most recent config blob.
	var/list/last_loaded_snapshot
	/// Config source path (overridable for tests).
	var/source_path = AI_CONTROL_CONFIG_PATH

/datum/ai_control_policy/New(list/config_override)
	..()
	reset_to_defaults()
	if(islist(config_override))
		apply_config(config_override)
	else
		load_from_file()
	enforce_constraints()

/// Reset policy values to built-in defaults prior to applying overrides.
/datum/ai_control_policy/proc/reset_to_defaults()
	enabled = TRUE
	cadence_seconds = AI_CONTROL_DEFAULT_CADENCE
	max_rollouts_per_cycle = AI_CONTROL_DEFAULT_MAX_ROLLOUTS
	task_queue_limit = AI_CONTROL_DEFAULT_TASK_QUEUE_LIMIT
	telemetry_retention_minutes = AI_CONTROL_DEFAULT_TELEMETRY_MINUTES

	action_category_defaults = GLOB.ai_control_default_multipliers?.Copy() || list()
	emergency_modifiers = list(
		"blue" = 0.85,
		"red" = 0.7,
		"delta" = 0.6,
	)
	safety_thresholds = list(
		"max_hazard_score" = AI_CONTROL_DEFAULT_MAX_HAZARD,
		"max_chain_failures" = AI_CONTROL_DEFAULT_MAX_CHAIN_FAILURES,
	)
	rate_limits = list(
		"item_toggle_seconds" = AI_CONTROL_DEFAULT_ITEM_TOGGLE_RATE,
		"aggressive_action_seconds" = AI_CONTROL_DEFAULT_AGGRESSIVE_RATE,
	)
	telemetry = list(
		"rolling_window_minutes" = AI_CONTROL_DEFAULT_TELEMETRY_MINUTES,
		"persistence_hours" = 24,
	)
	reservation = list(
		"default_expiry_seconds" = AI_CONTROL_DEFAULT_RESERVATION_SECONDS,
		"retry_delay_seconds" = AI_CONTROL_DEFAULT_RESERVATION_RETRY_SECONDS,
	)
	last_loaded_snapshot = null

/// Attempt to load config overrides from disk.
/datum/ai_control_policy/proc/load_from_file(path)
	var/target_path = path || source_path
	if(!fexists(target_path))
		return FALSE

	var/raw = file2text(target_path)
	if(!length(raw))
		return FALSE

	var/list/decoded = safe_json_decode(raw)
	if(!islist(decoded))
		log_world("[src]: unable to parse JSON config [target_path]")
		return FALSE

	apply_config(decoded)
	last_loaded_snapshot = decoded.Copy()
	return TRUE

/// Apply overrides from a decoded JSON blob or manual list.
/datum/ai_control_policy/proc/apply_config(list/config)
	if("ai_control_enabled" in config)
		enabled = !!config["ai_control_enabled"]

	if(isnum(config["cadence_seconds"]))
		cadence_seconds = max(0.1, config["cadence_seconds"])

	if(isnum(config["max_rollouts_per_cycle"]))
		max_rollouts_per_cycle = max(1, round(config["max_rollouts_per_cycle"]))

	if(isnum(config["task_queue_limit"]))
		task_queue_limit = max(1, round(config["task_queue_limit"]))

	if(islist(config["exploration_multipliers"]))
		apply_category_defaults(config["exploration_multipliers"])

	if(islist(config["emergency_modifiers"]))
		emergency_modifiers = config["emergency_modifiers"].Copy()

	if(islist(config["safety_thresholds"]))
		safety_thresholds = config["safety_thresholds"].Copy()

	if(islist(config["rate_limits"]))
		rate_limits = config["rate_limits"].Copy()

	if(islist(config["telemetry"]))
		telemetry = config["telemetry"].Copy()

	if(islist(config["reservation"]))
		reservation = config["reservation"].Copy()

	if(isnum(config["telemetry_retention_minutes"]))
		telemetry_retention_minutes = config["telemetry_retention_minutes"]

	else if(islist(telemetry) && isnum(telemetry["rolling_window_minutes"]))
		telemetry_retention_minutes = telemetry["rolling_window_minutes"]

	enforce_constraints()

/// Ensure configured values stay within documented bounds.
/datum/ai_control_policy/proc/enforce_constraints()
	telemetry_retention_minutes = clamp(round(telemetry_retention_minutes), AI_CONTROL_MIN_TELEMETRY_MINUTES, AI_CONTROL_MAX_TELEMETRY_MINUTES)

	if(action_category_defaults)
		for(var/category in GLOB.ai_control_action_categories)
			var/value = action_category_defaults[category]
			if(!isnum(value))
				action_category_defaults[category] = GLOB.ai_control_default_multipliers[category]
			else
				action_category_defaults[category] = max(0.1, value)

		if(action_category_defaults[AI_ACTION_CATEGORY_SECURITY] > 1)
			action_category_defaults[AI_ACTION_CATEGORY_SECURITY] = 1

	if(max_rollouts_per_cycle > AI_CONTROL_DEFAULT_MAX_ROLLOUTS)
		max_rollouts_per_cycle = AI_CONTROL_DEFAULT_MAX_ROLLOUTS

	if(task_queue_limit < 1)
		task_queue_limit = 1

	if(!islist(emergency_modifiers))
		emergency_modifiers = list("blue" = 0.85, "red" = 0.7, "delta" = 0.6)

	if(!islist(safety_thresholds))
		safety_thresholds = list("max_hazard_score" = AI_CONTROL_DEFAULT_MAX_HAZARD, "max_chain_failures" = AI_CONTROL_DEFAULT_MAX_CHAIN_FAILURES)

	if(!islist(rate_limits))
		rate_limits = list("item_toggle_seconds" = AI_CONTROL_DEFAULT_ITEM_TOGGLE_RATE, "aggressive_action_seconds" = AI_CONTROL_DEFAULT_AGGRESSIVE_RATE)

	if(!islist(telemetry))
		telemetry = list("rolling_window_minutes" = telemetry_retention_minutes, "persistence_hours" = 24)

	if(!islist(reservation))
		reservation = list("default_expiry_seconds" = AI_CONTROL_DEFAULT_RESERVATION_SECONDS, "retry_delay_seconds" = AI_CONTROL_DEFAULT_RESERVATION_RETRY_SECONDS)

/// Internal helper to merge exploration multipliers with defaults.
/datum/ai_control_policy/proc/apply_category_defaults(list/source)
	var/list/new_defaults = list()
	for(var/category in GLOB.ai_control_action_categories)
		var/value = source[category]
		if(!isnum(value))
			value = GLOB.ai_control_default_multipliers[category]
		new_defaults[category] = max(0.1, value)
	action_category_defaults = new_defaults

/// Return exploration multiplier for a category after alert scaling.
/datum/ai_control_policy/proc/get_category_multiplier(category, alert_level)
	var/base = action_category_defaults?[category]
	if(!isnum(base))
		base = 1

	return base * get_alert_scale(alert_level)

/// Obtain the scale multiplier for a given alert level.
/datum/ai_control_policy/proc/get_alert_scale(alert_level)
	if(!alert_level)
		return 1
	var/scale = emergency_modifiers?[alert_level]
	if(!isnum(scale))
		return 1
	return max(scale, 0)

/datum/ai_control_policy/proc/get_rate_limit_seconds(metric, default_value)
	var/value = rate_limits?[metric]
	if(!isnum(value))
		return default_value
	return max(value, 0)

/datum/ai_control_policy/proc/get_reservation_seconds(metric, default_value)
	var/value = reservation?[metric]
	if(!isnum(value))
		return default_value
	return max(value, 0)

/datum/ai_control_policy/proc/get_safety_threshold(metric, default_value)
	var/value = safety_thresholds?[metric]
	if(!isnum(value))
		return default_value
	return value

/datum/ai_control_policy/proc/get_rollout_cap()
	return max_rollouts_per_cycle

/datum/ai_control_policy/proc/get_cadence()
	return cadence_seconds

/datum/ai_control_policy/proc/get_task_queue_limit()
	return task_queue_limit

/datum/ai_control_policy/proc/get_telemetry_window_minutes()
	return telemetry_retention_minutes

/datum/ai_control_policy/proc/to_list()
	return list(
		"enabled" = enabled,
		"cadence_seconds" = cadence_seconds,
		"max_rollouts_per_cycle" = max_rollouts_per_cycle,
		"task_queue_limit" = task_queue_limit,
		"telemetry_retention_minutes" = telemetry_retention_minutes,
		"action_category_defaults" = action_category_defaults?.Copy(),
		"emergency_modifiers" = emergency_modifiers?.Copy(),
		"safety_thresholds" = safety_thresholds?.Copy(),
		"rate_limits" = rate_limits?.Copy(),
		"telemetry" = telemetry?.Copy(),
		"reservation" = reservation?.Copy(),
	)
