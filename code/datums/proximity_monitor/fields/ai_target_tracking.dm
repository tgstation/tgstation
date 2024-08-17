// Proximity monitor that checks to see if anything interesting enters our bounds
/datum/proximity_monitor/advanced/ai_target_tracking
	edge_is_a_field = TRUE
	/// The ai behavior who owns us
	var/datum/ai_behavior/find_potential_targets/owning_behavior
	/// The ai controller we're using
	var/datum/ai_controller/controller
	/// The target key we're trying to fill
	var/target_key
	/// The targeting strategy KEY we're using
	var/targeting_strategy_key
	/// The hiding location key we're using
	var/hiding_location_key

	/// The targeting strategy we're using
	var/datum/targeting_strategy/filter
	/// If we've built our field yet
	/// Prevents wasted work on the first build (since the behavior did it)
	var/first_build = TRUE

// Initially, run the check manually
// If that fails, set up a field and have it manage the behavior fully
/datum/proximity_monitor/advanced/ai_target_tracking/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, datum/ai_behavior/find_potential_targets/owning_behavior, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	src.owning_behavior = owning_behavior
	src.controller = controller
	src.target_key = target_key
	src.targeting_strategy_key = targeting_strategy_key
	src.hiding_location_key = hiding_location_key
	src.filter = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	RegisterSignal(controller, COMSIG_QDELETING, PROC_REF(controller_deleted))
	RegisterSignal(controller, COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS, PROC_REF(controller_think))
	RegisterSignal(controller, COMSIG_AI_CONTROLLER_POSSESSED_PAWN, PROC_REF(pawn_changed))
	RegisterSignal(controller, AI_CONTROLLER_BEHAVIOR_QUEUED(owning_behavior.type), PROC_REF(behavior_requeued))
	RegisterSignal(controller, COMSIG_AI_BLACKBOARD_KEY_SET(targeting_strategy_key), PROC_REF(targeting_datum_changed))
	RegisterSignal(controller, COMSIG_AI_BLACKBOARD_KEY_CLEARED(targeting_strategy_key), PROC_REF(targeting_datum_cleared))
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/ai_target_tracking/Destroy()
	. = ..()
	if(!QDELETED(controller) && owning_behavior)
		controller.modify_cooldown(owning_behavior, owning_behavior.get_cooldown(controller))
	owning_behavior = null
	controller = null
	target_key = null
	targeting_strategy_key = null
	hiding_location_key = null
	filter = null

/datum/proximity_monitor/advanced/ai_target_tracking/recalculate_field(full_recalc = FALSE)
	. = ..()
	first_build = FALSE

/datum/proximity_monitor/advanced/ai_target_tracking/setup_field_turf(turf/target)
	. = ..()
	if(first_build)
		return
	owning_behavior.new_turf_found(target, controller, filter)

/datum/proximity_monitor/advanced/ai_target_tracking/field_turf_crossed(atom/movable/movable, turf/location, turf/old_location)
	. = ..()

	if(!owning_behavior.atom_allowed(movable, filter, controller.pawn))
		return

	owning_behavior.new_atoms_found(list(movable), controller, target_key, filter, hiding_location_key)

/// React to controller planning
/datum/proximity_monitor/advanced/ai_target_tracking/proc/controller_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// React to the pawn goin byebye
/datum/proximity_monitor/advanced/ai_target_tracking/proc/pawn_changed(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// React to controller planning
/datum/proximity_monitor/advanced/ai_target_tracking/proc/controller_think(datum/ai_controller/source, list/datum/ai_behavior/old_behaviors, list/datum/ai_behavior/new_behaviors)
	SIGNAL_HANDLER
	// If our parent was forgotten, nuke ourselves
	if(!new_behaviors[owning_behavior])
		qdel(src)

/datum/proximity_monitor/advanced/ai_target_tracking/proc/behavior_requeued(datum/source, list/new_arguments)
	SIGNAL_HANDLER
	check_new_args(arglist(new_arguments))

/// Ensure our args and locals are up to date
/datum/proximity_monitor/advanced/ai_target_tracking/proc/check_new_args(target_key, targeting_strategy_key, hiding_location_key)
	var/update_filter = FALSE
	if(src.target_key != target_key)
		src.target_key = target_key
	if(src.targeting_strategy_key != targeting_strategy_key)
		src.targeting_strategy_key = targeting_strategy_key
		update_filter = TRUE
	if(src.hiding_location_key != hiding_location_key)
		src.hiding_location_key = hiding_location_key
	if(update_filter)
		targeting_datum_changed(null)

/datum/proximity_monitor/advanced/ai_target_tracking/proc/targeting_datum_changed(datum/source)
	SIGNAL_HANDLER
	filter = controller.blackboard[targeting_strategy_key]
	// Filter changed, need to do a full reparse
	// Fucking 9 * 9 out here I stg
	for(var/turf/in_field as anything in field_turfs + edge_turfs)
		owning_behavior.new_turf_found(in_field, controller, filter)

/datum/proximity_monitor/advanced/ai_target_tracking/proc/targeting_datum_cleared(datum/source)
	SIGNAL_HANDLER
	// Go fuckin home bros
	qdel(src)
