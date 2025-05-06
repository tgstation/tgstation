
///simple behavior to make mobs randomly drag things around
/datum/ai_planning_subtree/steal_items/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.pulling)
		if(prob(controller.blackboard[BB_GUILTY_CONSCIOUS_CHANCE]))
			controller.queue_behavior(/datum/ai_behavior/stop_dragging)
		return
	if(!controller.blackboard[BB_STEAL_CHANCE])
		return
	if(!controller.blackboard_key_exists(BB_ITEM_TO_STEAL))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/find_stealable, /obj/item, BB_ITEM_TO_STEAL)
		return
	controller.queue_behavior(/datum/ai_behavior/drag_target)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/find_and_set/find_stealable
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 2 MINUTES

/datum/ai_behavior/find_and_set/find_stealable/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn

	var/list/possible_items = shuffle_inplace(oview(search_range, controller.pawn))
	for(var/obj/item/possible_item in possible_items)
		if(possible_item.pulledby || possible_item.anchored)
			continue
		if(can_see(living_pawn, possible_item))
			return possible_item


/datum/ai_behavior/stop_dragging
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/stop_dragging/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.stop_pulling()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/drag_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/drag_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/drag_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored || target.pulledby)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/our_mob = controller.pawn
	our_mob.start_pulling(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/drag_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
