/**
 * Base decorator node. Wraps a single child with an optional condition gate.
 *
 * If check_condition() returns FALSE, tick() returns BT_FAILURE immediately.
 * Otherwise, delegates to child.tick().
 *
 * Supports UE5-style observer aborts: register to watch blackboard keys and
 * reactively abort running behaviors when the condition changes at runtime.
 *
 * child_typepath is set on the type definition and resolved to a singleton ref
 * by SSai_controllers/proc/setup_bt_nodes() before first use.
 */
/datum/bt_node/decorator
	/// Typepath of the single child node. Resolved to a singleton ref at subsystem init.
	var/child_typepath = null
	/// Resolved singleton child reference. Populated by setup_bt_nodes(). Do not set directly.
	var/datum/bt_node/child = null
	/// Observer abort mode. Controls reactive re-planning when watched keys change.
	var/observer_abort = BT_ABORT_NONE
	/// List of BB_* blackboard key constants to watch. Only used when observer_abort != BT_ABORT_NONE.
	var/list/observed_keys = null
	/// If TRUE, the result of check_condition() is inverted before gating the child.
	var/invert = FALSE

/datum/bt_node/decorator/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_FAILURE

	var/result
	if(check_condition(controller) == invert)
		result = BT_FAILURE
	else
		result = child.tick(controller, seconds_per_tick)

	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result

/**
 * Override to implement custom condition logic.
 * Return TRUE to allow child.tick() to proceed, FALSE to return BT_FAILURE immediately.
 * Blackboard helpers below (bb_key_exists, bb_key_equals, bb_key_greater) are available.
 */
/datum/bt_node/decorator/proc/check_condition(datum/ai_controller/controller)
	return TRUE

/**
 * Virtual proc called by the observer system when a watched key changes.
 * Override this instead of check_condition() for decorators that implement custom tick() logic
 * (e.g. is_at_distance) so the observer path never triggers movement side-effects.
 * Return TRUE if the decorator's condition would pass, FALSE otherwise.
 */
/datum/bt_node/decorator/proc/evaluate_for_observer(datum/ai_controller/controller)
	return check_condition(controller) != invert

/**
 * Called by the controller's observer handler when a watched blackboard key changes.
 * Re-evaluates evaluate_for_observer() and aborts based on observer_abort policy.
 *
 * BT_ABORT_SELF:            condition became FALSE → cancel actions and replan immediately.
 * BT_ABORT_LOWER_PRIORITY:  condition became TRUE  → cancel actions and replan immediately.
 */
/datum/bt_node/decorator/proc/on_observed_change(datum/ai_controller/controller, key)
	var/condition_result = evaluate_for_observer(controller)

	if(!condition_result && (observer_abort & BT_ABORT_SELF))
		controller.CancelActions()
		controller.SelectBehaviors(0)

	if(condition_result && (observer_abort & BT_ABORT_LOWER_PRIORITY))
		controller.CancelActions()
		controller.SelectBehaviors(0)

/**
 * Virtual proc. Override to return a list of COMSIG_* / SIGNAL_* constants that should
 * trigger a reactive re-evaluation of this decorator's condition on the pawn.
 * Return null (default) if this decorator does not watch pawn signals.
 * Signals are registered FROM the decorator singleton, so there is no conflict with
 * the controller's own pawn-signal registrations (e.g. COMSIG_MOVABLE_MOVED → update_grid).
 */
/datum/bt_node/decorator/proc/get_pawn_observe_signals()
	return null

/**
 * Called by setup_bt_observers() when the controller possesses a pawn.
 * Registers all signals from get_pawn_observe_signals() on the pawn using this singleton
 * as the source datum, with on_pawn_signal_changed() as the handler.
 */
/datum/bt_node/decorator/proc/register_pawn_observer(atom/pawn)
	var/list/sigs = get_pawn_observe_signals()
	if(LAZYLEN(sigs))
		RegisterSignals(pawn, sigs, PROC_REF(on_pawn_signal_changed))

/**
 * Called by teardown_bt_observers() when the controller unpossesses its pawn.
 * Unregisters all signals that were registered by register_pawn_observer().
 */
/datum/bt_node/decorator/proc/unregister_pawn_observer(atom/pawn)
	var/list/sigs = get_pawn_observe_signals()
	if(LAZYLEN(sigs))
		UnregisterSignal(pawn, sigs)

/**
 * Signal handler fired when any signal from get_pawn_observe_signals() changes on the pawn.
 * Reads the controller via source.ai_controller, re-evaluates this decorator's condition via
 * evaluate_for_observer(), then aborts and replans according to observer_abort policy.
 */
/datum/bt_node/decorator/proc/on_pawn_signal_changed(atom/source, ...)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.ai_controller
	if(isnull(controller))
		return
	var/condition_result = evaluate_for_observer(controller)
	if(!condition_result && (observer_abort & BT_ABORT_SELF))
		controller.CancelActions()
		controller.SelectBehaviors(0)
		return
	if(condition_result && (observer_abort & BT_ABORT_LOWER_PRIORITY))
		controller.CancelActions()
		controller.SelectBehaviors(0)

// --- Blackboard condition helpers ---

/// Returns TRUE if the blackboard key holds a non-null, non-deleted value.
/datum/bt_node/decorator/proc/bb_key_exists(datum/ai_controller/controller, key)
	return controller.blackboard_key_exists(key)

/// Returns TRUE if the blackboard value at key equals the given value.
/datum/bt_node/decorator/proc/bb_key_equals(datum/ai_controller/controller, key, value)
	return controller.blackboard[key] == value

/// Returns TRUE if the blackboard value at key is strictly greater than threshold.
/datum/bt_node/decorator/proc/bb_key_greater(datum/ai_controller/controller, key, threshold)
	return controller.blackboard[key] > threshold

/**
 * Decorator that requires the controller's pawn to be within range of a blackboard target.
 *
 * On each tick:
 * - If the target is gone → BT_FAILURE.
 * - If pawn is in [min_distance, required_distance] (and reachable when require_reach is TRUE) → child.tick().
 * - If pawn is too far or unreachable → sets movement target and returns BT_RUNNING.
 * - If pawn is too close (dist < min_distance) → BT_FAILURE (cannot back away).
 *
 * Replaces AI_BEHAVIOR_REQUIRE_MOVEMENT and AI_BEHAVIOR_REQUIRE_REACH for new content.
 */
/datum/bt_node/decorator/is_at_distance
	/// Blackboard key holding the atom to approach. Must be set on the subtype or via configure().
	var/target_key = null
	/// Minimum distance (inclusive) from target. 0 means no lower bound.
	var/min_distance = 0
	/// Maximum distance (inclusive) from target before passing to child.
	var/required_distance = 1
	/// If TRUE, also verifies target.IsReachableBy(pawn) before passing to child.
	var/require_reach = FALSE

/datum/bt_node/decorator/is_at_distance/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_RUNNING

	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		if(tick_rate)
			tick_cooldowns[controller] = world.time
			tick_results[controller] = BT_FAILURE
		return BT_FAILURE

	var/atom/movable/pawn = controller.pawn
	var/dist = get_dist(pawn, target)
	var/reachable = !require_reach || target.IsReachableBy(pawn)

	var/result
	if(dist <= required_distance && (min_distance == 0 || dist >= min_distance) && reachable)
		result = child.tick(controller, seconds_per_tick)
	else if(dist < min_distance)
		result = BT_FAILURE // Too close and we can't back away
	else
		controller.set_movement_target(type, target)
		result = BT_RUNNING

	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result

/**
 * Side-effect-free condition check for the observer system.
 * Returns TRUE if the pawn is currently within [min_distance, required_distance] of the target.
 */
/datum/bt_node/decorator/is_at_distance/evaluate_for_observer(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	var/dist = get_dist(controller.pawn, target)
	return (dist <= required_distance) && (min_distance == 0 || dist >= min_distance) && (!require_reach || target.IsReachableBy(controller.pawn))

/**
 * Decorator that gates its child on a blackboard key holding a non-null value.
 * Supports self-abort: when the key is cleared while the child is running, cancels and replans.
 * Configure at usage site via BT_DECORATOR:
 *   BT_DECORATOR(/datum/bt_node/decorator/bb_key_set, child,
 *       "key" = BB_SOME_KEY,
 *       "observed_keys" = list(BB_SOME_KEY),
 *       "observer_abort" = BT_ABORT_SELF)
 */
/datum/bt_node/decorator/bb_key_set
	var/key = null

/datum/bt_node/decorator/bb_key_set/check_condition(datum/ai_controller/controller)
	return controller.blackboard_key_exists(key)
