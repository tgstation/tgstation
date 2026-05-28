/**
 * Base decorator node. Wraps a single child with an optional condition gate.
 *
 * If check_condition() returns FALSE, tick() returns BT_FAILURE immediately.
 * Otherwise, delegates to child.tick().
 *
 * Supports UE5-style observer aborts: register to watch blackboard keys and
 * reactively abort running behaviors when the condition changes at runtime.
 */
/datum/bt_node/decorator
	node_type = BT_NODE_DECORATOR
	/// Typepath of the single child node. Resolved to an instance at tree construction.
	var/child_typepath = null
	/// Resolved child instance. Populated at tree construction. Do not set directly.
	var/datum/bt_node/child = null
	/// Observer abort mode. Controls reactive re-planning when watched keys change.
	var/observer_abort = BT_ABORT_NONE
	/// If TRUE, the result of check_condition() is inverted before gating the child.
	var/invert = FALSE
	/// Whether the child is currently BT_RUNNING. When latched, tick() skips check_condition() and delegates directly to child.tick().
	var/child_active = FALSE
	/// Set to TRUE once register_observe_signals() has been called for this instance.
	var/observers_registered = FALSE
	/// Set to TRUE when register_observe_signals() registered at least one signal. Controls condition-latch logic.
	var/has_observer_signals = FALSE
	/// The controller that owns this node instance. Set by finalize_tree().
	var/datum/ai_controller/owning_controller = null

/datum/bt_node/decorator/get_children()
	return child ? list(child) : null

/datum/bt_node/decorator/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick())
		return tick_result || BT_FAILURE

	if(!observers_registered)
		observers_registered = TRUE
		if(observer_abort != BT_ABORT_NONE)
			has_observer_signals = register_observe_signals(controller.pawn)

	// Latch: skip check_condition when child is running, unless polling (observer_abort set but no signals).
	var/result
	var/no_ticking_condition = observer_abort == BT_ABORT_NONE || has_observer_signals
	if(no_ticking_condition && child_active)
		result = child.tick(controller, seconds_per_tick)
	else if(check_condition(controller) == invert)
		result = BT_FAILURE
	else
		result = child.tick(controller, seconds_per_tick)

	if(no_ticking_condition)
		child_active = (result == BT_RUNNING)

	if(tick_rate)
		tick_cooldown = world.time
		tick_result = result
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
		var/active = controller.active_execution_index
		if(!execution_index || (active >= execution_index && active <= last_execution_index))
			EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] [type]: ABORT_SELF on key=[key] — condition lost, replanning")
			controller.CancelActions()
			//controller.SelectBehaviors(0)

	if(condition_result && (observer_abort & BT_ABORT_LOWER_PRIORITY))
		var/active = controller.active_execution_index
		if(!execution_index || !active || active > last_execution_index)
			EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] [type]: ABORT_LOWER on key=[key] — condition gained, preempting")
			controller.CancelActions()
			//controller.SelectBehaviors(0)

/datum/bt_node/decorator/reset_tick_state()
	if(observers_registered)
		unregister_observe_signals(owning_controller?.pawn)
		observers_registered = FALSE
		has_observer_signals = FALSE
	child_active = FALSE
	..()

/datum/bt_node/decorator/assign_execution_indices(counter)
	execution_index = counter
	counter++
	if(child)
		counter = child.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter

/// Override to register all signal observers for this decorator. Return TRUE if any were registered.
/datum/bt_node/decorator/proc/register_observe_signals(atom/pawn)
	return FALSE

/// Override to unregister all observers registered by register_observe_signals().
/datum/bt_node/decorator/proc/unregister_observe_signals(atom/pawn)
	return

/// Shared signal handler. Calls on_observed_change() with owning_controller.
/datum/bt_node/decorator/proc/on_signal_changed(atom/source, ...)
	SIGNAL_HANDLER
	if(owning_controller)
		on_observed_change(owning_controller, null)

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


///Decorator that requires the controller's pawn to be within range of a blackboard target.
/datum/bt_node/decorator/is_at_distance
	/// Blackboard key holding the atom to approach. Must be set on the subtype or via configure().
	var/target_key = null
	/// Minimum distance (inclusive) from target. 0 means no lower bound.
	var/min_distance = 0
	/// Maximum distance (inclusive) from target before passing to child.
	var/required_distance = 1
	/// If TRUE, also verifies target.IsReachableBy(pawn) before passing to child.
	var/require_reach = FALSE

/datum/bt_node/decorator/is_at_distance/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	var/atom/movable/pawn = controller.pawn
	var/dist = get_dist(pawn, target)
	var/reachable = !require_reach || target.IsReachableBy(pawn)

	return dist <= required_distance && (min_distance == 0 || dist >= min_distance) && reachable

///Is the key set to a non-null value
/datum/bt_node/decorator/bb_key_set
	var/key = null

/datum/bt_node/decorator/bb_key_set/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/bb_key_set/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/datum/bt_node/decorator/bb_key_set/check_condition(datum/ai_controller/controller)
	return controller.blackboard_key_exists(key)
