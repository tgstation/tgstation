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
	proc/handle_request(method, path, payload)
		var/verb = uppertext(method)
		var/list/segments = normalize_path(path)
		if(verb == "GET")
			if(length(segments) == 3 && segments[1] == "admin" && segments[2] == "ai" && segments[3] == "blackboard")
				return build_blackboard_snapshot()
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
