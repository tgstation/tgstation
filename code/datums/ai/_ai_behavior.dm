/// Base type for AI behavior leaf nodes in the behavior tree system.
/// setup() is called once on first activation, perform() each tick while running.
/// Returns BT_SUCCESS / BT_FAILURE on completion, BT_RUNNING while active.
/datum/bt_node/ai_behavior
	///Flags for extra behavior (see AI_BEHAVIOR_* defines)
	var/behavior_flags = NONE
	///Cooldown between perform() calls; do not read directly — use get_cooldown()
	var/time_between_perform = 0
	/// TRUE after setup() has been called and before finish_action() completes.
	var/running = FALSE
	/// world.time when perform() may next be called.
	var/next_perform_time = 0
	/// TRUE when the last perform() failed and we are waiting out next_perform_time to say we failed
	var/failed_last_perform = FALSE

/datum/bt_node/ai_behavior/has_active_descendants()
	return running

/datum/bt_node/ai_behavior/get_status_marker()
	if(running)
		return "*"
	return ..()

/datum/bt_node/ai_behavior/append_active_nodes(list/lines, indent)
	if(running)
		lines += "[indent][span_bold("● [get_label()]")]"

/**
 * ai behavior tick. Runs setup() once on first activation, then perform() each tick.
 * Respects per-controller cooldowns set by AI_BEHAVIOR_DELAY.
 * Returns BT_SUCCESS / BT_FAILURE on completion, BT_RUNNING while active.
 */
/datum/bt_node/ai_behavior/tick(datum/ai_controller/controller, seconds_per_tick)
	if(next_perform_time > world.time)
		if(!running && failed_last_perform)
			return BT_FAILURE
		controller.active_execution_index = execution_index
		return BT_RUNNING

	if(controller.bt_execution_log != null)
		if(length(controller.bt_execution_log) < BT_EXECUTION_LOG_MAX)
			controller.bt_execution_log += execution_index

	if(!running)
		if(!setup(controller))
			EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] [type]: setup() failed")
			return BT_FAILURE
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] starting [type]")
		running = TRUE

	var/process_flags = perform(seconds_per_tick, controller)

	if(process_flags & AI_BEHAVIOR_DELAY)
		next_perform_time = world.time + get_cooldown(controller)
	if(process_flags & AI_BEHAVIOR_SUCCEEDED)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] [type]: succeeded")
		failed_last_perform = FALSE
		finish_action(controller, TRUE)
		return BT_SUCCESS
	if(process_flags & AI_BEHAVIOR_FAILED)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] [type]: failed")
		failed_last_perform = TRUE
		finish_action(controller, FALSE)
		return BT_FAILURE
	controller.active_execution_index = execution_index
	return BT_RUNNING

/// Returns the cooldown to apply after a AI_BEHAVIOR_DELAY perform(). Override for conditional delays.
/datum/bt_node/ai_behavior/proc/get_cooldown(datum/ai_controller/cooldown_for)
	return time_between_perform

/// Called when this behavior first activates on a controller. Return FALSE to abort (returns BT_FAILURE).
/datum/bt_node/ai_behavior/proc/setup(datum/ai_controller/controller)
	return TRUE

/// Called each tick while the behavior is running. Returns AI_BEHAVIOR_* flags.
/datum/bt_node/ai_behavior/proc/perform(seconds_per_tick, datum/ai_controller/controller)
	return

/// Called when the behavior finishes (succeeded or failed). Subtypes should call ..().
/datum/bt_node/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded)
	SHOULD_CALL_PARENT(TRUE)
	running = FALSE


/datum/bt_node/ai_behavior/proc/modify_cooldown(new_next_perform_time)
	next_perform_time = new_next_perform_time

/datum/bt_node/ai_behavior/reset_tick_state()
	if(running)
		finish_action(owning_controller, FALSE)
	..()

// DEPRECATED — port behaviors to /datum/bt_node/ai_behavior
// Vars and proc stubs are required so subtype overrides still compile.
/datum/ai_behavior
	var/required_distance = 1
	var/behavior_flags = NONE
	var/time_between_perform = CLICK_CD_MELEE

/datum/ai_behavior/proc/setup(datum/ai_controller/controller, ...)
	return TRUE

/datum/ai_behavior/proc/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	return

/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded, ...)
	return

// DEPRECATED — movement target tracking is no longer used by the BT system
/datum/ai_behavior/proc/set_movement_target(datum/ai_controller/controller, atom/target, movement_type)
	return

/datum/ai_behavior/proc/clear_movement_target(datum/ai_controller/controller)
	return

// Compatibility shims so legacy ai_behavior subtypes ported via deprecated parent_type stubs
// can still call set_movement_target / clear_movement_target without compile errors.
/datum/bt_node/ai_behavior/proc/set_movement_target(datum/ai_controller/controller, atom/target, movement_type)
	return

/datum/bt_node/ai_behavior/proc/clear_movement_target(datum/ai_controller/controller)
	return

/datum/ai_behavior/proc/get_cooldown(datum/ai_controller/cooldown_for)
	return time_between_perform
