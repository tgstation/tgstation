/// Navigates to a blackboard-keyed item and picks it up, optionally dropping whatever is held first.
/datum/ai_behavior/navigate_to_and_pick_up
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 2 SECONDS

/datum/ai_behavior/navigate_to_and_pick_up/setup(datum/ai_controller/controller, target_key, drop_held = TRUE)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/navigate_to_and_pick_up/setup(datum/ai_controller/controller, target_key, drop_held = TRUE)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(living_pawn.is_holding(target)) // already in hands
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(!target.IsReachableBy(living_pawn)) // can't reach it, despite being adjacent
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(living_pawn.get_active_held_item()) // something is in our hands already
		if(!drop_held || !living_pawn.dropItemToGround(living_pawn.get_active_held_item()))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.ai_interact(target, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | (target.loc == living_pawn ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)
