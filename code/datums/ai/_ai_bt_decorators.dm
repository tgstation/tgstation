/**
 * Base decorator node. Wraps a single child with a condition check.
 *
 *
 * Supports observer aborts: register to watch specific signals, which triggers a re-check of the condition, potentially aborting the plan depending on the observer_abort settings.
 */
/datum/bt_node/decorator
	node_type = BT_NODE_DECORATOR
	/// Typepath of the single child node. Resolved to an instance at tree construction.
	var/child_typepath = null
	/// Resolved child instance. Populated at tree construction. Do not set directly.
	var/datum/bt_node/child = null
	/// Observer abort mode. Controls reactive re-planning when watched keys change. BT_ABORT_NONE (default) means no reactivity. BT_ABORT_SELF triggers re-plan if we're inside one of our children and the condition changes, while BT_ABORT_LOWER_PRIORITY triggers re-plan if we are in a lower priority (e.g. further to the right) node and the condition changes. BT_ABORT_BOTH does both.
	var/observer_abort = BT_ABORT_NONE
	/// If TRUE, the result of check_condition() is inverted before gating the child.
	var/invert = FALSE
	/// Whether the child is currently BT_RUNNING. This makes tick() skip check_condition() and delegate directly to child.tick().
	var/child_active = FALSE
	/// Set to TRUE once register_observe_signals() has been called for this instance.
	var/observers_registered = FALSE
	/// Set to TRUE when register_observe_signals() registered at least one signal. If this is not true but we are observing; then we need to check the condition every tick; not efficient, but allows for reactivity.
	var/has_observer_signals = FALSE
	/// Last result seen by poll_condition(). null = not yet polled. Used to detect condition changes when no signal is available.
	var/last_poll_result = null
	/// TRUE when this decorator is registered in the controller's polling_observers list.
	var/is_polled = FALSE


/datum/bt_node/decorator/get_children()
	return child ? list(child) : null

/datum/bt_node/decorator/has_active_descendants()
	return child && child.has_active_descendants()

/datum/bt_node/decorator/finalize_node(datum/ai_controller/controller, list/to_visit)
	..()
	if(child)
		child.parent_node = src
		to_visit += child

/datum/bt_node/decorator/append_active_nodes(list/lines, indent)
	if(child && child.has_active_descendants())
		lines += "[indent][get_label()]"
		child.append_active_nodes(lines, "[indent]  ")

/datum/bt_node/decorator/set_descriptor_children(list/children_descs, datum/ai_controller/controller)
	child = controller.get_or_build_node(children_descs[1])

/datum/bt_node/decorator/collect_reset_children(list/to_visit)
	if(child)
		to_visit += child

/datum/bt_node/decorator/append_full_tree_state(list/lines, indent)
	var/observer_text = ""
	if(observer_abort != BT_ABORT_NONE)
		var/abort_name = ""
		if(observer_abort == BT_ABORT_SELF)
			abort_name = "SELF"
		else if(observer_abort == BT_ABORT_LOWER_PRIORITY)
			abort_name = "LOWER"
		else if(observer_abort == BT_ABORT_BOTH)
			abort_name = "BOTH"
		observer_text = " (abort-[abort_name])"
	lines += "[indent][get_status_marker()] [get_label()][observer_text]"
	if(child)
		child.append_full_tree_state(lines, "[indent]  ")

/datum/bt_node/decorator/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick())
		return tick_result || BT_FAILURE

	if(!observers_registered)
		observers_registered = TRUE
		if(observer_abort != BT_ABORT_NONE)
			has_observer_signals = register_observe_signals(controller.pawn)
			if(!has_observer_signals)
				is_polled = TRUE
				LAZYADDASSOC(controller.polling_observers, src, TRUE)

	var/child_ticked = FALSE
	var/result
	var/no_ticking_condition = observer_abort == BT_ABORT_NONE || has_observer_signals
	if((no_ticking_condition || is_polled) && child_active)
		child_ticked = TRUE
		result = child.tick(controller, seconds_per_tick)
	else if(check_condition(controller) == invert)
		result = BT_FAILURE
	else
		child_ticked = TRUE
		result = child.tick(controller, seconds_per_tick)

	if(controller.cancelled_during_tick)
		child_active = FALSE
		return BT_FAILURE

	if(no_ticking_condition || is_polled)
		child_active = (result == BT_RUNNING)
		if(child_ticked && !child_active)
			on_child_complete(controller, result)

	if(tick_rate)
		tick_cooldown = world.time
		tick_result = result
	return result

/**
 * Called when the child finishes (returns a non-RUNNING result after being ticked).
 * NOT called when the condition gate blocks the child, or when the tree is cancelled mid-tick.
 */
/datum/bt_node/decorator/proc/on_child_complete(datum/ai_controller/controller, result)
	return

/**
 * Override to implement custom condition logic.
 * Return TRUE to allow child.tick() to proceed, FALSE to return BT_FAILURE immediately.
 */
/datum/bt_node/decorator/proc/check_condition(datum/ai_controller/controller)
	return TRUE

/**
 * Proc called by the observer system when a watched key changes.
 * Return TRUE if the decorator's condition would pass, FALSE otherwise.
 */
/datum/bt_node/decorator/proc/evaluate_for_observer(datum/ai_controller/controller)
	return check_condition(controller) != invert

/**
 * Called by the controller's observer handler when a watched blackboard key changes.
 * Re-evaluates evaluate_for_observer() and aborts based on observer_abort policy.
 *
 * BT_ABORT_SELF:            condition became FALSE and we're running our children → cancel actions
 * BT_ABORT_LOWER_PRIORITY:  condition became TRUE and we're running lower priority nodes → cancel actions
 */
/// Called by the controller's polling loop for decorators that have no signal observers.
/// Sets a baseline on first call, then fires on_observed_change() only when the result changes.
/datum/bt_node/decorator/proc/poll_condition(datum/ai_controller/controller)
	var/current = evaluate_for_observer(controller)
	if(last_poll_result == null)
		last_poll_result = current
		return
	if(current != last_poll_result)
		last_poll_result = current
		on_observed_change(controller, null)

/datum/bt_node/decorator/proc/on_observed_change(datum/ai_controller/controller, key)
	var/condition_result = evaluate_for_observer(controller)

	if(!condition_result && (observer_abort & BT_ABORT_SELF))
		var/active = controller.active_execution_index
		if(!execution_index || (active >= execution_index && active <= last_execution_index))
			EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] [type]: ABORT_SELF on key=[key] — condition lost, replanning")
			controller.CancelActions()

	if(condition_result && (observer_abort & BT_ABORT_LOWER_PRIORITY))
		var/active = controller.active_execution_index
		if(!execution_index || !active || active > last_execution_index)
			EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] [type]: ABORT_LOWER on key=[key] — condition gained, replanning")
			controller.CancelActions()

/datum/bt_node/decorator/reset_tick_state()
	if(observers_registered)
		unregister_observe_signals(owning_controller?.pawn)
		if(is_polled)
			LAZYREMOVE(owning_controller?.polling_observers, src)
			is_polled = FALSE
		observers_registered = FALSE
		has_observer_signals = FALSE
	last_poll_result = null
	child_active = FALSE
	..()

/datum/bt_node/decorator/assign_execution_indices(counter)
	execution_index = counter
	counter++
	if(child)
		counter = child.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter

/// Override to register all signal observers for this decorator. Return TRUE if any were registered. If a decorator does not handle this and we have an observer_abort mode that isn't BT_ABORT_NONE, the system will fall back to ticking the condition every tick, which is less efficient but allows for reactivity without signals.
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


/// Returns TRUE if the blackboard key holds a non-null, non-deleted value.
/datum/bt_node/decorator/proc/bb_key_exists(datum/ai_controller/controller, key)
	return controller.blackboard_key_exists(key)

/// Gates on whether the named override slot currently has an active override installed.
/// Observes COMSIG_AI_OVERRIDE_SLOT_CHANGED so it reacts immediately when a command is set or cleared.
/// Use with observer_abort = BT_ABORT_LOWER_PRIORITY to preempt idle behaviour when a command arrives.
/datum/bt_node/decorator/override_id_set
	/// SUBPLAN_ID_* constant matching the override slot to watch.
	var/override_id = null

/datum/bt_node/decorator/override_id_set/check_condition(datum/ai_controller/controller)
	var/datum/bt_node/subtree/potential_subtree = LAZYACCESS(controller.override_slots, override_id)
	return !isnull(potential_subtree.override_node)

/datum/bt_node/decorator/override_id_set/register_observe_signals(atom/pawn)
	if(isnull(override_id))
		return FALSE
	RegisterSignal(pawn, COMSIG_AI_OVERRIDE_SLOT_CHANGED(override_id), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/override_id_set/unregister_observe_signals(atom/pawn)
	if(!isnull(override_id))
		UnregisterSignal(pawn, COMSIG_AI_OVERRIDE_SLOT_CHANGED(override_id))

/// Returns TRUE if the blackboard value at key equals the given value.
/datum/bt_node/decorator/proc/bb_key_equals(datum/ai_controller/controller, key, value)
	return controller.blackboard[key] == value

/// Returns TRUE if the blackboard value at key is strictly greater than threshold.
/datum/bt_node/decorator/proc/bb_key_greater(datum/ai_controller/controller, key, threshold)
	return controller.blackboard[key] > threshold
