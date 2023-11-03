// Proximity monitor that checks to see if anything interesting enters our bounds
/datum/proximity_monitor/advanced/ai_target_tracking
	edge_is_a_field = TRUE
	/// Callback to invoke when we find a new turf
	var/datum/callback/on_new_turf
	/// Callback to invoke when we find a new movable
	var/datum/callback/on_new_movable
	/// The type of the ai behavior who owns us
	var/datum/ai_behavior/behavior_type

/datum/proximity_monitor/advanced/ai_target_tracking/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, datum/callback/on_new_turf, datum/callback/on_new_movable, datum/ai_controller/controller, datum/ai_behavior/behavior_type)
	. = ..()
	src.on_new_turf = on_new_turf
	src.on_new_movable = on_new_movable
	RegisterSignal(controller, COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS, PROC_REF(controller_think))
	src.behavior_type = behavior_type
	recalculate_field()

/datum/proximity_monitor/advanced/ai_target_tracking/setup_field_turf(turf/target)
	. = ..()
	on_new_turf.Invoke(target)

/datum/proximity_monitor/advanced/ai_target_trackinge/field_turf_crossed(atom/movable/movable, turf/location, turf/old_location)
	. = ..()
	// If we're coming from in bounds who cares
	if(old_location && get_dist(old_location, host) <= current_range)
		return

	on_new_movable.Invoke(movable)

/// React to controller planning
/datum/proximity_monitor/advanced/ai_target_tracking/proc/controller_think(datum/ai_controller/source, list/datum/ai_behaviors/old_behaviors, list/datum/ai_behaviors/new_behaviors)
	SIGNAL_HANDLER
	// If our parent was forgotten, nuke ourselves
	if(!new_behaviors[behavior_type])
		qdel(src)

