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
	src.behavior_type = behavior_type
	RegisterSignal(controller, COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS, PROC_REF(controller_think))
	RegisterSignal(controller, COMSIG_AI_CONTROLLER_POSSESSED_PAWN, PROC_REF(pawn_changed))
	RegisterSignal(controller, AI_CONTROLLER_BEHAVIOR_QUEUED(owning_behavior.type), PROC_REF(behavior_requeued))
	RegisterSignal(controller, COMSIG_AI_BLACKBOARD_KEY_SET(targetting_datum_key), PROC_REF(targeting_datum_changed))
	RegisterSignal(controller, COMSIG_AI_BLACKBOARD_KEY_CLEARED(targetting_datum_key), PROC_REF(targeting_datum_cleared))
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/ai_target_tracking/Destroy()
	. = ..()
	owning_behavior = null
	controller = null
	target_key = null
	targetting_datum_key = null
	hiding_location_key = null
	filter = null

/datum/proximity_monitor/advanced/ai_target_tracking/recalculate_field(full_recalc = FALSE)
	. = ..()
	first_build = FALSE

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

