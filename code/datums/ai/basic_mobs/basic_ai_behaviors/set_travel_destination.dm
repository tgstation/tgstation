/datum/ai_behavior/set_travel_destination

/datum/ai_behavior/set_travel_destination/perform(seconds_per_tick, datum/ai_controller/controller, target_key, location_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	controller.set_blackboard_key(location_key, target)

	finish_action(controller, TRUE, target_key)
