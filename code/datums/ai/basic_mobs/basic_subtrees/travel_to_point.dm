/// Simply walk to a location
/datum/ai_planning_subtree/travel_to_point
	/// Blackboard key where we travel a place we walk to
	var/location_key = BB_TRAVEL_DESTINATION
	/// What do we do in order to travel
	var/travel_behaviour = /datum/ai_behavior/travel_towards

/datum/ai_planning_subtree/travel_to_point/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/target = controller.blackboard[location_key]
	if (QDELETED(target))
		return
	controller.queue_behavior(travel_behaviour, location_key)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/ai_planning_subtree/travel_to_point/and_clear_target
	travel_behaviour = /datum/ai_behavior/travel_towards/stop_on_arrival

/datum/ai_planning_subtree/travel_to_point/and_clear_target/reinforce
	location_key = BB_BASIC_MOB_REINFORCEMENT_TARGET
