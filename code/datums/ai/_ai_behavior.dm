/// Base type for AI behavior leaf nodes in the behavior tree system.
/// Each controller gets its own node instance, so all state lives directly on the instance.
/// setup() is called once on first activation, perform() each tick while running.
/// Returns BT_SUCCESS / BT_FAILURE on completion, BT_RUNNING while active.
/datum/bt_node/ai_behavior
	///Flags for extra behavior (see AI_BEHAVIOR_* defines)
	var/behavior_flags = NONE
	///Cooldown between perform() calls; do not read directly — use get_cooldown()
	var/action_cooldown = CLICK_CD_MELEE
	/// Positional args passed to setup()/perform()/finish_action() after the fixed args.
	/// Set by BT_LEAF at build time via configure().
	var/list/default_behavior_args = null
	/// TRUE after setup() has been called and before finish_action() completes.
	var/running = FALSE
	/// world.time when perform() may next be called.
	var/next_perform_time = 0

/datum/bt_node/ai_behavior/has_active_descendants()
	return running

/datum/bt_node/ai_behavior/append_active_nodes(list/lines, indent)
	if(running)
		lines += "[indent][span_bold("● [get_label()]")]"

/// Returns the cooldown to apply after a AI_BEHAVIOR_DELAY perform(). Override for conditional delays.
/datum/bt_node/ai_behavior/proc/get_cooldown(datum/ai_controller/cooldown_for)
	return action_cooldown

/// Called when this behavior first activates on a controller. Return FALSE to abort (returns BT_FAILURE).
/datum/bt_node/ai_behavior/proc/setup(datum/ai_controller/controller, ...)
	return TRUE

/// Called each tick while the behavior is running. Returns AI_BEHAVIOR_* flags.
/datum/bt_node/ai_behavior/proc/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	return

/// Called when the behavior finishes (succeeded or failed). Subtypes should call ..().
/datum/bt_node/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded, ...)
	return

/**
 * BT leaf tick. Runs setup() once on first activation, then perform() each tick.
 * Respects per-controller cooldowns set by AI_BEHAVIOR_DELAY.
 * Returns BT_SUCCESS / BT_FAILURE on completion, BT_RUNNING while active.
 */
/datum/bt_node/ai_behavior/tick(datum/ai_controller/controller, seconds_per_tick)
	if(next_perform_time > world.time)
		controller.active_execution_index = execution_index
		return BT_RUNNING

	if(controller.bt_execution_log != null)
		if(length(controller.bt_execution_log) < BT_EXECUTION_LOG_MAX)
			controller.bt_execution_log += execution_index

	if(!running)
		var/list/setup_args = list(controller)
		if(LAZYLEN(default_behavior_args))
			setup_args += default_behavior_args
		if(!setup(arglist(setup_args)))
			EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] [type]: setup() failed")
			return BT_FAILURE
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] starting [type]")
		running = TRUE

	var/list/perform_args = list(seconds_per_tick, controller)
	if(LAZYLEN(default_behavior_args))
		perform_args += default_behavior_args
	var/process_flags = perform(arglist(perform_args))

	if(process_flags & AI_BEHAVIOR_DELAY)
		next_perform_time = world.time + get_cooldown(controller)
	if(process_flags & AI_BEHAVIOR_SUCCEEDED)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] [type]: succeeded")
		_finish_behavior(controller, TRUE)
		return BT_SUCCESS
	if(process_flags & AI_BEHAVIOR_FAILED)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] [type]: failed")
		_finish_behavior(controller, FALSE)
		return BT_FAILURE
	controller.active_execution_index = execution_index
	return BT_RUNNING

/// Calls finish_action() with args and clears per-controller state.
/datum/bt_node/ai_behavior/proc/_finish_behavior(datum/ai_controller/controller, succeeded)
	var/list/finish_args = list(controller, succeeded)
	if(LAZYLEN(default_behavior_args))
		finish_args += default_behavior_args
	finish_action(arglist(finish_args))
	running = FALSE
	next_perform_time = 0

/datum/bt_node/ai_behavior/reset_tick_state()
	if(running)
		if(!(behavior_flags & AI_BEHAVIOR_UNINTERRUPTIBLE))
			_finish_behavior(owning_controller, FALSE)
		else
			running = FALSE
			next_perform_time = 0
	else
		next_perform_time = 0
	..()

// DEPRECATED — port behaviors to /datum/bt_node/ai_behavior
// Vars and proc stubs are required so subtype overrides still compile.
/datum/ai_behavior
	var/required_distance = 1
	var/behavior_flags = NONE
	var/action_cooldown = CLICK_CD_MELEE

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
	return action_cooldown
