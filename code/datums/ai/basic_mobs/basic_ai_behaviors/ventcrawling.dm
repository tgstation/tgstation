///uhm...sus?
/datum/bt_node/subtree/consider_venting
	behavior_tree_json = "consider_venting.bt.json"


/// Enters a vent stored in entry_vent_key. Sets BB_EXIT_VENT_TARGET and BB_VENT_ENTRY_TIME on success.
/datum/bt_node/ai_behavior/enter_vent
	var/entry_vent_key = BB_ENTRY_VENT_TARGET
	/// TRUE while the async crawl-in is running. perform() holds at DELAY until it resolves.
	var/is_starting_crawl = FALSE
	/// Set by the async action when the crawl finished but we did not end up in the vent.
	var/failed_ventcrawl = FALSE

/datum/bt_node/ai_behavior/enter_vent/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/cached_pawn = controller.pawn

	// We kicked off the crawl on a previous tick; report its result once it resolves. Flags reset in finish_action.
	if(failed_ventcrawl)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(is_starting_crawl)
		if(!HAS_TRAIT(cached_pawn, TRAIT_MOVE_VENTCRAWLING))
			return AI_BEHAVIOR_DELAY // still climbing in
		controller.set_blackboard_key(BB_VENT_ENTRY_TIME, world.time)
		if(prob(50))
			cached_pawn.visible_message(
				span_warning("[cached_pawn] scrambles into the ventilation ducts!"),
				span_hear("You hear something scampering through the ventilation ducts."),
			)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(HAS_TRAIT(cached_pawn, TRAIT_MOVE_VENTCRAWLING))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent = controller.blackboard[entry_vent_key]
	if(!is_vent_valid(entry_vent) || !isliving(cached_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(!cached_pawn.can_enter_vent(entry_vent, provide_feedback = FALSE))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = calculate_exit_vent(controller)
	if(isnull(exit_vent))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_EXIT_VENT_TARGET, exit_vent)
	is_starting_crawl = TRUE
	INVOKE_ASYNC(src, PROC_REF(perform_ventcrawl_action), controller, entry_vent)
	return AI_BEHAVIOR_DELAY

/// Runs the sleeping ventcrawl off the tick. Flags failure if we didn't end up in the vent, so perform() never has to sleep.
/datum/bt_node/ai_behavior/enter_vent/proc/perform_ventcrawl_action(datum/ai_controller/controller, obj/machinery/atmospherics/components/unary/vent_pump/entry_vent)
	var/mob/living/cached_pawn = controller.pawn
	cached_pawn.handle_ventcrawl(entry_vent)
	if(!HAS_TRAIT(cached_pawn, TRAIT_MOVE_VENTCRAWLING)) //something failed and we ARE NOT IN THE VENT even though the earlier check said we were good to go! odd.
		failed_ventcrawl = TRUE

/datum/bt_node/ai_behavior/enter_vent/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_starting_crawl = FALSE
	failed_ventcrawl = FALSE
	if(!succeeded)
		controller.clear_blackboard_key(entry_vent_key)

/// Returns TRUE if the vent exists and isn't welded shut.
/datum/bt_node/ai_behavior/enter_vent/proc/is_vent_valid(obj/machinery/atmospherics/components/unary/vent_pump/vent)
	return !QDELETED(vent) && !vent.welded

/// Picks a random valid vent on the same pipeline as the entry vent. Falls back to the entry vent itself; returns null if nothing is usable.
/datum/bt_node/ai_behavior/enter_vent/proc/calculate_exit_vent(datum/ai_controller/controller)
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent = controller.blackboard[entry_vent_key]
	if(QDELETED(entry_vent))
		return null

	var/datum/pipeline/parent_pipe = entry_vent.parents[1]
	var/list/candidates = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in parent_pipe.other_atmos_machines)
		if(is_vent_valid(vent))
			candidates += vent

	if(length(candidates))
		return pick(candidates)

	if(is_vent_valid(entry_vent))
		return null // in the pipeline already; let the caller handle it

	return entry_vent


/// Waits inside a vent for a randomised duration, then exits. Handles the give-up timeout.
/datum/bt_node/ai_behavior/exit_vent
	time_between_perform = 1 SECONDS
	var/target_exit_time = 0
	/// TRUE while the async crawl-out is running. perform() holds at DELAY until it resolves.
	var/is_exiting_crawl = FALSE
	/// Set by the async action when the crawl finished but we are somehow still in the vent.
	var/failed_ventcrawl = FALSE

/datum/bt_node/ai_behavior/exit_vent/setup(datum/ai_controller/controller)
	. = ..()
	var/lower = controller.blackboard[BB_LOWER_VENT_TIME_LIMIT]
	var/upper = controller.blackboard[BB_UPPER_VENT_TIME_LIMIT]
	var/entry_time = controller.blackboard[BB_VENT_ENTRY_TIME] || world.time
	target_exit_time = entry_time + rand(lower, upper)
	return TRUE

/datum/bt_node/ai_behavior/exit_vent/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/cached_pawn = controller.pawn

	// We kicked off the crawl-out on a previous tick; report its result once it resolves. Flags reset in finish_action.
	if(failed_ventcrawl)
		return suicide_pill(cached_pawn)
	if(is_exiting_crawl)
		if(HAS_TRAIT(cached_pawn, TRAIT_MOVE_VENTCRAWLING))
			return AI_BEHAVIOR_DELAY // still climbing out
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(world.time < target_exit_time)
		var/give_up = controller.blackboard[BB_TIME_TO_GIVE_UP_ON_VENT_PATHING]
		var/entry_time = controller.blackboard[BB_VENT_ENTRY_TIME]
		if(give_up && entry_time && world.time > entry_time + give_up)
			return suicide_pill(cached_pawn)
		return AI_BEHAVIOR_DELAY

	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = controller.blackboard[BB_EXIT_VENT_TARGET]
	if(!is_vent_valid(exit_vent))
		exit_vent = calculate_exit_vent(controller)
		if(isnull(exit_vent))
			return suicide_pill(cached_pawn)
		controller.set_blackboard_key(BB_EXIT_VENT_TARGET, exit_vent)

	cached_pawn.forceMove(exit_vent)
	if(!cached_pawn.can_enter_vent(exit_vent, provide_feedback = FALSE))
		// vent became unusable while we waited; try an emergency exit next tick
		var/emergency = calculate_exit_vent(controller)
		if(isnull(emergency))
			return suicide_pill(cached_pawn)
		controller.set_blackboard_key(BB_EXIT_VENT_TARGET, emergency)
		target_exit_time = world.time // retry immediately next tick
		return AI_BEHAVIOR_DELAY

	is_exiting_crawl = TRUE
	INVOKE_ASYNC(src, PROC_REF(perform_ventcrawl_action), controller, exit_vent)
	return AI_BEHAVIOR_DELAY

/// Runs the sleeping ventcrawl off the tick. Flags failure if we're somehow still in the vent, so perform() never has to sleep.
/datum/bt_node/ai_behavior/exit_vent/proc/perform_ventcrawl_action(datum/ai_controller/controller, obj/machinery/atmospherics/components/unary/vent_pump/exit_vent)
	var/mob/living/cached_pawn = controller.pawn
	cached_pawn.handle_ventcrawl(exit_vent)
	if(HAS_TRAIT(cached_pawn, TRAIT_MOVE_VENTCRAWLING))
		stack_trace("[cached_pawn] [type]: exited vent but still has TRAIT_MOVE_VENTCRAWLING")
		failed_ventcrawl = TRUE

/datum/bt_node/ai_behavior/exit_vent/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_exiting_crawl = FALSE
	failed_ventcrawl = FALSE
	controller.clear_blackboard_key(BB_VENT_ENTRY_TIME)
	controller.clear_blackboard_key(BB_EXIT_VENT_TARGET)
	controller.clear_blackboard_key(BB_ENTRY_VENT_TARGET)

/// Kills the pawn if it has no client, then returns INSTANT FAILED.
/datum/bt_node/ai_behavior/exit_vent/proc/suicide_pill(mob/living/pawn)
	if(istype(pawn) && isnull(pawn.client))
		pawn.death(TRUE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/// Returns TRUE if the vent exists and isn't welded shut.
/datum/bt_node/ai_behavior/exit_vent/proc/is_vent_valid(obj/machinery/atmospherics/components/unary/vent_pump/vent)
	return !QDELETED(vent) && !vent.welded

/// Picks a random valid vent on the same pipeline as BB_ENTRY_VENT_TARGET. Returns null if nothing is usable.
/datum/bt_node/ai_behavior/exit_vent/proc/calculate_exit_vent(datum/ai_controller/controller)
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent = controller.blackboard[BB_ENTRY_VENT_TARGET]
	if(QDELETED(entry_vent))
		return null

	var/datum/pipeline/parent_pipe = entry_vent.parents[1]
	var/list/candidates = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in parent_pipe.other_atmos_machines)
		if(is_vent_valid(vent))
			candidates += vent

	if(length(candidates))
		return pick(candidates)

	if(is_vent_valid(entry_vent))
		return null

	return entry_vent

