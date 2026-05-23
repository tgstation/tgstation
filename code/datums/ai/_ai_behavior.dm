/// Base type for AI behavior leaf nodes in the behavior tree system.
/// Behaviors are singletons; all per-controller state lives in running_state and behavior_cooldowns.
/// setup() is called once on first activation, perform() each tick while running.
/// Returns BT_SUCCESS / BT_FAILURE on completion, BT_RUNNING while active.
/datum/bt_node/ai_behavior
	///What distance you need to be from the target to perform the action (informational, unused by BT tick)
	var/required_distance = 1
	///Flags for extra behavior (see AI_BEHAVIOR_* defines)
	var/behavior_flags = NONE
	///Cooldown between perform() calls; do not read directly — use get_cooldown()
	var/action_cooldown = CLICK_CD_MELEE
	/// Positional args passed to setup()/perform()/finish_action() after the fixed args.
	/// Set by BT_LEAF at build time via configure().
	var/list/default_behavior_args = null
	/// Per-controller active state. TRUE after setup() has been called for a controller.
	var/alist/running_state = alist()
	/// Per-controller cooldown. Stores world.time when perform() may next be called.
	var/alist/behavior_cooldowns = alist()

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
	// Respect per-controller action cooldown
	var/ready_time = behavior_cooldowns[controller]
	if(!isnull(ready_time) && ready_time > world.time)
		return BT_RUNNING

	// Run setup on first activation
	if(!running_state[controller])
		var/list/setup_args = list(controller)
		if(LAZYLEN(default_behavior_args))
			setup_args += default_behavior_args
		if(!setup(arglist(setup_args)))
			return BT_FAILURE
		running_state[controller] = TRUE

	// Run perform
	var/list/perform_args = list(seconds_per_tick, controller)
	if(LAZYLEN(default_behavior_args))
		perform_args += default_behavior_args
	var/process_flags = perform(arglist(perform_args))

	if(process_flags & AI_BEHAVIOR_SUCCEEDED)
		_finish_behavior(controller, TRUE)
		return BT_SUCCESS
	if(process_flags & AI_BEHAVIOR_FAILED)
		_finish_behavior(controller, FALSE)
		return BT_FAILURE
	if(process_flags & AI_BEHAVIOR_DELAY)
		behavior_cooldowns[controller] = world.time + get_cooldown(controller)
	return BT_RUNNING

/// Calls finish_action() with args and clears per-controller state.
/datum/bt_node/ai_behavior/proc/_finish_behavior(datum/ai_controller/controller, succeeded)
	var/list/finish_args = list(controller, succeeded)
	if(LAZYLEN(default_behavior_args))
		finish_args += default_behavior_args
	finish_action(arglist(finish_args))
	running_state -= controller
	behavior_cooldowns -= controller

/// Clears per-controller tick state. Calls finish_action(FALSE) unless AI_BEHAVIOR_UNINTERRUPTIBLE.
/datum/bt_node/ai_behavior/reset_tick_state(datum/ai_controller/controller)
	if(running_state[controller])
		if(!(behavior_flags & AI_BEHAVIOR_UNINTERRUPTIBLE))
			_finish_behavior(controller, FALSE)
		else
			running_state -= controller
			behavior_cooldowns -= controller
	else
		behavior_cooldowns -= controller
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

/datum/ai_behavior/proc/get_cooldown(datum/ai_controller/cooldown_for)
	return action_cooldown
