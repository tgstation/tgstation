/datum/ai_planning_subtree/follow_sound
	operational_datums = list(/datum/element/ai_react_to_sound)
	///the target we follow
	var/target_key = BB_SOUND_TARGET
	///behavior we execute if we heard a sound
	var/action_behavior = /datum/ai_behavior/travel_towards/stop_on_arrival

/datum/ai_planning_subtree/follow_sound/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard_key_exists(target_key))
		return
	controller.queue_behavior(action_behavior, target_key)

