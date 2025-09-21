/datum/blackboard_stub
/datum/perception_stub
/datum/option_runner_stub

/// Crew human controller integrating the AI control foundation with Dream Maker's
/// existing AI controller infrastructure. Handles profile lifecycles, exposes
/// stubs for perception/blackboard/option coordination, and cooperates with the
/// SS_AI subsystem for tick budgeting and gateway orchestration.

/datum/ai_controller/crew_human
	/// Disable client override unless explicitly allowed.
	continue_processing_when_client = FALSE
	/// We handle scheduling manually via SS_AI, not the legacy planning subsystem.
	planning_subtrees = list()
	/// Avoid idle subsystem behaviors for now; OptionRunner will drive cadence.
	can_idle = FALSE

	/// Reference to the coordinating SS_AI subsystem (cached for speed/testability).
	var/datum/controller/subsystem/ai/ai_subsystem
	/// Cached policy pointer for multipliers, cadence, and limits.
	var/datum/ai_control_policy/policy
	/// Runtime crew profile datum (risk tolerance, taxonomy multipliers, etc.).
	var/datum/ai_crew_profile/profile
	/// Last situational snapshot emitted for planner requests.
	var/datum/ai_context_snapshot/last_snapshot
	/// Pending gateway requests keyed by request id → metadata.
	var/list/pending_gateway_requests = list()
	/// Recently completed gateway responses for admin/debug surfaces.
	var/list/gateway_history = list()
	/// Cached backpressure state from the subsystem.
	var/last_backpressure_state = AI_BACKPRESSURE_NONE
	/// Next world.time (in deciseconds) we are allowed to initiate a planning cycle.
	var/next_planning_window = 0
	/// Baseline cadence (deciseconds) derived from policy config.
	var/planning_interval_ds = max(1, round(AI_CONTROL_DEFAULT_CADENCE * 10))
	/// Marker used to skip planning work when suspended or overridden.
	var/controller_suspended = FALSE

	/// Placeholder hooks populated in later tasks.
	var/datum/blackboard_stub/blackboard_component
	var/datum/perception_stub/perception_component
	var/datum/option_runner_stub/option_runner

/datum/ai_controller/crew_human/New(atom/new_pawn, datum/controller/subsystem/ai/subsystem_override)
	ai_subsystem = subsystem_override || SS_AI
	if(ai_subsystem)
		policy = ai_subsystem.get_policy()
	..(new_pawn)
	if(ai_subsystem)
		ai_subsystem.register_controller(src)
	initialize_controller_state()

/datum/ai_controller/crew_human/Destroy(force)
	release_from_subsystem()
	cleanup_profile()
	return ..()

/datum/ai_controller/crew_human/UnpossessPawn(destroy)
	if(profile)
		profile.deactivate()
		profile.set_player_override(FALSE)
		profile.set_mob(null)
	return ..()

/datum/ai_controller/crew_human/PossessPawn(atom/new_pawn)
	..()
	if(QDELETED(src))
		return
	attach_profile_to_pawn()
	schedule_next_planning_cycle(TRUE)

/datum/ai_controller/crew_human/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/carbon/human))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/carbon/human/human = new_pawn
	if(human.client && !continue_processing_when_client)
		return AI_CONTROLLER_INCOMPATIBLE
	return NONE

/datum/ai_controller/crew_human/on_sentience_gained()
	..()
	if(profile)
		profile.set_player_override(TRUE)
	controller_suspended = TRUE

/datum/ai_controller/crew_human/on_sentience_lost()
	..()
	controller_suspended = FALSE
	if(profile)
		profile.set_player_override(FALSE)
	schedule_next_planning_cycle(TRUE)

/datum/ai_controller/crew_human/on_stat_changed(mob/living/source, new_stat)
	..()
	if(!profile)
		return
	if(new_stat == DEAD)
		profile.deactivate()
	else if(!controller_suspended)
		profile.activate()

/datum/ai_controller/crew_human/on_pawn_qdeleted()
	..()
	detach_profile()
	release_from_subsystem()

/datum/ai_controller/crew_human/proc/initialize_controller_state()
	sync_policy(policy)
	if(pawn)
		attach_profile_to_pawn()
	schedule_next_planning_cycle(TRUE)

/datum/ai_controller/crew_human/proc/sync_policy(datum/ai_control_policy/new_policy)
	if(!new_policy)
		if(!policy)
			policy = new /datum/ai_control_policy
	else
		policy = new_policy
	planning_interval_ds = max(1, round((policy?.get_cadence() || AI_CONTROL_DEFAULT_CADENCE) * 10))
	if(profile && policy)
		profile.on_policy_updated(policy)

/datum/ai_controller/crew_human/proc/attach_profile_to_pawn()
	var/mob/living/carbon/human/human = pawn
	if(!human)
		return
	if(!profile)
		profile = new /datum/ai_crew_profile(human, policy)
	else
		profile.set_mob(human)
		if(policy)
			profile.on_policy_updated(policy)
	profile.activate()
	controller_suspended = FALSE

/datum/ai_controller/crew_human/proc/detach_profile()
	if(!profile)
		return
	profile.deactivate()
	profile.set_player_override(FALSE)
	profile.set_mob(null)

/datum/ai_controller/crew_human/proc/cleanup_profile()
	if(profile)
		qdel(profile)
	profile = null
	last_snapshot = null

/datum/ai_controller/crew_human/proc/release_from_subsystem()
	if(ai_subsystem)
		ai_subsystem.unregister_controller(src)
	ai_subsystem = null

/datum/ai_controller/crew_human/proc/ai_subsystem_enabled()
	return !!(policy?.enabled)

/datum/ai_controller/crew_human/proc/on_ai_subsystem_suspended(datum/controller/subsystem/ai/subsystem)
	controller_suspended = TRUE
	if(profile)
		profile.deactivate()

/datum/ai_controller/crew_human/proc/on_ai_subsystem_resumed(datum/controller/subsystem/ai/subsystem)
	controller_suspended = FALSE
	if(subsystem)
		sync_policy(subsystem.get_policy())
	if(profile)
		profile.activate()
	schedule_next_planning_cycle(TRUE)

/datum/ai_controller/crew_human/proc/on_policy_reloaded(datum/ai_control_policy/new_policy)
	sync_policy(new_policy)
	schedule_next_planning_cycle(TRUE)

/datum/ai_controller/crew_human/proc/ai_subsystem_tick(datum/controller/subsystem/ai/subsystem, backpressure_state)
	if(subsystem && subsystem != ai_subsystem)
		ai_subsystem = subsystem
	last_backpressure_state = backpressure_state
	poll_gateway_results()
	if(controller_suspended || !profile)
		return
	if(!profile.is_active() || !profile.can_plan())
		return
	var/current_time = world.time
	if(current_time < next_planning_window)
		return
	var/datum/ai_context_snapshot/snapshot = gather_context_snapshot()
	if(snapshot)
		last_snapshot = snapshot
	profile.record_action("planning_stub", null, "bp=[backpressure_state]")
	schedule_next_planning_cycle(FALSE, backpressure_state)

/datum/ai_controller/crew_human/proc/gather_context_snapshot()
	if(!pawn)
		return null
	var/turf/location = get_turf(pawn)
	return new /datum/ai_context_snapshot(location)

/datum/ai_controller/crew_human/proc/schedule_next_planning_cycle(immediate, backpressure_state = AI_BACKPRESSURE_NONE)
	var/base_interval = planning_interval_ds
	switch(backpressure_state)
		if(AI_BACKPRESSURE_LIGHT)
			base_interval += 5
		if(AI_BACKPRESSURE_HEAVY)
			base_interval += 10
		if(AI_BACKPRESSURE_CRITICAL)
			base_interval += 20
	if(immediate)
		next_planning_window = world.time
	else
		next_planning_window = world.time + base_interval

/datum/ai_controller/crew_human/proc/poll_gateway_results()
	if(!ai_subsystem || !length(pending_gateway_requests))
		return
	var/list/ids = pending_gateway_requests.Copy()
	for(var/request_id in ids)
		var/list/data = ai_subsystem.get_gateway_result(request_id)
		if(!islist(data))
			continue
		var/list/request_meta = ids[request_id]
		pending_gateway_requests -= request_id
		var/list/request = data["request"]
		var/list/result = data["result"]
		handle_gateway_result(request_id, request_meta, request, result)

/datum/ai_controller/crew_human/proc/handle_gateway_result(request_id, list/meta, list/request, list/result)
	var/channel = meta?["channel"] || request?["channel"]
	var/list/history_entry = list(
		"id" = request_id,
		"channel" = channel,
		"completed_at" = world.time,
		"result" = result,
	)
	gateway_history += list(history_entry)
	if(length(gateway_history) > 20)
		gateway_history.Cut(1, length(gateway_history) - 20 + 1)
	if(channel == AI_GATEWAY_CHANNEL_PLANNER)
		on_planner_response(request, result)
	else if(channel == AI_GATEWAY_CHANNEL_PARSER)
		on_parser_response(request, result)

/datum/ai_controller/crew_human/proc/on_planner_response(list/request, list/result)
	// Placeholder: Will integrate option runner and telemetry in later tasks.
	return

/datum/ai_controller/crew_human/proc/on_parser_response(list/request, list/result)
	// Placeholder: Will update blackboard/perception in later tasks.
	return

/datum/ai_controller/crew_human/proc/queue_planner_request(list/payload, priority = AI_GATEWAY_PRIORITY_NORMAL)
	return queue_gateway_request(AI_GATEWAY_CHANNEL_PLANNER, payload, priority)

/datum/ai_controller/crew_human/proc/queue_parser_request(list/payload, priority = AI_GATEWAY_PRIORITY_NORMAL)
	return queue_gateway_request(AI_GATEWAY_CHANNEL_PARSER, payload, priority)

/datum/ai_controller/crew_human/proc/queue_gateway_request(channel, list/payload, priority = AI_GATEWAY_PRIORITY_NORMAL)
	if(!ai_subsystem)
		return null
	var/id = ai_subsystem.queue_gateway_work(channel, payload, src, priority)
	if(!id)
		return null
	pending_gateway_requests[id] = list(
		"channel" = channel,
		"payload" = payload,
		"queued_at" = world.time,
	)
	return id

/datum/ai_controller/crew_human/proc/get_blackboard_component()
	return blackboard_component

/datum/ai_controller/crew_human/proc/get_perception_component()
	return perception_component

/datum/ai_controller/crew_human/proc/get_option_runner()
	return option_runner
