/// Administrator blackboard API facade for AI crew monitoring.

GLOBAL_DATUM(admin_ai_gateway, /datum/admin_ai_gateway)

/proc/call_admin_ai_endpoint(method, path, payload = null)
	var/datum/admin_ai_gateway/gateway = GLOB.admin_ai_gateway
	if(!gateway)
		gateway = new /datum/admin_ai_gateway
		GLOB.admin_ai_gateway = gateway
	return gateway.handle_request(method, path, payload)

/datum/admin_ai_gateway
	/// Entry point for simulated admin API requests.
	var/policy_snapshot_version = 0

	proc/handle_request(method, path, payload)
		var/verb = uppertext(method)
		var/list/segments = normalize_path(path)
		if(verb == "GET")
			if(length(segments) == 3 && segments[1] == "admin" && segments[2] == "ai" && segments[3] == "blackboard")
				return build_blackboard_snapshot()
			if(length(segments) == 4 && segments[1] == "admin" && segments[2] == "ai" && segments[3] == "crew")
				return build_crew_timeline(segments[4])
		if(verb == "PATCH")
			if(length(segments) == 3 && segments[1] == "admin" && segments[2] == "ai" && segments[3] == "config")
				return apply_policy_patch(payload)
		return build_error("not_found", 404)

	proc/normalize_path(path)
		if(!istext(path))
			return list()
		var/clean = path
		while(length(clean) && copytext(clean, 1, 2) == "/")
			clean = copytext(clean, 2)
		while(length(clean) && copytext(clean, length(clean), length(clean) + 1) == "/")
			clean = copytext(clean, 1, length(clean))
		if(!length(clean))
			return list()
		return splittext(clean, "/")

	proc/build_blackboard_snapshot()
		var/list/result = list()
		var/datum/controller/subsystem/ai/ss = SS_AI
		if(ss)
			for(var/datum/ai_controller/crew_human/controller as anything in ss.active_controllers)
				if(QDELETED(controller))
					continue
				var/datum/ai_crew_profile/profile = controller.profile
				if(!profile)
					continue
				var/list/summary = build_controller_summary(controller, profile)
				if(summary)
					result += list(summary)

		return list(
			"generated_at" = format_iso_timestamp(world.realtime),
			"crew" = result,
		)

	proc/build_crew_timeline(profile_id)
		if(!istext(profile_id) || !length(profile_id))
			return build_error("invalid_profile", 400)

		var/datum/controller/subsystem/ai/ss = SS_AI
		if(!ss)
			return build_error("unavailable", 503)

		var/datum/ai_controller/crew_human/controller = find_controller_by_profile_id(profile_id)
		var/datum/ai_telemetry_manager/manager = ss?.get_telemetry_manager()
		var/list/raw_records = manager ? manager.get_recent_records(profile_id, 0, FALSE) : list()

		if(!controller && (!islist(raw_records) || !length(raw_records)))
			return build_error("profile_not_found", 404)

		var/list/entries = list()
		if(islist(raw_records))
			for(var/datum/ai_decision_telemetry/record as anything in raw_records)
				if(!record)
					continue
				var/list/entry = build_timeline_entry(manager, record)
				if(entry)
					entries += list(entry)

		var/list/response = list(
			"profile_id" = profile_id,
			"entries" = entries,
		)

		if(controller && controller.profile)
			var/datum/ai_crew_profile/profile = controller.profile
			response["job_id"] = profile.get_job_id() || ""
			response["status"] = resolve_status(profile)
			var/datum/ai_blackboard/blackboard = controller.get_blackboard_component()
			var/current_objective = blackboard?.get_goal()
			if(istext(current_objective) && length(current_objective))
				response["current_objective"] = current_objective
		else
			response["status"] = "UNKNOWN"

		response["generated_at"] = format_iso_timestamp(world.realtime)
		return response

	proc/build_controller_summary(datum/ai_controller/crew_human/controller, datum/ai_crew_profile/profile)
		var/list/action_weights = profile.action_taxonomy_weights?.Copy() || list()
		var/list/recent_actions = list()
		var/list/last_action = profile.get_last_action()
		if(islist(last_action))
			var/list/entry = build_action_entry(last_action)
			if(entry)
				recent_actions += list(entry)

		var/datum/ai_blackboard/blackboard = controller.get_blackboard_component()
		var/current_objective = blackboard?.get_goal()

		return list(
			"profile_id" = profile.get_profile_id(),
			"job_id" = profile.get_job_id() || "",
			"status" = resolve_status(profile),
			"current_objective" = current_objective || "",
			"action_category_weights" = action_weights,
			"recent_actions" = recent_actions,
		)

	proc/build_action_entry(list/action)
		var/verb = action["verb"]
		if(!istext(verb))
			verb = verb ? "[verb]" : "unknown"
		var/result = action["result"]
		if(!istext(result))
			result = result ? lowertext("[result]") : "partial"
		var/timestamp_ds = action["timestamp"]
		var/timepoint = convert_world_time_to_realtime(timestamp_ds)
		return list(
			"verb" = verb,
			"result" = result,
			"timestamp" = format_iso_timestamp(timepoint),
		)

	proc/resolve_status(datum/ai_crew_profile/profile)
		if(!profile)
			return "UNKNOWN"
		if(profile.has_status(AI_CREW_STATUS_EMERGENCY_LOCKDOWN))
			return "EMERGENCY_LOCKDOWN"
		if(profile.has_status(AI_CREW_STATUS_PLAYER_OVERRIDE))
			return "PLAYER_OVERRIDE"
		if(profile.has_status(AI_CREW_STATUS_ACTIVE))
			return "AI_ACTIVE"
		return "UNKNOWN"

	proc/find_controller_by_profile_id(profile_id)
		if(!istext(profile_id))
			return null
		var/datum/controller/subsystem/ai/ss = SS_AI
		if(!ss)
			return null
		if(!length(ss.active_controllers))
			return null
		for(var/datum/ai_controller/crew_human/controller as anything in ss.active_controllers)
			if(!controller || QDELETED(controller))
				continue
			var/datum/ai_crew_profile/profile = controller.profile
			if(!profile)
				continue
			if(profile.get_profile_id() == profile_id)
				return controller
		return null

	proc/build_timeline_entry(datum/ai_telemetry_manager/manager, datum/ai_decision_telemetry/record)
		if(!record)
			return null
		var/sequence_id = record.sequence_id
		if(!isnum(sequence_id))
			return null
		var/selected_action = stringify_selected_action(manager, record.selected_action)
		var/exploration_bonus = record.exploration_bonus
		if(!isnum(exploration_bonus))
			exploration_bonus = 0
		var/rollout_count = record.rollout_count
		if(!isnum(rollout_count))
			rollout_count = 0
		var/result = manager ? manager.sanitize_result(record.result) : sanitize_result(record.result)
		var/notes = manager ? manager.sanitize_notes(record.notes) : sanitize_notes(record.notes)
		var/timepoint = convert_world_time_to_realtime(record.created_at_tick)
		var/list/entry = list(
			"sequence_id" = round(sequence_id),
			"selected_action" = selected_action,
			"exploration_bonus" = round(exploration_bonus, 0.01),
			"rollout_count" = clamp(round(rollout_count), 0, AI_CONTROL_DEFAULT_MAX_ROLLOUTS),
			"result" = result,
			"timestamp" = format_iso_timestamp(timepoint),
		)
		if(notes)
			entry["notes"] = notes
		return entry

	proc/stringify_selected_action(datum/ai_telemetry_manager/manager, value)
		if(manager)
			return manager.resolve_selected_action(value)
		if(istext(value))
			return value
		if(islist(value))
			if(istext(value["id"]))
				return value["id"]
			if(istext(value["verb"]))
				return value["verb"]
		return "unknown"

	proc/sanitize_result(value)
		if(!istext(value))
			return "partial"
		var/lower = lowertext(value)
		if(lower in list("success", "partial", "failure", "aborted"))
			return lower
		return "partial"

	proc/sanitize_notes(value)
		if(isnull(value))
			return null
		if(istext(value))
			return copytext(value, 1, 2048)
		return text("[value]")

	proc/apply_policy_patch(payload)
		if(!islist(payload))
			return build_error("invalid_payload", 400)

		var/list/applied = list()
		var/list/action_defaults = extract_action_defaults(payload["action_category_defaults"])
		if(!length(action_defaults))
			return build_error("invalid_action_defaults", 422)
		apply_action_defaults(action_defaults)
		applied["action_category_defaults"] = action_defaults.Copy()

		var/list/emergency_modifiers = extract_emergency_modifiers(payload["emergency_modifiers"])
		if(length(emergency_modifiers))
			apply_emergency_modifiers(emergency_modifiers)
			applied["emergency_modifiers"] = emergency_modifiers.Copy()

		var/list/safety_thresholds = extract_safety_thresholds(payload["safety_thresholds"])
		if(length(safety_thresholds))
			apply_safety_thresholds(safety_thresholds)
			applied["safety_thresholds"] = safety_thresholds.Copy()

		var/list/rate_limits = extract_rate_limits(payload["rate_limits"])
		if(length(rate_limits))
			apply_rate_limits(rate_limits)
			applied["rate_limits"] = rate_limits.Copy()

		var/list/gateway_overrides = extract_gateway_overrides(payload["gateway"])
		if(length(gateway_overrides))
			apply_gateway_overrides(gateway_overrides)
			applied["gateway"] = gateway_overrides.Copy()

		var/telemetry_minutes = extract_telemetry_minutes(payload["telemetry_retention_minutes"])
		if(telemetry_minutes)
			CONFIG_SET(number/ai_control_telemetry_minutes, telemetry_minutes)
			applied["telemetry_retention_minutes"] = telemetry_minutes

		var/datum/controller/subsystem/ai/ss = SS_AI
		var/datum/ai_control_policy/policy = ss?.get_policy() || GLOB.ai_control_policy
		if(!policy)
			policy = new /datum/ai_control_policy
			GLOB.ai_control_policy = policy
			if(ss)
				ss.policy = policy

		policy.apply_entry_overrides()
		policy.enforce_constraints()

		if(ss)
			var/datum/ai_telemetry_manager/manager = ss.get_telemetry_manager()
			if(manager)
				manager.sync_from_policy(policy)
			ss.notify_policy_reloaded()

		if(length(applied))
			log_admin("AI foundation config patched via admin gateway: [json_encode(applied)]")

		return build_policy_snapshot(policy)

	proc/extract_action_defaults(source)
		var/list/result = list()
		if(!islist(source))
			return result
		for(var/category in GLOB.ai_control_action_categories)
			if(!(category in source))
				continue
			var/value = source[category]
			if(!isnum(value))
				continue
			value = clamp(value, 0.1, 4)
			result[category] = round(value, 0.01)
		return result

	proc/apply_action_defaults(list/action_defaults)
		if(!islist(action_defaults) || !length(action_defaults))
			return
		if(AI_ACTION_CATEGORY_ROUTINE in action_defaults)
			CONFIG_SET(number/ai_control_multiplier_routine, action_defaults[AI_ACTION_CATEGORY_ROUTINE])
		if(AI_ACTION_CATEGORY_LOGISTICS in action_defaults)
			CONFIG_SET(number/ai_control_multiplier_logistics, action_defaults[AI_ACTION_CATEGORY_LOGISTICS])
		if(AI_ACTION_CATEGORY_MEDICAL in action_defaults)
			CONFIG_SET(number/ai_control_multiplier_medical, action_defaults[AI_ACTION_CATEGORY_MEDICAL])
		if(AI_ACTION_CATEGORY_SECURITY in action_defaults)
			CONFIG_SET(number/ai_control_multiplier_security, action_defaults[AI_ACTION_CATEGORY_SECURITY])
		if(AI_ACTION_CATEGORY_SUPPORT in action_defaults)
			CONFIG_SET(number/ai_control_multiplier_support, action_defaults[AI_ACTION_CATEGORY_SUPPORT])

	proc/extract_emergency_modifiers(source)
		var/list/result = list()
		if(!islist(source))
			return result
		if(istext(source["alert_level"]))
			var/level = lowertext(source["alert_level"])
			var/scale = source["c_pi_scale"]
			if(isnum(scale))
				result[level] = clamp(round(scale, 0.01), 0, 2)
			return result
		for(var/level in list("blue", "red", "delta", "green"))
			if(!(level in source))
				continue
			var/value = source[level]
			if(!isnum(value))
				continue
			result[level] = clamp(round(value, 0.01), 0, 2)
		return result

	proc/apply_emergency_modifiers(list/modifiers)
		if(!islist(modifiers) || !length(modifiers))
			return
		if("blue" in modifiers)
			CONFIG_SET(number/ai_control_emergency_blue, modifiers["blue"])
		if("red" in modifiers)
			CONFIG_SET(number/ai_control_emergency_red, modifiers["red"])
		if("delta" in modifiers)
			CONFIG_SET(number/ai_control_emergency_delta, modifiers["delta"])

	proc/extract_safety_thresholds(source)
		var/list/result = list()
		if(!islist(source))
			return result
		for(var/key in list("max_hazard_score", "max_chain_failures"))
			if(!(key in source))
				continue
			var/value = source[key]
			if(!isnum(value))
				continue
			if(key == "max_hazard_score")
				value = clamp(value, 0, 1)
			else
				value = clamp(round(value), 0, 10)
			result[key] = value
		return result

	proc/apply_safety_thresholds(list/thresholds)
		if(!islist(thresholds) || !length(thresholds))
			return
		if("max_hazard_score" in thresholds)
			CONFIG_SET(number/ai_control_max_hazard, thresholds["max_hazard_score"])
		if("max_chain_failures" in thresholds)
			CONFIG_SET(number/ai_control_max_chain_failures, thresholds["max_chain_failures"])

	proc/extract_rate_limits(source)
		var/list/result = list()
		if(!islist(source))
			return result
		for(var/key in list("item_toggle_seconds", "aggressive_action_seconds"))
			if(!(key in source))
				continue
			var/value = source[key]
			if(!isnum(value))
				continue
			value = clamp(round(value), 0, 600)
			result[key] = value
		return result

	proc/apply_rate_limits(list/limits)
		if(!islist(limits) || !length(limits))
			return
		if("item_toggle_seconds" in limits)
			CONFIG_SET(number/ai_control_item_toggle_seconds, limits["item_toggle_seconds"])
		if("aggressive_action_seconds" in limits)
			CONFIG_SET(number/ai_control_aggressive_seconds, limits["aggressive_action_seconds"])

	proc/extract_gateway_overrides(source)
		var/list/result = list()
		if(!islist(source))
			return result
		if(istext(source["planner_url"]))
			result["planner_url"] = source["planner_url"]
		if(istext(source["parser_url"]))
			result["parser_url"] = source["parser_url"]
		if(isnum(source["planner_timeout_ds"]))
			result["planner_timeout_ds"] = clamp(round(source["planner_timeout_ds"]), 5, 300)
		if(isnum(source["parser_timeout_ds"]))
			result["parser_timeout_ds"] = clamp(round(source["parser_timeout_ds"]), 5, 300)
		if(isnum(source["retry_ds"]))
			result["retry_ds"] = clamp(round(source["retry_ds"]), 1, 100)
		return result

	proc/apply_gateway_overrides(list/overrides)
		if(!islist(overrides) || !length(overrides))
			return
		if("planner_url" in overrides)
			CONFIG_SET(string/ai_gateway_planner_url, overrides["planner_url"])
		if("parser_url" in overrides)
			CONFIG_SET(string/ai_gateway_parser_url, overrides["parser_url"])
		if("planner_timeout_ds" in overrides)
			CONFIG_SET(number/ai_gateway_planner_timeout_ds, overrides["planner_timeout_ds"])
		if("parser_timeout_ds" in overrides)
			CONFIG_SET(number/ai_gateway_parser_timeout_ds, overrides["parser_timeout_ds"])
		if("retry_ds" in overrides)
			CONFIG_SET(number/ai_gateway_retry_ds, overrides["retry_ds"])

	proc/extract_telemetry_minutes(value)
		if(!isnum(value))
			return 0
		value = clamp(round(value), AI_CONTROL_MIN_TELEMETRY_MINUTES, AI_CONTROL_MAX_TELEMETRY_MINUTES)
		return value

	proc/build_policy_snapshot(datum/ai_control_policy/policy)
		if(!policy)
			policy = GLOB.ai_control_policy
		var/list/action_defaults = policy?.action_category_defaults?.Copy() || list()
		var/list/emergency = policy?.emergency_modifiers?.Copy() || list()
		var/telemetry_minutes = policy?.get_telemetry_window_minutes() || AI_CONTROL_DEFAULT_TELEMETRY_MINUTES
		policy_snapshot_version = max(policy_snapshot_version + 1, 1)
		return list(
			"version" = policy_snapshot_version,
			"updated_at" = format_iso_timestamp(world.realtime),
			"action_category_defaults" = action_defaults,
			"emergency_modifiers" = emergency,
			"telemetry_retention_minutes" = telemetry_minutes,
		)

	proc/convert_world_time_to_realtime(timestamp_ds)
		if(!isnum(timestamp_ds))
			return world.realtime
		return world.realtime + (timestamp_ds - world.time)

	proc/format_iso_timestamp(time_ds)
		if(!isnum(time_ds))
			time_ds = world.realtime
		return "[time2text(time_ds, \"YYYY-MM-DDThh:mm:ss\", TIMEZONE_UTC)]Z"

	proc/build_error(reason, status_code = 500)
		return list(
			"error" = reason,
			"status" = status_code,
		)

#define AI_BLACKBOARD_REFRESH_COOLDOWN (5 SECONDS)

ADMIN_VERB(open_ai_blackboard, R_ADMIN, "AI Foundation Blackboard", "Inspect AI crew controllers, planner health, and runtime config.", ADMIN_CATEGORY_DEBUG)
	usr.holder?.open_ai_blackboard_panel("AIFoundationBlackboard")

ADMIN_VERB(open_ai_foundation_config, R_ADMIN, "AI Foundation Config", "Adjust exploration multipliers, safety thresholds, and gateway tuning for the AI foundation.", ADMIN_CATEGORY_DEBUG)
	usr.holder?.open_ai_blackboard_panel("AdminConfig")

/datum/admins/proc/open_ai_blackboard_panel(interface_name)
	if(!check_rights(R_ADMIN))
		return
	var/datum/admin_ai_blackboard_panel/ui = new(usr)
	if(istext(interface_name) && length(interface_name))
		ui.interface_id = interface_name
	ui.ui_interact(usr)

/datum/admin_ai_blackboard_panel
	var/interface_id = "AIFoundationBlackboard"
	var/list/cached_blackboard
	var/last_blackboard_refresh = 0
	var/list/cached_timelines = list()
	var/list/policy_snapshot
	var/list/last_patch_response

/datum/admin_ai_blackboard_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/admin_ai_blackboard_panel/ui_interact(mob/user, datum/tgui/ui)
	refresh_blackboard(TRUE)
	refresh_policy_snapshot()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, interface_id || "AIFoundationBlackboard")
		ui.open()

/datum/admin_ai_blackboard_panel/ui_static_data(mob/user)
	return list(
		"refresh_cooldown_ds" = AI_BLACKBOARD_REFRESH_COOLDOWN,
	)

/datum/admin_ai_blackboard_panel/ui_data(mob/user)
	refresh_blackboard(FALSE)
	var/list/data = list()
	data["blackboard"] = cached_blackboard?.Copy() || list("crew" = list())
	data["last_refresh_ds"] = last_blackboard_refresh
	data["now_ds"] = world.time
	data["timelines"] = build_timeline_payload()
	data["gateway_status"] = build_gateway_status()
	data["policy"] = policy_snapshot?.Copy()
	data["last_patch_response"] = last_patch_response?.Copy()
	return data

/datum/admin_ai_blackboard_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(R_ADMIN))
		return

	switch(action)
		if("refresh")
			refresh_blackboard(TRUE)
			ui?.update()
			return TRUE

		if("loadTimeline")
			var/profile_id = params["profile_id"]
			var/force = params?["force"]
			load_timeline(profile_id, !!force)
			ui?.update()
			return TRUE

		if("clearTimeline")
			var/profile_id = params["profile_id"]
			if(istext(profile_id))
				cached_timelines -= profile_id
				ui?.update()
				return TRUE

		if("patchConfig")
			if(apply_config_patch(params))
				ui?.update()
				return TRUE

	return FALSE

/datum/admin_ai_blackboard_panel/proc/refresh_blackboard(force)
	if(!force && world.time < (last_blackboard_refresh + AI_BLACKBOARD_REFRESH_COOLDOWN))
		return cached_blackboard

	var/list/result = call_admin_ai_endpoint("GET", "/admin/ai/blackboard")
	if(!islist(result))
		cached_blackboard = list("error" = "unknown", "crew" = list())
		last_blackboard_refresh = world.time
		return cached_blackboard

	if(result["error"])
		cached_blackboard = list(
			"error" = result["error"],
			"status" = result["status"],
			"crew" = list(),
		)
		last_blackboard_refresh = world.time
		return cached_blackboard

	cached_blackboard = result.Copy()
	last_blackboard_refresh = world.time
	return cached_blackboard

/datum/admin_ai_blackboard_panel/proc/load_timeline(profile_id, force)
	if(!istext(profile_id) || !length(profile_id))
		return null

	var/list/entry = cached_timelines[profile_id]
	if(!force && islist(entry) && islist(entry["timeline"]))
		return entry

	var/list/result = call_admin_ai_endpoint("GET", "/admin/ai/crew/[profile_id]")
	if(!islist(result))
		return null

	if(result["error"])
		cached_timelines[profile_id] = list(
			"timeline" = list(
				"error" = result["error"],
				"status" = result?["status"],
				"profile_id" = profile_id,
			),
			"fetched_at" = world.time,
		)
		return cached_timelines[profile_id]

	cached_timelines[profile_id] = list(
		"timeline" = result.Copy(),
		"fetched_at" = world.time,
	)
	return cached_timelines[profile_id]

/datum/admin_ai_blackboard_panel/proc/build_timeline_payload()
	if(!length(cached_timelines))
		return list()
	var/list/output = list()
	for(var/profile_id in cached_timelines)
		var/list/entry = cached_timelines[profile_id]
		if(!islist(entry))
			continue
		var/list/timeline = entry["timeline"]
		if(!islist(timeline))
			continue
		output[profile_id] = timeline.Copy()
	return output

/datum/admin_ai_blackboard_panel/proc/build_gateway_status()
	var/list/status = list()
	var/datum/controller/subsystem/ai/ss = SS_AI
	if(!ss)
		return status

	status["feature_enabled"] = ss.is_enabled()
	status["backpressure_state"] = ss.get_backpressure_state()
	status["tick_usage"] = round(ss.last_tick_usage, 0.1)
	status["planner_queue"] = length(ss.planner_queue)
	status["parser_queue"] = length(ss.parser_queue)
	status["inflight"] = length(ss.inflight_gateway)
	status["deferred"] = length(ss.gateway_client?.deferred_requests)
	status["last_policy_refresh"] = ss.last_policy_refresh

	var/datum/ai_control_policy/policy = get_policy()
	if(policy)
		status["planner_url"] = policy.get_gateway_url(AI_GATEWAY_CHANNEL_PLANNER)
		status["parser_url"] = policy.get_gateway_url(AI_GATEWAY_CHANNEL_PARSER)
		status["planner_timeout_ds"] = policy.get_gateway_timeout_ds(AI_GATEWAY_CHANNEL_PLANNER)
		status["parser_timeout_ds"] = policy.get_gateway_timeout_ds(AI_GATEWAY_CHANNEL_PARSER)
		status["retry_ds"] = policy.get_gateway_retry_ds()

	return status

/datum/admin_ai_blackboard_panel/proc/get_policy()
	var/datum/controller/subsystem/ai/ss = SS_AI
	var/datum/ai_control_policy/policy = ss?.get_policy()
	if(!policy)
		policy = GLOB.ai_control_policy
	return policy

/datum/admin_ai_blackboard_panel/proc/refresh_policy_snapshot()
	var/datum/ai_control_policy/policy = get_policy()
	policy_snapshot = policy ? policy.to_list() : null

/datum/admin_ai_blackboard_panel/proc/apply_config_patch(list/params)
	if(!islist(params))
		return FALSE

	var/list/payload = list()
	if(islist(params["action_category_defaults"]))
		payload["action_category_defaults"] = params["action_category_defaults"].Copy()
	if(islist(params["emergency_modifiers"]))
		payload["emergency_modifiers"] = params["emergency_modifiers"].Copy()
	if(islist(params["safety_thresholds"]))
		payload["safety_thresholds"] = params["safety_thresholds"].Copy()
	if(islist(params["rate_limits"]))
		payload["rate_limits"] = params["rate_limits"].Copy()
	if(islist(params["gateway"]))
		payload["gateway"] = params["gateway"].Copy()
	if(isnum(params["telemetry_retention_minutes"]))
		payload["telemetry_retention_minutes"] = params["telemetry_retention_minutes"]

	if(!length(payload))
		return FALSE

	var/list/result = call_admin_ai_endpoint("PATCH", "/admin/ai/config", payload)
	if(!islist(result))
		last_patch_response = list("error" = "patch_failed")
		return FALSE

	if(result["error"])
		last_patch_response = result.Copy()
		return FALSE

	last_patch_response = result.Copy()
	refresh_policy_snapshot()
	return TRUE

#undef AI_BLACKBOARD_REFRESH_COOLDOWN
