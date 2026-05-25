/// Drops a random non-weapon held item to the ground.
/datum/ai_behavior/drop_item

/datum/ai_behavior/drop_item/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/my_held_items = living_pawn.held_items - GetBestWeapon(controller, null, living_pawn.held_items)
	if(!length(my_held_items))
		return AI_BEHAVIOR_FAILED | AI_BEHAVIOR_DELAY
	living_pawn.dropItemToGround(pick(my_held_items))
	return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_DELAY
