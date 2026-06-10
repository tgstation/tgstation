/datum/bt_node/ai_behavior/befriend_target
	var/target_key
	var/befriend_message
	var/long_range_friendship = FALSE

/datum/bt_node/ai_behavior/befriend_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!long_range_friendship && get_dist(living_pawn, living_target) > 1)
		return AI_BEHAVIOR_INSTANT
	living_pawn.befriend(living_target)
	var/befriend_text = controller.blackboard[befriend_message]
	if(befriend_text)
		to_chat(living_target, span_nicegreen("[living_pawn] [befriend_text]"))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/befriend_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

///behavior to befriend any targets
/datum/ai_behavior/befriend_target

/datum/ai_behavior/befriend_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, befriend_message)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.befriend(living_target)
	var/befriend_text = controller.blackboard[befriend_message]
	if(befriend_text)
		to_chat(living_target, span_nicegreen("[living_pawn] [befriend_text]"))

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/befriend_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
