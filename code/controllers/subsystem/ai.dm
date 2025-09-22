/**
 * Core subsystem orchestrating AI crew profiles and planner/LLM gateway coordination.
 * Provides tick-aware budgeting, feature gating, and backpressure state that other
 * modules (controllers, gateway client, telemetry) consume.
 */

#include "../../modules/ai_control/constants_shared.dm"

#ifndef SS_AI
#define SS_AI SSai
#endif

SUBSYSTEM_DEF(ai)
	name = "AI Crew Foundation"
	/// Run frequently so we can amortize cadence across controllers.
	wait = 0.5 SECONDS
	/// Treat as background work so player-facing subsystems win contention.
	flags = SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC_ACTIONS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	/// Runtime policy handle (shared with config/UI layers).
	var/datum/ai_control_policy/policy
	/// Controllers currently managed by the subsystem.
	var/list/datum/ai_controller/active_controllers = list()
	/// Controllers scheduled for removal once safe.
	var/list/datum/ai_controller/pending_unregister = list()
	/// Planner request backlog (higher priority than parser work).
	var/list/planner_queue = list()
	/// Parser request backlog.
	var/list/parser_queue = list()
	/// Requests that have been dispatched to external services.
	var/list/inflight_gateway = list()
	/// Completed gateway results cached for callers.
	var/list/gateway_results = list()
	/// Current backpressure mode derived from tick usage.
	var/backpressure_state = AI_BACKPRESSURE_NONE
	/// Cached tick usage from last cycle for telemetry/debugging.
	var/last_tick_usage = 0
	/// Round-robin cursor over active controllers.
	var/controller_cursor = 1
	/// Cached feature flag state to short-circuit processing.
	var/feature_enabled = FALSE
	/// Monotonic identifier for gateway requests.
	var/gateway_request_seq = 0
	/// Rolling history of state transitions for observability.
	var/list/backpressure_log = list()
	/// Timestamp of the most recent policy reload.
	var/last_policy_refresh = 0
	/// Gateway client responsible for dispatching planner/parser work.
	var/datum/ai_gateway_client/gateway_client
	/// Telemetry manager buffering decision logs before persistence.
	var/datum/ai_telemetry_manager/telemetry_manager

/datum/controller/subsystem/ai/PreInit()
	policy = GLOB.ai_control_policy
	if(!policy)
		policy = new /datum/ai_control_policy
		GLOB.ai_control_policy = policy

/datum/controller/subsystem/ai/Initialize()
	sync_feature_flag(FALSE)
	gateway_client = new /datum/ai_gateway_client(src)
	telemetry_manager = new /datum/ai_telemetry_manager(src)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai/OnConfigLoad()
	. = ..()
	sync_feature_flag(TRUE)
	return .

/datum/controller/subsystem/ai/fire(resumed = FALSE)
	if(!feature_enabled)
		if(!sync_feature_flag())
			return

	if(gateway_client)
		gateway_client.sync_from_policy(policy)
	if(telemetry_manager)
		telemetry_manager.sync_from_policy(policy)

	update_backpressure_state()
	cleanup_controllers()

	var/controllers_budget = controllers_per_cycle()
	if(controllers_budget > 0)
		process_controllers(controllers_budget)
		if(MC_TICK_CHECK)
			return

	process_gateway_deferred()
	process_gateway_dispatch()

/datum/controller/subsystem/ai/proc/sync_feature_flag(reload_policy = TRUE)
	if(reload_policy)
		reload_policy_from_disk()

	var/was_enabled = feature_enabled
	feature_enabled = !!AI_CREW_ENABLED
	if(feature_enabled)
		if(!was_enabled)
			on_resumed()
	else if(was_enabled)
		on_suspended()
	return feature_enabled

/datum/controller/subsystem/ai/proc/reload_policy_from_disk()
	if(!policy)
		return
	policy.load_from_file()
	policy.apply_entry_overrides()
	policy.enforce_constraints()
	last_policy_refresh = world.time
	if(gateway_client)
		gateway_client.sync_from_policy(policy)
	if(telemetry_manager)
		telemetry_manager.sync_from_policy(policy)
	notify_policy_reloaded()

/datum/controller/subsystem/ai/proc/notify_policy_reloaded()
	if(!length(active_controllers))
		return
	for(var/datum/ai_controller/controller as anything in active_controllers.Copy())
		if(!controller || QDELETED(controller))
			continue
		if(hascall(controller, "on_policy_reloaded"))
			call(controller, "on_policy_reloaded")(policy)

/datum/controller/subsystem/ai/proc/on_suspended()
	for(var/datum/ai_controller/controller as anything in active_controllers)
		if(hascall(controller, "on_ai_subsystem_suspended"))
			call(controller, "on_ai_subsystem_suspended")(src)

/datum/controller/subsystem/ai/proc/on_resumed()
	for(var/datum/ai_controller/controller as anything in active_controllers)
		if(hascall(controller, "on_ai_subsystem_resumed"))
			call(controller, "on_ai_subsystem_resumed")(src)

/datum/controller/subsystem/ai/proc/update_backpressure_state()
	last_tick_usage = TICK_USAGE
	var/new_state = AI_BACKPRESSURE_NONE
	if(last_tick_usage >= AI_TICK_USAGE_CRITICAL)
		new_state = AI_BACKPRESSURE_CRITICAL
	else if(last_tick_usage >= AI_TICK_USAGE_HARD_CAP)
		new_state = AI_BACKPRESSURE_HEAVY
	else if(last_tick_usage >= AI_TICK_USAGE_SOFT_CAP)
		new_state = AI_BACKPRESSURE_LIGHT

	if(new_state == backpressure_state)
		return
	backpressure_state = new_state
	backpressure_log += list(list("time" = world.time, "mode" = backpressure_state, "usage" = last_tick_usage))
	if(length(backpressure_log) > 50)
		backpressure_log.Cut(1, length(backpressure_log) - 50 + 1)
	if(backpressure_state >= AI_BACKPRESSURE_HEAVY)
		postpone(1)

/datum/controller/subsystem/ai/proc/controllers_per_cycle()
	switch(backpressure_state)
		if(AI_BACKPRESSURE_CRITICAL)
			return AI_CONTROLLERS_PER_TICK_CRITICAL
		if(AI_BACKPRESSURE_HEAVY)
			return AI_CONTROLLERS_PER_TICK_HEAVY
		if(AI_BACKPRESSURE_LIGHT)
			return AI_CONTROLLERS_PER_TICK_LIGHT
	return AI_CONTROLLERS_PER_TICK_NORMAL

/datum/controller/subsystem/ai/proc/process_controllers(limit)
	if(!length(active_controllers))
		return

	var/processed = 0
	while(processed < limit && length(active_controllers))
		if(controller_cursor > length(active_controllers))
			controller_cursor = 1

		var/datum/ai_controller/controller = active_controllers[controller_cursor]
		if(!controller)
			active_controllers.Cut(controller_cursor, controller_cursor + 1)
			continue

		if(!should_run_controller(controller))
			controller_cursor++
			continue

		dispatch_controller(controller)
		processed++
		controller_cursor++
		if(MC_TICK_CHECK)
			break

/datum/controller/subsystem/ai/proc/should_run_controller(datum/ai_controller/controller)
	if(QDELETED(controller))
		queue_controller_removal(controller)
		return FALSE
	if(hascall(controller, "ai_subsystem_enabled") && !call(controller, "ai_subsystem_enabled")())
		return FALSE
	if(hascall(controller, "can_plan") && !call(controller, "can_plan")())
		return FALSE
	return TRUE

/datum/controller/subsystem/ai/proc/dispatch_controller(datum/ai_controller/controller)
	if(hascall(controller, "ai_subsystem_tick"))
		call(controller, "ai_subsystem_tick")(src, backpressure_state)
		return
	if(hascall(controller, "process"))
		call(controller, "process")(backpressure_state)

/datum/controller/subsystem/ai/proc/cleanup_controllers()
	if(!length(active_controllers))
		return
	for(var/index = length(active_controllers); index >= 1; index--)
		var/datum/ai_controller/controller = active_controllers[index]
		if(!controller || QDELETED(controller) || controller in pending_unregister)
			active_controllers.Cut(index, index + 1)

	if(length(pending_unregister))
		pending_unregister.Cut()
	if(controller_cursor > length(active_controllers))
		controller_cursor = 1

/datum/controller/subsystem/ai/proc/register_controller(datum/ai_controller/controller)
	if(!controller || QDELETED(controller))
		return FALSE
	if(!(controller in active_controllers))
		active_controllers += controller
	return TRUE

/datum/controller/subsystem/ai/proc/unregister_controller(datum/ai_controller/controller)
	if(!controller)
		return FALSE
	if(!(controller in active_controllers))
		return TRUE
	queue_controller_removal(controller)
	return TRUE

/datum/controller/subsystem/ai/proc/queue_controller_removal(datum/ai_controller/controller)
	if(!pending_unregister)
		pending_unregister = list()
	if(!(controller in pending_unregister))
		pending_unregister += controller

/datum/controller/subsystem/ai/proc/process_gateway_dispatch()
	if(!length(planner_queue) && !length(parser_queue))
		return

	var/inflight_cap = max_gateway_inflight()
	if(inflight_cap <= 0)
		return

	while(length(inflight_gateway) < inflight_cap)
		var/list/request = pop_next_gateway_request()
		if(!request)
			break
		dispatch_gateway_request(request)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/ai/proc/process_gateway_deferred()
	if(!gateway_client)
		return
	var/list/ready = gateway_client.collect_deferred_ready(backpressure_state)
	if(!length(ready))
		return
	for(var/list/request as anything in ready)
		if(!islist(request))
			continue
		request["status"] = "queued"
		insert_gateway_request(request["channel"] == AI_GATEWAY_CHANNEL_PLANNER ? planner_queue : parser_queue, request)

/datum/controller/subsystem/ai/proc/max_gateway_inflight()
	switch(backpressure_state)
		if(AI_BACKPRESSURE_CRITICAL)
			return AI_GATEWAY_INFLIGHT_CRITICAL
		if(AI_BACKPRESSURE_HEAVY)
			return AI_GATEWAY_INFLIGHT_HEAVY
		if(AI_BACKPRESSURE_LIGHT)
			return AI_GATEWAY_INFLIGHT_LIGHT
	return AI_GATEWAY_INFLIGHT_NORMAL

/datum/controller/subsystem/ai/proc/pop_next_gateway_request()
	var/list/request
	if(length(planner_queue))
		request = planner_queue[1]
		planner_queue.Cut(1, 2)
	else if(length(parser_queue))
		request = parser_queue[1]
		parser_queue.Cut(1, 2)
	return request

/datum/controller/subsystem/ai/proc/dispatch_gateway_request(list/request)
	if(!islist(request))
		return
	if(!gateway_client)
		gateway_client = new /datum/ai_gateway_client(src)
	if(!gateway_client.can_dispatch(backpressure_state))
		request["status"] = "deferred"
		gateway_client.defer_request(request, backpressure_state)
		return
	request["status"] = "pending"
	request["attempts"] = (request["attempts"] || 0) + 1
	inflight_gateway += list(request)
	gateway_client.dispatch(request)

/datum/controller/subsystem/ai/proc/queue_gateway_work(channel, payload, datum/ai_controller/source, priority = AI_GATEWAY_PRIORITY_NORMAL)
	if(!(channel in list(AI_GATEWAY_CHANNEL_PLANNER, AI_GATEWAY_CHANNEL_PARSER)))
		return null
	var/list/request = list(
		"id" = ++gateway_request_seq,
		"channel" = channel,
		"payload" = payload,
		"source" = source,
		"priority" = priority,
		"queued_at" = world.time,
	)
	insert_gateway_request(channel == AI_GATEWAY_CHANNEL_PLANNER ? planner_queue : parser_queue, request)
	return request["id"]

/datum/controller/subsystem/ai/proc/insert_gateway_request(list/queue, list/request)
	if(!length(queue))
		queue += list(request)
		return
	for(var/index in 1 to length(queue))
		var/list/entry = queue[index]
		if(!islist(entry))
			continue
		if(request["priority"] < entry["priority"])
			queue.Insert(index, request)
			return
	queue += list(request)

/datum/controller/subsystem/ai/proc/store_gateway_result(list/request, list/result)
	if(!islist(request))
		return
	inflight_gateway -= request
	request["status"] = "complete"
	request["completed_at"] = world.time
	gateway_results[request["id"]] = list(
		"request" = request,
		"result" = result,
	)

/datum/controller/subsystem/ai/proc/get_gateway_result(request_id, remove = TRUE)
	if(!gateway_results || !(request_id in gateway_results))
		return null
	var/list/data = gateway_results[request_id]
	if(remove)
		gateway_results -= request_id
	return data

/datum/controller/subsystem/ai/proc/is_enabled()
	return feature_enabled

/datum/controller/subsystem/ai/proc/get_policy()
	return policy

/datum/controller/subsystem/ai/proc/get_backpressure_state()
	return backpressure_state

/datum/controller/subsystem/ai/proc/get_telemetry_manager()
	return telemetry_manager
