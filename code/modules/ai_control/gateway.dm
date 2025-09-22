/// Gateway client skeleton that translates planner/parser requests into world.Export
/// calls. For now this implementation simulates responses while respecting tick
/// backpressure and configuration-driven endpoints.

/datum/ai_gateway_client
	/// Owning subsystem reference (used to store results and read policy updates).
	var/datum/controller/subsystem/ai/owner
	/// Planner endpoint configuration.
	var/planner_endpoint = AI_GATEWAY_DEFAULT_PLANNER_URL
	var/planner_timeout_ds = AI_GATEWAY_DEFAULT_TIMEOUT_DS
	/// Parser endpoint configuration.
	var/parser_endpoint = AI_GATEWAY_DEFAULT_PARSER_URL
	var/parser_timeout_ds = AI_GATEWAY_DEFAULT_TIMEOUT_DS
	/// Base retry delay (deciseconds) applied when deferring work.
	var/retry_delay_ds = AI_GATEWAY_DEFAULT_RETRY_DS
	/// Pending deferred requests waiting for a retry window.
	var/list/deferred_requests = list()
	/// Tracks when configuration was last synced to avoid redundant work.
	var/last_policy_revision = 0

/datum/ai_gateway_client/New(datum/controller/subsystem/ai/new_owner)
	owner = new_owner
	sync_from_policy(owner?.get_policy())
	return ..()

/// Update endpoints/timeouts after configuration reloads.
/datum/ai_gateway_client/proc/sync_from_policy(datum/ai_control_policy/policy)
	if(!policy)
		return
	planner_endpoint = policy.get_gateway_url(AI_GATEWAY_CHANNEL_PLANNER) || AI_GATEWAY_DEFAULT_PLANNER_URL
	parser_endpoint = policy.get_gateway_url(AI_GATEWAY_CHANNEL_PARSER) || AI_GATEWAY_DEFAULT_PARSER_URL
	planner_timeout_ds = policy.get_gateway_timeout_ds(AI_GATEWAY_CHANNEL_PLANNER)
	parser_timeout_ds = policy.get_gateway_timeout_ds(AI_GATEWAY_CHANNEL_PARSER)
	retry_delay_ds = policy.get_gateway_retry_ds()
	last_policy_revision = policy.last_loaded_snapshot

/// Push requests that were deferred back to the subsystem queues when ready.
/datum/ai_gateway_client/proc/collect_deferred_ready(backpressure_state)
	if(!length(deferred_requests))
		return list()
	var/current_time = world.time
	var/list/ready = list()
	for(var/index = length(deferred_requests); index >= 1; index--)
		var/list/entry = deferred_requests[index]
		if(!islist(entry))
			deferred_requests.Cut(index, index + 1)
			continue
		var/next_attempt = entry["retry_at"]
		if(!isnum(next_attempt))
			ready += entry["request"]
			deferred_requests.Cut(index, index + 1)
			continue
		if(current_time >= next_attempt)
			ready += entry["request"]
			deferred_requests.Cut(index, index + 1)
	return ready

/// Determine whether the current tick usage allows dispatching.
/datum/ai_gateway_client/proc/can_dispatch(backpressure_state)
	if(backpressure_state >= AI_BACKPRESSURE_HEAVY)
		return FALSE
	if(world.tick_usage >= AI_TICK_USAGE_HARD_CAP)
		return FALSE
	return TRUE

/// Schedule a retry window that respects backpressure severity.
/datum/ai_gateway_client/proc/defer_request(list/request, backpressure_state)
	if(!islist(request))
		return
	var/delay = retry_delay_ds
	switch(backpressure_state)
		if(AI_BACKPRESSURE_LIGHT)
			delay += AI_GATEWAY_BACKOFF_LIGHT_DS
		if(AI_BACKPRESSURE_HEAVY)
			delay += AI_GATEWAY_BACKOFF_HEAVY_DS
		if(AI_BACKPRESSURE_CRITICAL)
			delay += AI_GATEWAY_BACKOFF_CRITICAL_DS
	deferred_requests += list(list(
		"request" = request,
		"retry_at" = world.time + max(delay, 1),
	))

/// Dispatch the request. Currently emits mocked responses for planner/parser.
/datum/ai_gateway_client/proc/dispatch(list/request)
	if(!islist(request) || !owner)
		return
	var/channel = request["channel"]
	if(!istext(channel))
		channel = AI_GATEWAY_CHANNEL_PLANNER
	request["dispatched_at"] = world.time
	if(channel == AI_GATEWAY_CHANNEL_PLANNER)
		request["endpoint"] = planner_endpoint
		owner.store_gateway_result(request, build_mock_planner_response(request))
		return
	if(channel == AI_GATEWAY_CHANNEL_PARSER)
		request["endpoint"] = parser_endpoint
		owner.store_gateway_result(request, build_mock_parser_response(request))
		return
	owner.store_gateway_result(request, list("error" = "unknown_channel", "channel" = channel))

/// Generate a placeholder planner response so downstream code can integrate.
/datum/ai_gateway_client/proc/build_mock_planner_response(list/request)
	var/list/payload = request?["payload"]
	var/ai_id = payload?["ai_id"]
	return list(
		"status" = "mock",
		"chosen" = list("id" = "hold_position", "args" = list()),
		"meta" = list(
			"ai_id" = ai_id,
			"dispatched_at" = request?["dispatched_at"],
			"queued_at" = request?["queued_at"],
			"mock" = TRUE,
		),
		"stats" = list(
			"n_sims" = 0,
			"depth" = 0,
			"beta" = null,
		),
	)

/// Generate a placeholder parser response that yields no structured events.
/datum/ai_gateway_client/proc/build_mock_parser_response(list/request)
	var/list/payload = request?["payload"]
	return list(
		"status" = "mock",
		"events" = list(),
		"meta" = list(
			"utterances" = payload?["utterances"] || list(),
			"dispatched_at" = request?["dispatched_at"],
		),
	)
