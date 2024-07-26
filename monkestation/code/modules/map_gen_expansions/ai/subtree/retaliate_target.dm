// This is to ensure retaliation breaks the "hiding" state if a target is found.
/datum/ai_planning_subtree/target_retaliate/check_faction/stop_hiding
	operational_datums = list(/datum/element/can_hide)


/datum/ai_planning_subtree/target_retaliate/check_faction/stop_hiding/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/target_from_retaliate_list/stop_hiding, BB_BASIC_MOB_RETALIATE_LIST, target_key, targeting_strategy_key, hiding_place_key, check_faction)


// This is to ensure retaliation breaks the "hiding" state if a target is found.
/datum/ai_behavior/target_from_retaliate_list/stop_hiding


/datum/ai_behavior/target_from_retaliate_list/stop_hiding/finish_action(datum/ai_controller/controller, succeeded, shitlist_key, target_key, targeting_strategy_key, hiding_location_key, check_faction)
	. = ..()
	if(!controller.blackboard[BB_HIDING_HIDDEN] || !succeeded)
		return

	controller.queue_behavior(/datum/ai_behavior/toggle_hiding, FALSE)
