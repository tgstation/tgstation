// Prevents finding a target if hiding.
/datum/ai_planning_subtree/simple_find_target/not_while_hiding
	operational_datums = list(/datum/element/can_hide)

/datum/ai_planning_subtree/simple_find_target/not_while_hiding/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_HIDING_HIDDEN])
		return

	return ..()
