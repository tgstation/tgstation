/**
 * Passes while its duration has not elapsed.
 * Starts timing on the first tick; resets when the tree resets.
 *
 * duration: how long to pass, in deciseconds (e.g. "10 SECONDS").
 * succeed_on_timeout FALSE (default): counts as succeed and lets lower nodes pass
*/
/datum/bt_node/decorator/true_for_time
	observer_abort = BT_ABORT_SELF
	var/duration = 0
	var/succeed_on_timeout = FALSE
	VAR_PRIVATE/timer_id = null
	VAR_PRIVATE/timed_out = FALSE

/datum/bt_node/decorator/true_for_time/register_observe_signals(atom/pawn)
	timer_id = addtimer(CALLBACK(src, PROC_REF(on_timeout)), duration, TIMER_STOPPABLE|TIMER_DELETE_ME)
	return TRUE

/datum/bt_node/decorator/true_for_time/unregister_observe_signals(atom/pawn)
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	timed_out = FALSE

/datum/bt_node/decorator/true_for_time/proc/on_timeout()
	SIGNAL_HANDLER
	timer_id = null
	timed_out = TRUE
	if(succeed_on_timeout)
		return // handled locally by tick(), no plan-wide cancel needed
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/true_for_time/check_condition(datum/ai_controller/controller)
	return !timed_out

/datum/bt_node/decorator/true_for_time/tick(datum/ai_controller/controller, seconds_per_tick)
	if(succeed_on_timeout && timed_out)
		if(child_active && child)
			child.reset_subtree_tick_states()
			child_active = FALSE
		return BT_SUCCESS
	return ..()
