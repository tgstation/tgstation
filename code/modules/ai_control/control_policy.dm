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
	var/list/gateway_config

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
	gateway_config = list(
		"planner" = list(
			"url" = AI_GATEWAY_DEFAULT_PLANNER_URL,
			"timeout_ds" = AI_GATEWAY_DEFAULT_TIMEOUT_DS,
		),
		"parser" = list(
			"url" = AI_GATEWAY_DEFAULT_PARSER_URL,
			"timeout_ds" = AI_GATEWAY_DEFAULT_TIMEOUT_DS,
		),
		"retry_ds" = AI_GATEWAY_DEFAULT_RETRY_DS,
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

	if(islist(config["gateway"]))
		apply_gateway_config(config["gateway"])

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

	if(!islist(gateway_config))
		reset_gateway_to_defaults()
	else
		enforce_gateway_constraints()

/// Reset gateway configuration to baked-in defaults.
/datum/ai_control_policy/proc/reset_gateway_to_defaults()
	gateway_config = list(
		"planner" = list(
			"url" = AI_GATEWAY_DEFAULT_PLANNER_URL,
			"timeout_ds" = AI_GATEWAY_DEFAULT_TIMEOUT_DS,
		),
		"parser" = list(
			"url" = AI_GATEWAY_DEFAULT_PARSER_URL,
			"timeout_ds" = AI_GATEWAY_DEFAULT_TIMEOUT_DS,
		),
		"retry_ds" = AI_GATEWAY_DEFAULT_RETRY_DS,
	)

/// Ensure gateway configuration adheres to safety bounds.
/datum/ai_control_policy/proc/enforce_gateway_constraints()
	if(!islist(gateway_config))
		reset_gateway_to_defaults()
		return

	for(var/channel in list("planner", "parser"))
		var/list/entry = gateway_config[channel]
		if(!islist(entry))
			gateway_config[channel] = list("url" = channel == "planner" ? AI_GATEWAY_DEFAULT_PLANNER_URL : AI_GATEWAY_DEFAULT_PARSER_URL, "timeout_ds" = AI_GATEWAY_DEFAULT_TIMEOUT_DS)
			continue
		if(!istext(entry["url"]))
			entry["url"] = channel == "planner" ? AI_GATEWAY_DEFAULT_PLANNER_URL : AI_GATEWAY_DEFAULT_PARSER_URL
		if(!isnum(entry["timeout_ds"]))
			entry["timeout_ds"] = AI_GATEWAY_DEFAULT_TIMEOUT_DS
		else
			entry["timeout_ds"] = clamp(round(entry["timeout_ds"]), 5, 300)

	if(!isnum(gateway_config["retry_ds"]))
		gateway_config["retry_ds"] = AI_GATEWAY_DEFAULT_RETRY_DS
	else
		gateway_config["retry_ds"] = clamp(round(gateway_config["retry_ds"]), 1, 100)

/// Internal helper to merge exploration multipliers with defaults.
/datum/ai_control_policy/proc/apply_category_defaults(list/source)
	var/list/new_defaults = list()
	for(var/category in GLOB.ai_control_action_categories)
		var/value = source[category]
		if(!isnum(value))
			value = GLOB.ai_control_default_multipliers[category]
		new_defaults[category] = max(0.1, value)
	action_category_defaults = new_defaults

/// Override planner/parser gateway configuration from config file input.
/datum/ai_control_policy/proc/apply_gateway_config(list/source)
	if(!islist(source))
		return
	reset_gateway_to_defaults()
	if(islist(source["planner"]))
		gateway_config["planner"] = merge_gateway_endpoint(gateway_config["planner"], source["planner"])
	if(islist(source["parser"]))
		gateway_config["parser"] = merge_gateway_endpoint(gateway_config["parser"], source["parser"])
	if(isnum(source["retry_ds"]))
		gateway_config["retry_ds"] = clamp(round(source["retry_ds"]), 1, 100)
	else if(isnum(source["retry_seconds"]))
		gateway_config["retry_ds"] = clamp(round(source["retry_seconds"] * 10), 1, 100)
	enforce_gateway_constraints()

/// Merge helper to keep endpoint input safe.
/datum/ai_control_policy/proc/merge_gateway_endpoint(list/base, list/override)
	var/list/result = base?.Copy() || list()
	if(istext(override["url"]))
		result["url"] = override["url"]
	if(isnum(override["timeout_ds"]))
		result["timeout_ds"] = clamp(round(override["timeout_ds"]), 5, 300)
	else if(isnum(override["timeout_seconds"]))
		result["timeout_ds"] = clamp(round(override["timeout_seconds"] * 10), 5, 300)
	return result

/// Merge current configuration entry values into the active policy.

/datum/ai_control_policy/proc/apply_entry_overrides()
	if(!global.config || !global.config.loaded)
		return
	var/list/overrides = build_entry_overrides()
	if(!islist(overrides))
		return
	apply_config(overrides)

/// Build a config list compatible with apply_config() using admin entry values.
/datum/ai_control_policy/proc/build_entry_overrides()
	var/list/overrides = list()
	overrides["ai_control_enabled"] = CONFIG_GET(flag/ai_control_enabled)
	overrides["cadence_seconds"] = CONFIG_GET(number/ai_control_cadence_seconds)
	overrides["max_rollouts_per_cycle"] = CONFIG_GET(number/ai_control_max_rollouts)
	overrides["task_queue_limit"] = CONFIG_GET(number/ai_control_task_queue_limit)
	overrides["telemetry_retention_minutes"] = CONFIG_GET(number/ai_control_telemetry_minutes)

	overrides["exploration_multipliers"] = list(
		AI_ACTION_CATEGORY_ROUTINE = CONFIG_GET(number/ai_control_multiplier_routine),
		AI_ACTION_CATEGORY_LOGISTICS = CONFIG_GET(number/ai_control_multiplier_logistics),
		AI_ACTION_CATEGORY_MEDICAL = CONFIG_GET(number/ai_control_multiplier_medical),
		AI_ACTION_CATEGORY_SECURITY = CONFIG_GET(number/ai_control_multiplier_security),
		AI_ACTION_CATEGORY_SUPPORT = CONFIG_GET(number/ai_control_multiplier_support),
	)

	overrides["emergency_modifiers"] = list(
		"blue" = CONFIG_GET(number/ai_control_emergency_blue),
		"red" = CONFIG_GET(number/ai_control_emergency_red),
		"delta" = CONFIG_GET(number/ai_control_emergency_delta),
	)

	overrides["safety_thresholds"] = list(
		"max_hazard_score" = CONFIG_GET(number/ai_control_max_hazard),
		"max_chain_failures" = CONFIG_GET(number/ai_control_max_chain_failures),
	)

	overrides["rate_limits"] = list(
		"item_toggle_seconds" = CONFIG_GET(number/ai_control_item_toggle_seconds),
		"aggressive_action_seconds" = CONFIG_GET(number/ai_control_aggressive_seconds),
	)

	overrides["telemetry"] = list(
		"rolling_window_minutes" = CONFIG_GET(number/ai_control_telemetry_minutes),
		"persistence_hours" = 24,
	)

	overrides["reservation"] = list(
		"default_expiry_seconds" = CONFIG_GET(number/ai_control_reservation_seconds),
		"retry_delay_seconds" = CONFIG_GET(number/ai_control_reservation_retry_seconds),
	)

	overrides["gateway"] = list(
		"planner" = list(
			"url" = CONFIG_GET(string/ai_gateway_planner_url),
			"timeout_ds" = CONFIG_GET(number/ai_gateway_planner_timeout_ds),
		),
		"parser" = list(
			"url" = CONFIG_GET(string/ai_gateway_parser_url),
			"timeout_ds" = CONFIG_GET(number/ai_gateway_parser_timeout_ds),
		),
		"retry_ds" = CONFIG_GET(number/ai_gateway_retry_ds),
	)

	return overrides

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

/datum/ai_control_policy/proc/get_gateway_url(channel)
	var/list/entry = gateway_config?[channel]
	if(!islist(entry))
		return null
	return entry["url"]

/datum/ai_control_policy/proc/get_gateway_timeout_ds(channel)
	var/list/entry = gateway_config?[channel]
	if(!islist(entry))
		return AI_GATEWAY_DEFAULT_TIMEOUT_DS
	var/value = entry["timeout_ds"]
	if(!isnum(value))
		return AI_GATEWAY_DEFAULT_TIMEOUT_DS
	return clamp(round(value), 5, 300)

/datum/ai_control_policy/proc/get_gateway_retry_ds()
	var/value = gateway_config?["retry_ds"]
	if(!isnum(value))
		return AI_GATEWAY_DEFAULT_RETRY_DS
	return clamp(round(value), 1, 100)

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
		"gateway" = gateway_config?.Copy(),
	)
