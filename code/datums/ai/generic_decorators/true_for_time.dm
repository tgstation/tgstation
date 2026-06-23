/**
 * Passes while its duration has not elapsed, then fails  reactively via observer abort.
 * Starts timing on the first tick; resets when the tree resets.
 *
 * duration: how long to pass, in deciseconds (e.g. "10 SECONDS").
 * Set observer_abort to BT_ABORT_BOTH (or BT_ABORT_SELF) to abort the child when time expires.
 */
/datum/bt_node/decorator/true_for_time
	var/duration = 0
	var/timer_id = null
	var/timed_out = FALSE

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
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/true_for_time/check_condition(datum/ai_controller/controller)
	return !timed_out
