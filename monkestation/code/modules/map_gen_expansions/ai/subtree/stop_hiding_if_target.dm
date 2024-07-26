
/// This subtree ensures that the mob gets out from hiding if they have a target.
/datum/ai_planning_subtree/stop_hiding_if_target
	operational_datums = list(/datum/element/can_hide, /datum/element/can_hide/basic)
	/// Blackboard key where we check if there's currently a target.
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET


/datum/ai_planning_subtree/stop_hiding_if_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] && controller.blackboard[BB_HIDING_HIDDEN])
		controller.queue_behavior(/datum/ai_behavior/toggle_hiding, FALSE)

